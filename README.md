[![Travis Status](https://travis-ci.org/clarin-eric/SPF-SPs-metadata.svg?branch=master)](https://travis-ci.org/clarin-eric/SPF-SPs-metadata)
[![Latest Release](https://img.shields.io/github/v/release/clarin-eric/SPF-SPs-metadata)](https://github.com/clarin-eric/SPF-SPs-metadata/releases/latest)
[![Commits Since Latest Release](https://img.shields.io/github/commits-since/clarin-eric/SPF-SPs-metadata/latest)](https://github.com/clarin-eric/SPF-SPs-metadata/commits/master)
# Metadata sources for service providers inside the CLARIN Service Provider Federation

## Notes for service provider operators

To update or add SAML metadata for your SP:
1. Fork this repository.
2. Make your changes in the file corresponding to your SP inside the `metadata/` directory. In case you are adding a new SP, add the metadata by creating a new file following the same naming convention: `[New SP File Name] = [SP entityID].replace("http(s)?://", "").replace("/", "%2F")`
3. Create a pull request to the *master* branch of this repository.
4. Wait for Travis CI to finish the XSD validation on your pull request.
5. Make sure your pull request is XSD valid. Fix your metadata based on the Travis CI output information and update the pull request until XSD validation passes.
6. Wait for your pull request to be merged into the *master* branch by a CLARIN SPF operator. This will trigger the generation of an [aggregated quality assurance (QA) report](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html) by Travis CI.
7. Wait for Travis CI to finish the generation of the [aggregated QA report](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html). The [CLARIN bot](https://github.com/clarin-bot) will write a comment on the pull request once the generation is complete, linking to the new aggregated QA report and to any individual SP report which has changed due to your pull request.
8. Fix the issues concerning your SP described in the QA report and update your pull request accordingly (alternatively you can also submit a new pull request with your QA fixes).

After a pull request is created *(3.)* the [SAML metadata checker script](https://github.com/clarin-eric/SAML-metadata-checker) will automactically run on the pull request code via Travis CI *(4.)*. The result of this check will be visible on the pull request page. Check the [existing pull resquests](https://github.com/clarin-eric/SPF-SPs-metadata/pulls?utf8=%E2%9C%93&q=is%3Apr) on this repository for examples.

When your pull request successfully passes XSD validation *(5.)*, a CLARIN SPF operator will merge it into the *master* branch of original repository for QA assessment *(6.)*.  
Note that the SPF operators will only consider merging pull requests which are XSD valid. If you cannot make your file successfully pass the XSD validation or you believe you are hitting a false positive. Please create an ​[issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) explaining the problem. 

After your pull request is merged *(6.)*, Travis CI will automatically analyze the latest *master* version and generate a new QA report visible in ​[this page](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html) *(7.)*. When this operation has finished, the CLARIN bot](https://github.com/clarin-bot) will write a comment on the pull request linking to the new aggregated QA report and to any individual SP report which changed. Please ascertain that you comply with ​the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp). Mind to check and resolve issues in the SAML metadata quality for your SP after your pull request has been merged into the *master* branch, then update your pull request with any necessary fixes or create a new one *(8.)*. Make sure you always update the SAML metadata template of your SP to make it correspond exactly with the SAML metadata you deposit here (see e.g. ​https://goo.gl/uysudA).

If you wish that the registration/modification of the SAML metadata about your SP with identity federations is coordinated extra carefully (say, you perform a key rollover), then please create a new ​[issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) describing the task. Alternatively you can also head over to https://trac.clarin.eu/newticket and create a ticket for the 'AAI' Trac component (requires a CLARIN 'developer' account).

Finally your metadata will be released and picked up by an hourly cron job which automatically downloads the latest available release from this repository and publishes it at ​https://infra.clarin.eu/aai/md_about_spf_sps.xml (staging feed) and https://infra.clarin.eu/aai/prod_md_about_spf_sps.xml (production feed). 

Note: For an SP to be published in the production feed it must be defined first as a production SP [in our configuration](https://github.com/clarin-eric/pyFF_config/blob/master/job_b.fd). This can only be done by CLARIN SPF operators.
