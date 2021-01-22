#!/bin/bash

#
# qsub -t 1-n bcbio_variant.sh CONFIG IDS
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line
#
#$ -N bcbio_variant
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -l h_rt=96:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

WORK_DIR=$BCBIO_WORK/$PATIENT_ID
UPLOAD_DIR=$BCBIO_VARIANTS/$PATIENT_ID
CONFIG_FILE=$BCBIO_CONFIG/${PATIENT_ID}_variant.yaml

mkdir -p $WORK_DIR $UPLOAD_DIR
cd $WORK_DIR

bcbio_nextgen.py $CONFIG_FILE -n $NSLOTS -t local
