# Metadata sources for service providers inside the CLARIN Service Provider Federation

## Notes for service provider operators

To update or add SAML metadata for your SP:
1. Fork this repository
2. Make your changes to the clarin-sp-metadata.xml file
3. Create a pull request the 'master' branch of this repository

After a pull request is created the [SAML metadata checker script](https://github.com/clarin-eric/SAML-metadata-checker) will automactically run on the pull request code via Travis CI. The result of this check will be visible on the pull request page. Check the [existing pull resquests](https://github.com/clarin-eric/SPF-SPs-metadata/pulls?utf8=%E2%9C%93&q=is%3Apr) on this repository for examples.

When your pull request successfully passes XSD validation, a CLARIN SPF operator will merge it into the *master* branch of original repository for QA assessment. Note: the SPF operators will only consider for merging pull requests which are XSD valid. If you cannot make you file successfully pass the XSD validation or you believe you are hitting a false positive. Please create an ​[issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) explaining the problem. 

After your pull request is merged, Travis CI will automatically analyze the latest *master* version and generate a QA report visible in ​[this table](https://clarin-eric.github.io/SPF-SPs-metadata/page/master_qa_report.html).
Please ascertain that you comply with ​the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp). Mind to check and resolve issues in the SAML metadata quality for your SP after your pull request has been merged into the *master* branch, then create a new pull request containing any necessary fixes. Make sure you always update the SAML metadata template of your SP to make it correspond exactly with the SAML metadata you deposit here (see e.g. ​https://goo.gl/uysudA).

If you wish that the registration/modification of the SAML metadata about your SP with identity federations is coordinated extra carefully (say, you perform a key rollover), then please create a new ​[issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) describing the task. Alternatively you can also head over to https://trac.clarin.eu/newticket and create a ticket for the 'AAI' Trac component (requires a CLARIN 'developer' account).

Finally your metadata will be merged into the *production* branch and picked up by an hourly cron job which automatically checks out the latest version and publishes it at ​http://infra.clarin.eu/aai/prod_clarin_sp_metadata.xml 
