#!/usr/bin/bash

#
# Configuration file for common directory and file locations for scripts
#

BASE=<base_dir>
ALIGNMENTS=$BASE/alignments
BCBIO_CONFIG=$BASE/bcbio/config
BCBIO_WORK=$BASE/bcbio/work
BCBIO_ALIGNMENT_TEMPLATE=$BCBIO_CONFIG/templates/align.yaml
BCBIO_VARIANT_TEMPLATE=$BCBIO_CONFIG/templates/variant.yaml
PARAMS=$BASE/params
RAW_READS=$BASE/raw_reads
READS=$BASE/reads
SCRIPTS=$BASE/scripts
TARGETS=$BASE/targets
VARIANTS=$BASE/variants
BCBIO_VARIANTS=$BASE/variants/bcbio
BRASS_BASE=$BASE/variants/brass
QC=$BASE/qc
METRICS=$BASE/metrics

BCBIO_VERSION=1.0.7
export PATH=$BASE/software/bcbio-${BCBIO_VERSION}/tools/bin
GATK4=$BASE/software/gatk-4.0.2.1/gatk
GATK4_JAR=$BASE/software/bcbio-1.0.7/anaconda/share/gatk4-4.0b6-0/gatk-package-4.beta.6-local.jar
REFERENCE=$BASE/software/bcbio-1.0.7/genomes/Hsapiens/hg38/seq/hg38.fa
KNOWN_SITES=$BASE/software/bcbio-1.0.7/genomes/Hsapiens/hg38/variation/dbsnp-150.vcf.gz
CONTAMINATION_SITES=$BASE/targets/gnomad.genomes.r2.0.1.sites.hg38_crossmap.minAF_0.01.vcf.gz
MANTIS=$BASE/software/MANTIS-1.0.4/mantis.py
