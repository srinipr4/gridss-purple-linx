#!/bin/bash
#
# Packages release artifacts based on the versions specified in the Dockerfiles
#
rm -rf package
mkdir -p package/gridss package/gridss-purple-linx package/hmftools

version=$(grep software.version Dockerfile | grep -oh '".*"' | tr -d \")

GRIDSS_VERSION=$(grep "GRIDSS_VERSION=" Dockerfile | cut -d "=" -f 2)
GRIPSS_VERSION=$(grep "GRIPSS_VERSION=" Dockerfile | cut -d "=" -f 2)
AMBER_VERSION=$(grep "AMBER_VERSION=" Dockerfile | cut -d "=" -f 2)
COBALT_VERSION=$(grep "COBALT_VERSION=" Dockerfile | cut -d "=" -f 2)
PURPLE_VERSION=$(grep "PURPLE_VERSION=" Dockerfile | cut -d "=" -f 2)
LINX_VERSION=$(grep "LINX_VERSION=" Dockerfile | cut -d "=" -f 2)

cd package/gridss
wget https://github.com/PapenfussLab/gridss/releases/download/v$GRIDSS_VERSION/gridss-$GRIDSS_VERSION.tar.gz &
cd -
cd package/hmftools
wget https://github.com/hartwigmedical/hmftools/releases/download/gripss-v$GRIPSS_VERSION/gripss-$GRIPSS_VERSION.jar &
wget https://github.com/hartwigmedical/hmftools/releases/download/amber-v$AMBER_VERSION/amber-$AMBER_VERSION.jar &
wget https://github.com/hartwigmedical/hmftools/releases/download/cobalt-v$COBALT_VERSION/cobalt-$COBALT_VERSION.jar &
wget https://github.com/hartwigmedical/hmftools/releases/download/purple-v$PURPLE_VERSION/purple-$PURPLE_VERSION.jar &
wget https://github.com/hartwigmedical/hmftools/releases/download/sv-linx-v$LINX_VERSION/sv-linx_v$LINX_VERSION.jar &
cd -
cp gridss-purple-linx.sh package/gridss-purple-linx/
wait
cd package/gridss
tar zxvf gridss-$GRIDSS_VERSION.tar.gz
chmod a+x *.sh *.R
cd - 
cd package
wait
tar -zcvf ../gridss-purple-linx-v$version.tar.gz .
