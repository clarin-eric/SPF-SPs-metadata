#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
set -x
QA_VALIDATOR_VERSION=1.0.8
SAXON_VERSION=SaxonHE9-9-1-5J
SAXON_URL=https://netcologne.dl.sourceforge.net/project/saxon/Saxon-HE/9.9/$SAXON_VERSION.zip
SCHEMATRON_VERSION=1.0.1-e16ecc4-CLARIN
INSTALLS_PATH=qa-tmp

sed_cmd="sed"
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed_cmd="gsed"
fi

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
md_files=../../metadata/*.xml
for file in ${md_files}
do
    ant -v -DinputFile="file:$(realpath ${file})"
done
number_of_files=$(ls ${md_files} 2> /dev/null | wc -l)
if [ ${number_of_files} -gt 1 ]; then
	echo "Generating and testing aggregated output..."
	((xmllint -xpath "/*[local-name()='EntitiesDescriptor' and namespace-uri()='urn:oasis:names:tc:SAML:2.0:metadata']" ../../CI-assets/feed_wrapper.xml  | \
        head -1; xmllint -xpath "/*[local-name()='EntityDescriptor' and namespace-uri()='urn:oasis:names:tc:SAML:2.0:metadata']" ../../metadata/*;tail -1 ../../CI-assets/feed_wrapper.xml) | \
        xmllint --nsclean --format -) > ../../$TARGET_BRANCH/aggregated_feed_${SOURCE_BRANCH}.xml
	ant -v -DinputFile="file:$(realpath ../../$TARGET_BRANCH/aggregated_feed_${SOURCE_BRANCH}.xml)"
fi
rm -rf out/*.sch out/*.xsl out/.gitignore
if [ ! -d "../../$TARGET_BRANCH/reports/" ]; then
    mkdir ../../$TARGET_BRANCH/reports/
fi
for report in out/*results.xml
do
	set +e
    if ! diff -q ${report} ../../$TARGET_BRANCH/reports/$(basename ${report}) > /dev/null; then
    	set -e
    	echo "Report $(basename $report) has changed"

    	${sed_cmd} -i "2i <report>" ${report}
    	${sed_cmd} -i "3i <FromCommit>${SHA}</FromCommit>" ${report}
    	${sed_cmd} -i "\$a</report>" ${report}
    	xmllint --output ${report} --format ${report}
    	
    	mv ${report} ../../$TARGET_BRANCH/reports/
    	filename_wo_ext="${report%_results.xml}"
    	mv ${filename_wo_ext}.xml ../../$TARGET_BRANCH/reports/
    	mv ${filename_wo_ext}.svrlt ../../$TARGET_BRANCH/reports/
    else
    	set -e
    	echo "Report $(basename ${report}) is unhanged. Leaving previous version in place."
    fi
done
cd ../.. && rm -rf $INSTALLS_PATH
