#!/bin/bash

# 
# qsub -t 1-n facets.sh <CONFIG> <IDS> <CVAL>
#
# CONFIG is a set of environment variables useful for all scripts in Cohort A
# IDS is the list of ids to run FACETS on
# CVAL is the segment change paramteter - higher values = longer segments, less sensitive
#
#$ -N facets
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=64G
#$ -l h_rt=24:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

module load igmm/apps/R/3.5.1

CONFIG=$1
IDS=$2
CVAL=$3

source $CONFIG

ID=`head -n $SGE_TASK_ID $IDS | tail -n 1 | awk '{ print $1 }'`

INPUT=$VARIANTS/facets/pileups
OUTPUT=$VARIANTS/facets/segments

Rscript --vanilla $SCRIPTS/facets.R -i $ID -f $INPUT/$ID-pileup.csv.gz -o $OUTPUT -c $CVAL
