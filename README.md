[![Validate MD and generate QA Report](https://github.com/clarin-eric/SPF-SPs-metadata/actions/workflows/val-and-upd.yml/badge.svg?event=push)](https://github.com/clarin-eric/SPF-SPs-metadata/actions/workflows/val-and-upd.yml)
[![Latest Release](https://img.shields.io/github/v/release/clarin-eric/SPF-SPs-metadata)](https://github.com/clarin-eric/SPF-SPs-metadata/releases/latest)
[![Commits Since Latest Release](https://img.shields.io/github/commits-since/clarin-eric/SPF-SPs-metadata/latest)](https://github.com/clarin-eric/SPF-SPs-metadata/commits/master)

# Metadata sources for service providers inside the CLARIN Service Provider Federation

[View our most recent QA report for all service providers](https://clarin-eric.github.io/SPF-SPs-metadata/web/master_qa_report.html)

## Notes for service provider operators

## Prerequisites

Before updating or adding your Service Provider’s metadata, please ensure that you have:

- **A GitHub account** and the ability to fork repositories under your own profile or organisation.  
- **Basic familiarity with GitHub**, either through the web interface or a Git client, so you can edit files and submit pull requests.  
- **Access to your SP’s SAML configuration**, allowing you to keep your deployed configuration aligned with the metadata you submit here.  
- **Authority within your organisation** to update SAML metadata, including certificates, endpoints, and technical contact information.  
- **A valid X.509 certificate** for your SP that meets the required key size and validity period.  
- **Knowledge of your SP’s entityID, endpoints, and attribute requirements**, as described in the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp).

---

### To update or add SAML metadata for your SP:

1. **Fork this repository.**
2. **Modify the metadata file** corresponding to your SP inside the `metadata/` directory.  
   If you are adding a new SP, create a new file following this naming convention:
    ```
    [New SP File Name] = [SP entityID].replace("http(s)?://", "").replace("/", "%2F") + ".xml"
    ```
   Example:  
   `https://example.org/sp` → `example.org%2Fsp.xml`  
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

Once your pull request is merged into *master*, an hourly cron job will publish your metadata to the **SPF staging feed**, making it available to the CLARIN IdP within approximately one hour:

- **Staging feed:** https://infra.clarin.eu/aai/md_about_spf_sps.xml  

After merging, a release of the *master* branch will be created.  
The hourly cron job will then publish the metadata to the **SPF production feed**, making it available to all eduGAIN IdPs.  
Full propagation across eduGAIN typically completes within ~24 hours:

- **Production feed:** https://infra.clarin.eu/aai/prod_md_about_spf_sps.xml

You can verify how your metadata has propagated across national federations and eduGAIN using the **CLARIN Centre Registry**:  
https://centres.clarin.eu/spf  
Click the green triangles to view the diff between your metadata and the version known to each federation.

> **Note:** For an SP to appear in the production feed for the first time, it must first be marked with production status in the [CLARIN Centre Registry](https://centres.clarin.eu/spf).  
Please create a ticket when you want to promote your SP to production for the first time.

---

#### Certificate & XML Validation checks

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

#### Metadata Quality Assurance checks

After a pull request is created *(step 3)*, GitHub Actions also generates a **QA report**. This report is posted as a comment on the pull request.

Please ensure your metadata complies with the [SAML metadata guidelines](https://www.clarin.eu/content/guidelines-saml-metadata-about-your-sp).  
Review and resolve any issues reported in the QA output, and update the metadata file in your pull request accordingly.

---

#### Other considerations when depositing your metadata

*(Step 6)* When modifying fields with technical impact, please make sure you also update your SP’s configuration so it matches the metadata you deposit here.

ℹ️ Here is short video demonstrating how to add a new SP directly using only the GitHub website:  
https://b2drop.eudat.eu/s/myZtSFi6DgEw3Rb

If you need the registration or modification of your SP’s SAML metadata to be coordinated carefully (e.g., during a key rollover), please create a new [issue](https://github.com/clarin-eric/SPF-SPs-metadata/issues/new) describing the task.

---

### Metadata file template for first time depositors

You can use the following template to create a SAML metadata file for your SP for the first time.
Adapt all fields marked with `[CHANGE ME]` and remove the explanatory comments.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:idpdisc="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
    xmlns:init="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
    xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
    xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns:remd="http://refeds.org/metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:shibmd="urn:mace:shibboleth:metadata:1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    entityID="[CHANGE ME] https://sp.catalog.clarin.eu">
    <md:Extensions>
        <mdattr:EntityAttributes>
            <saml:Attribute NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
                Name="http://macedir.org/entity-category">
                <saml:AttributeValue>http://www.geant.net/uri/dataprotection-code-of-conduct/v1</saml:AttributeValue>
                <saml:AttributeValue>http://refeds.org/category/research-and-scholarship</saml:AttributeValue>
                <saml:AttributeValue>http://clarin.eu/category/clarin-member</saml:AttributeValue>
            </saml:Attribute>
        </mdattr:EntityAttributes>
    </md:Extensions>
    <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:Extensions>
            <mdui:UIInfo>
                <mdui:DisplayName xml:lang="en">[CHANGE ME] CLARIN CMDI metadata (prod)</mdui:DisplayName> <!-- Informative -->
                <mdui:Description xml:lang="en">[CHANGE ME] For the Component Registry, Virtual Language Observatory.</mdui:Description> <!-- Informative -->
                <mdui:InformationURL xml:lang="en">[CHANGE ME] https://www.clarin.eu/applications</mdui:InformationURL> <!-- Informative -->
                <mdui:Logo height="220" width="195">[CHANGE ME] https://www.clarin.eu/sites/default/files/clarin-logo.png</mdui:Logo> <!-- Informative -->
                <mdui:Keywords xml:lang="en">[CHANGE ME] CLARIN catalog Component+Registry Virtual+Language+Observatory VLO</mdui:Keywords> <!-- Informative -->
                <mdui:PrivacyStatementURL xml:lang="en">[CHANGE ME] https://catalog.clarin.eu/privacy_statement.xhtml</mdui:PrivacyStatementURL> <!-- Informative with technical impact -->
            </mdui:UIInfo>
            <init:RequestInitiator Binding="urn:oasis:names:tc:SAML:profiles:SSO:request-init"
                Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/Login"/> <!-- Technical impact -->
            <idpdisc:DiscoveryResponse Binding="urn:oasis:names:tc:SAML:profiles:SSO:idp-discovery-protocol"
                Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/Login" 
                index="1"/> <!-- Technical impact -->
        </md:Extensions>
        <md:KeyDescriptor>
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>[CHANGE ME] MIID6zCCAlOgAwIBAgIJANuz74wrvwz/MA0GCSqGSIb3DQEBCwUAMBcxFTATBgNV
BAMTDDg4NzExYTI4MjMwNzAeFw0xOTA0MTUxMjQ0MzFaFw0yOTA0MTIxMjQ0MzFa
MBcxFTATBgNVBAMTDDg4NzExYTI4MjMwNzCCAaIwDQYJKoZIhvcNAQEBBQADggGP
ADCCAYoCggGBAKTA3XtHQLhHn55smhE6B3Hhv38AfcungbDYayDb8GYFOzhFFYLd
WR5hJCrdUOY7JxowBsKYv7dcJWt6PUz44vPfuC+YRPopOVW0PKNoXDeAYi3AFTDA
7ZAziEEQ4PF+7f1BqEsllccaQmpSbb1v0LWehoOIznZV+LQZaEVRI+t6W6eOlox8
c8j0cYeNUmE7aEcOVbD/a5eZxa/9K1XRthONA+4HmgHR+XmbIizMRL7NyVAvIjOL
dXtV+cyRVgRm4/QjBM3mkfNvrXCLyQxeXRNG2sCKZqRdnVV+/61IW+IUt6iemcE9
59waJJLoTm2y9JFH4YZM+FHqOHp7SdemKnR+UlQjvW4X3L/DB8j3xqd6U3+7NN0s
xq/sMqKm9FzWoQ5SevFdkboG2b+aSoXIhwT1FQDhl7H1QhIadhx33kf1dkSzhCQf
bbvFiwngfqkMOBAlv8aY6MoZYGPWTUQGKk5TdH8sFLJkFfkNPX5sf550XEpAiM+5
NL0KQ0V7CiBG9wIDAQABozowODAXBgNVHREEEDAOggw4ODcxMWEyODIzMDcwHQYD
VR0OBBYEFNzNA4+BU9xiCMsAYQmiYcK5wTn4MA0GCSqGSIb3DQEBCwUAA4IBgQCJ
7GHb9cBx2/e7gyFP6huRhjIJK04CROQz6RJBuZf0MpzbOmRqkM6/NIwN13ZiagXY
NUe0NQsDnKlpSeQFdMgj9grCJvSCseHNAMaQm2hjXLrPqdI6DiVApXkm36bB8v65
L1SGSxIiLpT51bu/mJn7mSZcBt89ffj47jtdwy/RZhCb6qD1W2jz3NU9LS0ZLKpc
9GsVO57j8U6rLrfRxbQHX5GXhm8Bz+8QDb6JHHkq6mdB+IlLc8jR1IUviwHAbQVz
TQCP+EYe38XaT9q/Ecxk4OWGkoW0Y6/dBD1nKnTUG7/0CdMVM6O9njqrXUyp0gqx
45WRdQYINE78djmT5woUEqBX1ZjNMkftE/VUow9CODW7zdGewnwdSBgKxcOpjsGo
5zHRoTDDnAxsOc2KC4VRAWBJhbL1dDTiPW8kpT8O02sHOmrQsAhqME3IntRv0PaA
d7ttcj/dT4m8TJc/fKvOFPzw2UvsyX5axX0umdI3pN4PRW9cDYkAwY75+p0v+zI=</ds:X509Certificate> <!-- Technical impact -->
                </ds:X509Data>
            </ds:KeyInfo>
        </md:KeyDescriptor>
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SLO/SOAP"/> <!-- Technical impact -->
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SLO/Redirect"/> <!-- Technical impact -->
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SLO/POST"/> <!-- Technical impact -->
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SLO/Artifact"/> <!-- Technical impact -->
        <md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</md:NameIDFormat>
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SAML2/POST"
            index="1"/> <!-- Technical impact -->
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SAML2/POST-SimpleSign"
            index="2"/> <!-- Technical impact -->
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SAML2/Artifact"
            index="3"/> <!-- Technical impact -->
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS"
            Location="[CHANGE ME] https://catalog.clarin.eu/Shibboleth.sso/SAML2/ECP"
            index="4"/> <!-- Technical impact -->
        <md:AttributeConsumingService index="1">
            <md:ServiceName xml:lang="en">[CHANGE ME] CLARIN CMDI metadata (prod)</md:ServiceName>
            <md:ServiceDescription xml:lang="en">[CHANGE ME] For the Component Registry, Virtual Language Observatory.</md:ServiceDescription>
            <md:RequestedAttribute FriendlyName="eduPersonPrincipalName"
                Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6"
                NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
                isRequired="true"/> <!-- Technical impact -->
            <md:RequestedAttribute FriendlyName="eduPersonTargetedID"
                Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10"
                NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
                isRequired="true"/> <!-- Technical impact -->
            <md:RequestedAttribute FriendlyName="mail"
                Name="urn:oid:0.9.2342.19200300.100.1.3"
                NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
                isRequired="true"/> <!-- Technical impact -->
            <!-- include more attributes here in case your application needs then --> <!-- Technical impact -->
        </md:AttributeConsumingService>
    </md:SPSSODescriptor>
    <md:Organization>
        <md:OrganizationName xml:lang="en">[CHANGE ME] CLARIN ERIC</md:OrganizationName> <!-- Informative with technical impact -->
        <md:OrganizationDisplayName xml:lang="en">[CHANGE ME] CLARIN</md:OrganizationDisplayName> <!-- Informative with technical impact -->
        <md:OrganizationURL xml:lang="en">[CHANGE ME] https://www.clarin.eu/</md:OrganizationURL> <!-- Informative with technical impact -->
    </md:Organization>
    <md:ContactPerson contactType="administrative">
        <md:GivenName>[CHANGE ME] CLARIN</md:GivenName> <!-- Informative -->
        <md:SurName>[CHANGE ME] System operators</md:SurName> <!-- Informative -->
        <md:EmailAddress>[CHANGE ME] mailto:clarin@clarin.eu</md:EmailAddress> <!-- Informative with technical impact -->
    </md:ContactPerson>
    <md:ContactPerson contactType="support">
        <md:GivenName>[CHANGE ME] CLARIN</md:GivenName> <!-- Informative -->
        <md:SurName>[CHANGE ME] System operators</md:SurName> <!-- Informative -->
        <md:EmailAddress>[CHANGE ME] mailto:sysops@clarin.eu</md:EmailAddress> <!-- Informative with technical impact -->
    </md:ContactPerson>
    <md:ContactPerson contactType="technical">
        <md:GivenName>[CHANGE ME] CLARIN</md:GivenName> <!-- Informative -->
        <md:SurName>[CHANGE ME] System operators</md:SurName> <!-- Informative -->
        <md:EmailAddress>[CHANGE ME] mailto:sysops@clarin.eu</md:EmailAddress> <!-- Informative with technical impact -->
    </md:ContactPerson>
</md:EntityDescriptor>
```

> **Note:** This template is an example. Do not reuse the example URLs, contacts, or certificate values in production.

#### SAML X509 certificate recommendations:

For information and intructions about how to create and rollover your a certificate with or without service disruption see:

https://doku.tid.dfn.de/en:certificates#information_for_service_providers and

https://help.switch.ch/aai/guides/sp/certificate-rollover/

Please also follow the following guidelines:
- Do not use the same SSL certificate you use in your http webserver for SSL termination.
- Use self-signed certificates whenever possible.
- Always use a key size of at least 3072 bits.
- Always use a certificate expiration date of 3-5 years in the future.
