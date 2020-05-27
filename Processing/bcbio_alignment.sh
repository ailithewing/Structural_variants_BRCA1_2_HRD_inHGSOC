#!/bin/bash

#
# qsub -t 1-n bcbio_alignment.sh CONFIG IDS TYPE
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# TYPE is T for tumor, N for normal
#
#$ -N bcbio_alignment
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 16
#$ -l h_rt=192:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
TYPE=$3

ulimit -n 8192

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}

WORK_DIR=$BCBIO_WORK/$SAMPLE_ID
UPLOAD_DIR=$ALIGNMENTS/$SAMPLE_ID
CONFIG_FILE=$BCBIO_CONFIG/${SAMPLE_ID}_alignment.yaml

mkdir -p $WORK_DIR $UPLOAD_DIR
cd $WORK_DIR

bcbio_nextgen.py $CONFIG_FILE -n $NSLOTS -t local
