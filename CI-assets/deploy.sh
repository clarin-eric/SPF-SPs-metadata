#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"
COMMIT_AUTHOR_EMAIL="clarin_spf_qa_bot@clarin.eu"

function doCompile {
  . CI-assets/compile.sh
}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Not ${SOURCE_BRANCH}. Skipping QA report build."
    exit 0
fi

# Save some useful information
REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=$(git rev-parse --verify HEAD)
COMMIT_API_INFO=$(curl --max-time 900 --connect-timeout 240 "https://api.github.com/search/issues?q=${SHA}" 2> /dev/null)
RELEVANT_PR=$(echo ${COMMIT_API_INFO} | jq .items[].number | head -1)
PR_TARGET_BRANCH=$(echo ${COMMIT_API_INFO} | jq .items[].pull_request.html_url | head -1 | grep ${TRAVIS_REPO_SLUG})

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
git config user.name "CLARIN SPF QA bot"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
git add -A .
if git diff $TARGET_BRANCH --quiet; then
    echo "No changes to the output on this push. Leaving upstream \"$TARGET_BRANCH\" branch untouched."
else
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
fi

# Comment pull request
if [ ! -z "${RELEVANT_PR}" -a ! -z "PR_TARGET_BRANCH" ]; then
    echo "Commenting pull request..."
    if [ ${#CHANGED_SPS[@]} -gt 0 ]; then
        CHANGED_SPS_HTML="<p>The following SPs changed their QA assessment with this pull request:</p><ul>Standalone QA reports:"
        for report in ${CHANGED_SPS[@]}
        do
        	# do not generate entry for aggregated report (it is always present in curl message body. See bellow)
            if [ "${report}" != "aggregated_feed_master_sps_qa_report_results.xml" ]; then
                CHANGED_SPS_HTML+="<li><a href=https://clarin-eric.github.io/SPF-SPs-metadata/web/sp_qa_report.html?${report}>${report%_sps_qa_report_results.xml}</a></li>"
            fi
        done
        CHANGED_SPS_HTML+="</ul>"
    fi
    
    curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST \
        -d "{\"body\": \"\
<img src=https://img.shields.io/github/status/contexts/pulls/${TRAVIS_REPO_SLUG}/${RELEVANT_PR}></img> \
<img src=https://img.shields.io/github/commit-status/${TRAVIS_REPO_SLUG}/${SOURCE_BRANCH}/${SHA}></img> \
<p>Automated QA assessment complete.</p>\
<p>Please check your SP in the <a href=https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html>master QA report</a> (or in its standalone QA report) \
and <strong>fix all entries marked in red</strong>. Any entries marked in yellow should also be fixed, though for those we apply some tolerance on a case by case basis.</p>\
${CHANGED_SPS_HTML} \
<p>Your SP has successfully passed our automated QA assessment when the master QA report does not include any entries for it.</p> \
<p>To submit your SAML fixes, either commit them to this pull request or open a new one.</p> \
\"}" \
        "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/issues/${RELEVANT_PR}/comments"
fi
exit 0