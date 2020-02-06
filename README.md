[![Travis Status](https://travis-ci.org/clarin-eric/SPF-SPs-metadata.svg?branch=production)](https://travis-ci.org/clarin-eric/SPF-SPs-metadata)
# Staging metadata sources for service providers inside the CLARIN Service Provider Federation
---
## Notes for service provider operators:
**Do not fork or submmit pull-requests to this branch!**

---

This branch contains the live input for the SAML agreegation pipeline of the CLARIN SPF.

Every hour the contents of the [clarin-sp-metadata.xml](https://github.com/clarin-eric/SPF-SPs-metadata/blob/production/clarin-sp-metadata.xml) file are automatically fetched by the the agregation pipeline, processed and propagated to the CLARIN SPF [staging](https://infra.clarin.eu/aai/md_about_spf_sps.xml) and [production](https://infra.clarin.eu/aai/prod_md_about_spf_sps.xml) SAML feeds.
