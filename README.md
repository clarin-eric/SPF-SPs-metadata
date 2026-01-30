[![Validate MD and generate QA Report](https://github.com/clarin-eric/SPF-SPs-metadata/actions/workflows/val-and-upd.yml/badge.svg)](https://github.com/clarin-eric/SPF-SPs-metadata/actions/workflows/val-and-upd.yml)
[![Latest Release](https://img.shields.io/github/v/release/clarin-eric/SPF-SPs-metadata)](https://github.com/clarin-eric/SPF-SPs-metadata/releases/latest)
[![Commits Since Latest Release](https://img.shields.io/github/commits-since/clarin-eric/SPF-SPs-metadata/latest)](https://github.com/clarin-eric/SPF-SPs-metadata/commits/master)

# Metadata sources for service providers inside the CLARIN Service Provider Federation

[View our most recent QA report for all service providers](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html)

## Notes for service provider operators

To update or add SAML metadata for your SP:

1. **Fork this repository.**
2. **Modify the metadata file** corresponding to your SP inside the `metadata/` directory.  
   If you are adding a new SP, create a new file following this naming convention:
    ```
    [New SP File Name] = [SP entityID].replace("http(s)?://", "").replace("/", "%2F") + ".xml"`.
    ```
   Check the existing files for examples.
3. **Create a pull request** to the *master* branch of this repository.  
You can do this using a Git client or GitHub’s web interface.
4. **Wait for GitHub Actions to finish all checks** on your pull request.
5. After all checks complete, the pull request will be updated automatically with a comment containing two reports:  
1. **Certificate & XML Validation Summary** – SPF operators will only consider merging pull requests that pass all checks in this report.  
2. **Metadata Quality Assurance Summary** – warnings may be acceptable in some cases, but you should generally fix them, especially entries marked as **error**.
6. In your fork, **fix all issues** described in the reports and commit your changes.  
The pull request will update automatically and the checks will restart.
7. A CLARIN SPF operator may request **additional changes** not covered by the automated checks.
8. When all checks pass and your metadata meets the quality standards, a CLARIN SPF operator will merge your pull request.

---

### Certificate & XML Validation checks

After a pull request is created *(step 3)*, GitHub Actions runs the [SAML metadata checker script](https://github.com/clarin-eric/SAML-metadata-checker) to:

- validate your SP file against the XSD schema  
- check the certificate for:
  - **key size** (must be ≥ 3072 bits)  
  - **expiration date** (should be at least 30 days in the future)

When this finishes, GitHub Actions posts a comment on the pull request with the results.  
See the existing pull requests for examples:  
https://github.com/clarin-eric/SPF-SPs-metadata/pulls?q=is%3Apr

If you cannot make your file pass the XSD validation or certificate checks, please create an [issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) explaining the problem.

---

### Metadata Quality Assurance checks

After a pull request is created *(step 3)*, GitHub Actions also generates a **QA report**. This report is posted as a comment on the pull request.

Please ensure your metadata complies with the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp).  
Review and resolve any issues reported in the QA output, and update your metadata file accordingly.

---

### Other considerations

*(Step 6)* Make sure you also update your SP’s SAML metadata template so it matches exactly the metadata you deposit here (see e.g. https://goo.gl/uysudA).

ℹ️ A short video demonstrating how to update your SP metadata directly in GitHub is available:  
https://b2drop.eudat.eu/s/HmTqbrz3pFaBdHC

If you need the registration or modification of your SP’s SAML metadata to be coordinated carefully (e.g., during a key rollover), please create a new [issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) describing the task.

---

Once merged into master, your metadata will be picked up by an hourly cron job, which publishes it in the SPF staging feed - making it available for the CLARIN IdP:
- **Staging feed:** https://infra.clarin.eu/aai/md_about_spf_sps.xml  

Finally, once a release of master is created, the hourly cron job will publish it in the SPF production feed - making it available for all eduGAIN IdPs:
- **Production feed:** https://infra.clarin.eu/aai/prod_md_about_spf_sps.xml  

**Note:** For an SP to appear in the production feed, it must first be included in a release and registered with production status in the [CLARIN Centre Registry](https://centres.clarin.eu/spf). Please create a ticket for this, when you 
want to promote your SP to production.
