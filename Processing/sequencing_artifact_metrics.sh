#!/bin/bash

#
# qsub -t 1-n sequencing_artifact_metrics.sh CONFIG IDS TYPE
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# TYPE T for tumor N for normal
#
#$ -N sequencing_artifact_metrics
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -l h_rt=24:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
TYPE=$3

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}
BAM_FILE=$ALIGNMENTS/$SAMPLE_ID/$SAMPLE_ID/$SAMPLE_ID-ready.bam

$GATK4 --java-options "-Xmx8g" CollectSequencingArtifactMetrics --INPUT $BAM_FILE -R $REFERENCE --OUTPUT $METRICS/${SAMPLE_ID}_artifact
