#!/bin/bash

# 
# qsub -t 1-n facets_snp_pileup.sh <CONFIG> <params.txt> <outdir>
#
# column 1 - sample id
# column 2 - path to normal BAM file
# column 3 - path to tumor BAM file
#
#$ -N snp_pileup
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=4G

unset MODULEPATH
. /etc/profile.d/modules.sh

module load igmm/compilers/gcc/5.5.0
module load igmm/libs/htslib/1.6

CONFIG=$1
PARAMS=$2
OUTDIR=$3

source $CONFIG

SNPS=$BASE/software/bcbio/1.0.7/genomes/Hsapiens/hg38/variation/1000G_phase1.snps.high_confidence.vcf.gz
SNP_PILEUP=$BASE/software/facets/inst/extcode/snp-pileup

ID=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | cut -f 1`
NORMAL_BAM=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | cut -f 2`
TUMOR_BAM=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | cut -f 3`

$SNP_PILEUP --gzip --pseudo-snps=100 --min-map-quality=30 --min-base-quality=30 --min-read-counts=10,0 $SNPS $OUTDIR/$ID-pileup.csv.gz $NORMAL_BAM $TUMOR_BAM
