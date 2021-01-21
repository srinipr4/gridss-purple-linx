
# GRIDSS PURPLE LINX

The GRIDSS/PURPLE/LINX toolkit takes a pair of match tumour/normal BAM files, and performs somatic genomic rearrangement detection and classificatiion.

- [GRIDSS](https://github.com/PapenfussLab/gridss): performs structural variant calling
- [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator): performs allele specific copy number calling
- [LINX](https://github.com/hartwigmedical/hmftools/tree/master/sv-linx): performs event classification, and visualisation

The simplest way to run the toolkit is via the docker image.

## Reference data

The toolkit requires multiple reference data files and these have been packaged into a single file for HG37 and HG38.  These can be downloaded from the following locations:

|Reference Genome | Download Location |
|---|---|
|GRCh37|https://resources.hartwigmedicalfoundation.nl/ then navigate to HMFTools-Resources/GRIDSS-Purple-Linx-Docker/gpl_ref_data_hg37.gz|
|GRCh38|https://resources.hartwigmedicalfoundation.nl/ then navigate to HMFTools-Resources/GRIDSS-Purple-Linx-Docker/gpl_ref_data_hg38.gz|

## Download the docker image
The docker image can be downloaded from [dockerhub](https://hub.docker.com/r/gridss/gridss-purple-linx) with the `latest` tag.
For alternative versions, all tags can be found [here](https://hub.docker.com/r/gridss/gridss-purple-linx/tags).

```
# Download the latest version of the docker images
docker pull gridss/gridss-purple-linx:latest
```


## Running the Docker Image Pipeline
The docker images assumes the following:
- The reference data is mounted read/write in `/refdata`
- The input/output directory is mounted read/write in `/data`

Run docker image as follows:

```
docker run -v /path_to_ref_data/:/refdata \
	-v /path_to_sample_data/:/data/:Z \
	gridss/gridss-purple-linx:latest \
	-n /data/SAMPLE.sv.normal.bam \
	-t /data/SAMPLE.sv.tumor.bam \
	-s SAMPLE \
	--snvvcf /data/SAMPLE.somatic.vcf.gz \
	--ref_genome_version HG37 \
	--ulimit nofile=100000:100000
```

Providing a somatic point-mutation VCF can improve Purple's copy number fit for samples with low aneuploidy. This file must have the AD field populated. Otherwise use the argument `--nosnvvcf`.

The ulimit increase is due to GRIDSS multi-threading using many file handles.

### Optional arguments
|Argument|Description|Default|
|---|---|---|
|--output_dir|Output directory|/data/|
|--threads|Number of threads to use|number of cores available|
|--ref_genome_version|Either HG37 or HG38| HG37|
|--jvmheap|Maximum java heap size for high-memory steps|25g|

## Outputs
Outputs are located in subdirectories of `--output_dir` corresponding to each of the tools. Consult the tool documentation for details of the output file formats:
- GRIDSS: https://github.com/PapenfussLab/gridss
- PURPLE: https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator
- LINX: https://github.com/hartwigmedical/hmftools/tree/master/sv-linx

## Memory/CPU usage
Running it's default settings, the pipeline will use 25GB of memory and as many cores are available for the multi-threaded stages (such as GRIDSS assembly and variant calling). These can be overridden using the `--jvmheap` and `--threads` argumennts. A minimum of 14GB of memory is required and at least 3GB per core should be allocated. Recommended settings are 8 threads and 25gb heap size (actual memory usage will be slightly higher than heap size).

## Reference Genomes
If the BAMs have been aligned with a different ref genome than the one provided in the Hartwig reference data, then either:
- overwrite reference genome files in /ref_data/refgenomes/ OR
- realign the reads to the reference genome supplied with the reference genome files in /ref_data/refgenomes/

## Running the Pipeline Directly
As an alternative to running the pipeline via the docker image, the following script can be called directly to execute each component in turn:

```
install_dir=~/
GRIDSS_VERSION=2.9.4
COBALT_VERSION=1.11
PURPLE_VERSION=2.51
LINX_VERSION=1.12
export GRIDSS_JAR=$install_dir/gridss/gridss-${GRIDSS_VERSION}-gridss-jar-with-dependencies.jar
export AMBER_JAR=$install_dir/hmftools/amber-${AMBER_VERSION}-jar-with-dependencies.jar
export COBALT_JAR=$install_dir/hmftools/count-bam-lines-${COBALT_VERSION}-jar-with-dependencies.jar
export PURPLE_JAR=$install_dir/hmftools/purity-ploidy-estimator-${PURPLE_VERSION}-jar-with-dependencies.jar
export LINX_JAR=$install_dir/hmftools/sv-linx-${LINX_VERSION}-jar-with-dependencies.jar

$install_dir/gridss-purple-linx/gridss-purple-linx.sh \
	-n /path_to_sample_data/SAMPLE.sv.normal.bam \
	-t /path_to_sample_data/SAMPLE.sv.tumor.bam \
	-s SAMPLE \
	--snvvcf /path_to_sample_data/SAMPLE.somatic.vcf.gz \
	--ref_dir ~/refdata \
	--install_dir $install_dir \
	--rundir ~/colo829_example
```

For the list of packages and tools required for the pipeline, see Dockerfile (https://github.com/hartwigmedical/gridss-purple-linx/blob/master/Dockerfile).
