#!/bin/bash

#
# qsub -t 1-n bcbio_prepare_alignment.sh CONFIG IDS DATE BATCH
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# DATE is the batch date for the group of samples
# BATCH is the batch name, e.g. SHGSOC, TCGA_US_OV, AOCS
#
#$ -N bcbio_prepare_samples
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -l h_rt=12:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG_FILE=$1
IDS=$2
DATE=$3
BATCH_NAME=$4

source $CONFIG_FILE

ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

# Create the prepare_samples.csv file
cd $BCBIO_CONFIG

echo "samplename,description,phenotype,sex" > ${ID}_prepare_samples.csv
for file in `ls $READS/lane/${ID}N*.gz`
do
  echo "$file,${ID}N,normal,female" >> ${ID}_prepare_samples.csv
done
for file in `ls $READS/lane/${ID}T*.gz`
do
  echo "$file,${ID}T,tumor,female" >> ${ID}_prepare_samples.csv
done

# Group the FASTQ files by sample
bcbio_prepare_samples.py --out $READS --csv ${ID}_prepare_samples.csv

# Create the YAML template
bcbio_nextgen.py -w template $BCBIO_ALIGNMENT_TEMPLATE ${ID}_prepare_samples-merged.csv $READS/$ID*.fastq.gz

# Split the configuration YAML file by sample
perl $SCRIPTS/split_bcbio_config_by_sample.pl --input ${ID}_prepare_samples-merged/config/${ID}_prepare_samples-merged.yaml --output . --upload $ALIGNMENTS --type alignment --fc_date $DATE --fc_name $BATCH_NAME

# Clean up the intermediate files
rm -r ${ID}_prepare_samples-merged
