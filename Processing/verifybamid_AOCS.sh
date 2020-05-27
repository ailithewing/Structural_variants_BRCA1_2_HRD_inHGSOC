#!/bin/bash

# 
# qsub -t 1-n verifybamid_AOCS.sh CONFIG IDS TYPE_PREFIX TYPE_SUFFIX
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# TYPE is T for tumor, N for normal
#
#$ -N verifybamid
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -l h_rt=72:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
TYPE_PREFIX=$3
TYPE_SUFFIX=$4

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}_${TYPE_SUFFIX}
BAM_FILE=$ALIGNMENTS/$TYPE_PREFIX-$PATIENT_ID.$TYPE_SUFFIX/$SAMPLE_ID/$SAMPLE_ID-ready.bam
CONT_DIR=$QC/verifybamid

verifyBamID --bam $BAM_FILE --vcf $CONTAMINATION_SITES --out $CONT_DIR/$SAMPLE_ID
