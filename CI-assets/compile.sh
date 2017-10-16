#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
QA_VALIDATOR_VERSION=travis
SAXON_VERSION=SaxonHE9-6-0-10J
SAXON_URL=https://netcologne.dl.sourceforge.net/project/saxon/Saxon-HE/9.6/$SAXON_VERSION.zip
SCHEMATRON_VERSION=1.0-CLARIN
INSTALLS_PATH=qa-tmp


mkdir -p $INSTALLS_PATH/saxon
cd $INSTALLS_PATH/saxon
wget $SAXON_URL
unzip -o $SAXON_VERSION.zip
rm $SAXON_VERSION.zip
cd ..
wget -O schematron.tar.gz https://codeload.github.com/clarin-eric/schematron/tar.gz/$SCHEMATRON_VERSION
tar xvf schematron.tar.gz schematron-$SCHEMATRON_VERSION/trunk/schematron/code/
mv schematron-$SCHEMATRON_VERSION/trunk/schematron/code schematron
rm -rf schematron-$SCHEMATRON_VERSION schematron.tar.gz

wget -O SAML_metadata_QA_validator.tar.gz https://codeload.github.com/clarin-eric/SAML_metadata_QA_validator/tar.gz/$QA_VALIDATOR_VERSION
tar xvf SAML_metadata_QA_validator.tar.gz
cd SAML_metadata_QA_validator-$QA_VALIDATOR_VERSION
ant -v
rm out/SAML_metadata_QA_validator.concrete.sch out/SAML_metadata_QA_validator.xsl out/.gitignore
if [ ! -d "../../out/" ]; then
	mkdir ../../out/
fi
mv out/* ../../out/
cd ../.. && rm -rf $INSTALLS_PATH


