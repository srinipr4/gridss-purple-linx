#!/bin/bash
docker run --ulimit nofile=100000:100000 \
	-v c:/dev/gridss-purple-linx/gpl_ref_data_hg37:/refdata \
	-v c:/dev/gridss-purple-linx/smoke_test:/data/ \
	gridss/gridss-purple-linx:latest \
	-n /data/CPCT12345678R.bam \
	-t /data/CPCT12345678T.bam \
	-v /data/smoketest.vcf \
	-s smoketest \
	--normal_sample CPCT12345678R \
	--tumour_sample CPCT12345678T \
	--snvvcf /data/CPCT12345678T.somatic_caller_post_processed.vcf.gz \
	--jvmheap 15g \
	--threads 4 \







