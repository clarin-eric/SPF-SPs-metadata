# Metadata sources for service providers inside the CLARIN Service Provider Federation

## Notes for service provider operators

To update or create SAML metadata for your SP:
1. Fork this repository
2. Make your changes to the clarin-sp-metadata.xml file
3. Create a pull request to this repository

After a pull request is created the [SAML metadata checker script](https://github.com/clarin-eric/SAML-metadata-checker) will automactically run on the pull request commited code via Travis CI. The result of this check will be visible on the pull request page.

Please ascertain that you comply with ​the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp). Mind to check and resolve issues in the SAML metadata quality for your SP before and after your commit, as listed in ​[this spreadsheet](https://goo.gl/Nl0DCH). Finally, always update the SAML metadata template of your SP to make it correspond exactly with the SAML metadata you deposit here (see e.g. ​https://goo.gl/uysudA).
If you wish that the registration/modification of the SAML metadata about your SP with identity federations is coordinated extra carefully (say, you perform a key rollover), then please head over to https://trac.clarin.eu/newticket and create a ticket for the 'AAI' Trac component, describing the task (you will need a CLARIN.eu 'developer' account to do so). 

Once the pull request is acepted our system will automactically update the CLARIN SPF metadata feeds in less than 1 hour.