
# GRIDSS PURPLE LINX

The GRIDSS/PURPLE/LINX toolkit takes a pair of match tumour/normal BAM files, and performs somatic genomic rearrangement detection and classificatiion.

- [GRIDSS](https://github.com/PapenfussLab/gridss): performs structural variant calling
- [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator): performs allele specific copy number calling
- [LINX](https://github.com/hartwigmedical/hmftools/tree/master/sv-linx): performs event classification, and visualisation

The simplest way to run the toolkit is through the docker image

# Prerequisites

The prerequities for running the toolkit depend on whether it is run directly, or through the docker image.
If you are using to docker image, only the reference data is required.

### Reference data

The toolkit requires multiple reference data sets. These have been packaged into a single download.

|reference genome | download location |
|---|---|
|hg37|https://resources.hartwigmedicalfoundation.nl/ then navigate to HMFTools-Resources/GRIDSS-Purple-Linx-Docker/gpl_ref_data_hg37.gz|
|hg38|https://resources.hartwigmedicalfoundation.nl/ then navigate to HMFTools-Resources/GRIDSS-Purple-Linx-Docker/gpl_ref_data_hg38.gz|


### External software (local installation)

The following software is required to run to toolkit if installing locally:

- GRIDSS PURPLE LINX toolkit
  - A combined package is downloadable from https://github.com/hartwigmedical/gridss-purple-linx/releases
- java 8
- R 3.6.1
- bwa
- samtools
- sambamba
- circos (including all dependencies and Perl packages)

#### R CRAN packages
- tidyverse
- assertthat
- testthat
- NMF
- randomForest
- stringdist
- stringr
- argparser
- R.cache
- BiocManager
- Rcpp
- blob
- RSQLite
- cowplot
- magick

#### R BioConductor packages

- copynumber
- StructuralVariantAnnotation
- VariantAnnotation
- rtracklayer
- BSgenome
- Rsamtools
- biomaRt
- Gviz
- org.Hs.eg.db

Also required are the `TxDb` and `BSGenome` package for your reference genome

- TxDb.Hsapiens.UCSC.hg19.knownGene
- TxDb.Hsapiens.UCSC.hg38.knownGene
- BSgenome.Hsapiens.UCSC.hg19
  - This package is included in the hg19 reference data package
- BSgenome.Hsapiens.UCSC.hg38

# Command line arguments

The driver script can be found in the `gridss-purple-linx/gridss-purple-linx.sh` directory of the release package.
When running from docker, this is the docker image entry point.

## Required arguments

The following command-line arguments are required:

|Argument|Description|
|---|---|
|--tumour_bam|tumour BAM file|
|--normal_bam|matched normal BAM file|
|--sample|sample name|
|--snvvcf|A somatic SNV VCF with the AD genotype field populated. |
|--nosnvvcf|Indicates a somatic SNV VCF will not be supplied.|

Note that only one of Only one of `--snvvcf` or `--nosnvvcf` should be specified. As not supplying a somatic SNV VCF results reduces PURPLE performance, this file must be explicitly omitted via `--nosnvvcf`.

## Optional arguments

The driver script has many optional arguments.
The default values match those required to run the Docker image using the hg19 reference data.
The docker image assumes the output directory is `/data`, and the reference data package is located in `/refdata`

|Argument|Description|Default|
|---|---|---|
|--output_dir|output directory|/data/|
|--threads|number of threads to use.|number of cores available|
|--normal_sample|sample name of matched normal| ${sample}_N|
|--tumour_sample|sample name of tumour. Must match the somatic --snvvcf sample name.|${sample}_T |
|--jvmheap|maximum java heap size for high-memory steps|25g|
|--ref_dir|path to decompressed reference data package.|/refdata|

#### Reference data paths

These reference data paths are all relative to `--ref_dir`.
The default values match those required of the hg19 reference data.

|Argument|Description|Default|
|---|---|---|
|--reference|reference genome|refgenomes/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta|
|--repeatmasker|repeatmasker .fa.out file for reference genome|refgenomes/dbs/repeatmasker/hg19.fa.out|
|--blacklist|Blacklisted regions|dbs/gridss/ENCFF001TDO.bed|
|--bafsnps|bed file of het SNP locations used by amber.|dbs/germline_het_pon_hg19/GermlineHetPon.hg19.bed|
|--gcprofile|.cnp file of GC in reference genome. 1k bins|dbs/gc/GC_profile.1000bp.cnp|
|--gridsspon|GRIDSS PON|dbs/gridss/pon3792v1|
|--viralreference|viral reference database (fasta format)|refgenomes/human_virus/human_virus.fa|
|--rlib|R library path that include correct BSgenome package|rli)|
|--viral_hosts_csv|viral contig to name lookup|dbs/sv/viral_host_ref.csv|
|--fusion_pairs_csv|known driver gene fusions|dbs/knowledgebases/output/knownFusionPairs.csv|
|--promiscuous_five_csv|known promiscuous gene fusions |dbs/knowledgebases/output/knownPromiscuousFive.csv|
|--promiscuous_three_csv|known promiscuous gene fusions|dbs/knowledgebases/output/knownPromiscuousThree.csv|
|--fragile_sites|known fragile sites|dbs/sv/fragile_sites_hmf.csv|
|--line_elements|known LINE donor sites|dbs/sv/line_elements.csv|
|--replication_origins|replication timing BED file|dbs/sv/heli_rep_origins.bed|
|--ensembl_data_dir|ensemble data cache|dbs/ensembl_data_cache|
|--install_dir|root directory of gridss-purple-linx release package|/opt/|


## Example Usage (COLO829 cell line)

Let us assume the following:

1) Your sample is in /home/user/colo829_example

|File|Description|
|---|---|
|COLO829T_dedup.realigned.bam|Tumour sample (COLO829T cell line)|
|COLO829T_dedup.realigned.bam.bai|BAM index|
|COLO829R_dedup.realigned.bam|Matched normal (COLO829BL cell line)|
|COLO829R_dedup.realigned.bam.bai|BAM index|
|COLO829.somatic_caller_post_processed.vcf.gz|strelka somatic calls|

and your stelka somatic sample name is COLO829_T

2) You have downloaded and decompressed the hg19 reference `gridss-purple-linx-docker-image-refdata-hg19.tar.gz` to `/home/user/refdata/`

3) You have downloaded the gridss-purple-linx release to `/home/user/gridss-purple-linx/` (Not required if using docker image)

### Docker

This simplest way to run the pipeline is through the docker image. The docker images assumes the following:

- The reference data is mounted read/write in `/refdata`
- The input/output directory is  mounted read/write in `/data`

To run the docker image on the above example, the following docker command line would be used:

```
docker run --ulimit nofile=100000:100000 \
	-v /home/user/refdata/:/refdata \
	-v /home/user/colo829_example/data/ \
	gridss/gridss-purple-linx:latest \
	-n /data/COLO829R_dedup.realigned.bam \
	-t /data/COLO829T_dedup.realigned.bam \
	-s COLO829 \
	--snvvcf /data/COLO829.somatic_caller_post_processed.vcf.gz
```

The ulimit increase is due to GRIDSS multi-threading using many file handles.

### Directly

To run the toolkit directly, one would use the following command-line:

```
install_dir=~/
GRIDSS_VERSION=2.6.2
COBALT_VERSION=1.7
PURPLE_VERSION=2.34
LINX_VERSION=1.4
export GRIDSS_JAR=$install_dir/gridss/gridss-${GRIDSS_VERSION}-gridss-jar-with-dependencies.jar
export AMBER_JAR=$install_dir/hmftools/amber-${AMBER_VERSION}-jar-with-dependencies.jar
export COBALT_JAR=$install_dir/hmftools/count-bam-lines-${COBALT_VERSION}-jar-with-dependencies.jar
export PURPLE_JAR=$install_dir/hmftools/purity-ploidy-estimator-${PURPLE_VERSION}-jar-with-dependencies.jar
export LINX_JAR=$install_dir/hmftools/sv-linx-${LINX_VERSION}-jar-with-dependencies.jar

$install_dir/gridss-purple-linx/gridss-purple-linx.sh \
	-n ~/colo829_example/COLO829R_dedup.realigned.bam \
	-t ~/colo829_example/COLO829T_dedup.realigned.bam \
	-s COLO829 \
	--snvvcf ~/colo829_example/COLO829.somatic_caller_post_processed.vcf.gz \
	--ref_dir ~/refdata \
	--install_dir $install_dir \
	--rundir ~/colo829_example
```

## Outputs

Outputs are located in subdirectories of `--output_dir` corresponding to each of the tools. Consult the tool documentation for details of the output file formats:

- GRIDSS: https://github.com/PapenfussLab/gridss
- PURPLE: https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator
- LINX: https://github.com/hartwigmedical/hmftools/tree/master/sv-linx

## Memory/CPU usage

Running it's default settings, the pipeline will use 25GB of memory and as many cores are available for the multi-threaded stages (such as GRIDSS assembly and variant calling). These can be overridden using the `--jvmheap` and `--threads` argumennts. A minimum of 14GB of memory is required and at least 3GB per core should be allocated. Recommended settings are 8 threads and 25gb heap size (actual memory usage will be slightly higher than heap size).

# FAQ

## My BAM were aligned to a different reference. What should I do?

If your reference genome does not match exactly, then GRIDSS will fail with an error.
If your reference genomes is just a different version of hg19, then you'll need to make the reference in the BAM and the `ref_data` match. To correct this, you can do one of the following:

- Realign your reads to the reference genome supplied with the reference data  OR
- Use a different reference genome using the `--reference` parameter
  - *WARNING*: bed, bedpe, and csv will need to be converted to use a `chr` if your reference uses a `chr` prefix
