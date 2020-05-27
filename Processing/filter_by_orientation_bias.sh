#!/bin/bash

#
# qsub -t 1-n filter_by_orientation_bias.sh CONFIG IDS
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
#
#$ -N filter_by_orientation_bias_oxog
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=32G
#$ -l h_rt=24:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
INFILE=`ls $BCBIO_VARIANTS/$PATIENT_ID/*/$PATIENT_ID-ensemble-annotated.vcf.gz`
OUTFILE=${INFILE%.vcf.gz}-oxog_filtered.vcf.gz
METRICS_FILE=$METRICS/${PATIENT_ID}T_artifact.pre_adapter_detail_metrics

$GATK4 --java-options "-Xmx16g" FilterByOrientationBias \
  --variant $INFILE \
  --artifact-modes 'G/T' \
  --pre-adapter-detail-file $METRICS_FILE \
  --output $OUTFILE

mv $OUTFILE.summary $METRICS/
