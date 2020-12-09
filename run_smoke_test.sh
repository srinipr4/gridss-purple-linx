#!/bin/bash

# Local system locations
install_dir=package
ref_data=gpl_ref_data_hg37
data_dir=smoke_test
run_dir=smoke_test_output

rm -rf $data_dir/amber $data_dir/cobalt $data_dir/gridss $data_dir/logs $data_dir/purple

GRIDSS_VERSION=$(grep "GRIDSS_VERSION=" Dockerfile | cut -d "=" -f 2)
GRIPSS_VERSION=$(grep "GRIPSS_VERSION=" Dockerfile | cut -d "=" -f 2)
AMBER_VERSION=$(grep "AMBER_VERSION=" Dockerfile | cut -d "=" -f 2)
COBALT_VERSION=$(grep "COBALT_VERSION=" Dockerfile | cut -d "=" -f 2)
PURPLE_VERSION=$(grep "PURPLE_VERSION=" Dockerfile | cut -d "=" -f 2)
LINX_VERSION=$(grep "LINX_VERSION=" Dockerfile | cut -d "=" -f 2)

export GRIDSS_JAR=$install_dir/gridss/gridss-${GRIDSS_VERSION}-gridss-jar-with-dependencies.jar
export GRIPSS_JAR=$install_dir/hmftools/gripss-${GRIPSS_VERSION}.jar
export AMBER_JAR=$install_dir/hmftools/amber-${AMBER_VERSION}.jar
export COBALT_JAR=$install_dir/hmftools/cobalt-${COBALT_VERSION}.jar 
export PURPLE_JAR=$install_dir/hmftools/purple-${PURPLE_VERSION}.jar
export LINX_JAR=$install_dir/hmftools/sv-linx_v${LINX_VERSION}.jar

bash -x gridss-purple-linx.sh \
	-o $run_dir \
	-n $data_dir/CPCT12345678R.bam \
	-t $data_dir/CPCT12345678T.bam  \
	-v $data_dir/CPCT12345678T.somatic_caller_post_processed.vcf.gz \
	--snvvcf $data_dir/CPCT12345678T.somatic_caller_post_processed.vcf.gz \
	-s CPCT12345678 \
	--normal_sample CPCT12345678R \
	--tumour_sample CPCT12345678T \
	--ref_dir $ref_data \
	--install_dir $install_dir \
	--gridss_args "--jvmheap 14g"
	
