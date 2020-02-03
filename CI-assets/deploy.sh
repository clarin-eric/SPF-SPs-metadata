#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"
COMMIT_AUTHOR_EMAIL="clarin_bot@clarin.eu"

function doCompile {
  . CI-assets/compile.sh
}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping QA report build."
    exit 0
fi

# Save some useful information
REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=$(git rev-parse --verify HEAD)

# Clone the existing qa-output for this repo into out/
# Create a new empty branch if qa-output doesn't exist yet (should only happen on first deploy)
rm -rf $TARGET_BRANCH
git clone $REPO $TARGET_BRANCH
cd $TARGET_BRANCH
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH

# Run our compile script
cd ..
doCompile

# Now let's go have some fun with the cloned repo
cd $TARGET_BRANCH
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
git add -A .
if git diff $TARGET_BRANCH --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../CI-assets/deploy_key.enc -out ../CI-assets/deploy_key -d
chmod 600 ../CI-assets/deploy_key
eval `ssh-agent -s`
ssh-add ../CI-assets/deploy_key

# Commit the "changes", i.e. the new version.
git commit -m "Deploy SAML QA report for: ${SHA}"

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH

# TODO
# Comment pull request
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Commenting pull request"
    curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST \
        -d "{\"body\": \"https://img.shields.io/github/status/s/pulls/clarin-eric/SPF-SPs-metadata/${TRAVIS_PULL_REQUEST}
Automated QA assessment complete. Please check you SP at [QA report](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html)\"}" \
        "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/issues/${TRAVIS_PULL_REQUEST}/comments"
fi
exit 0