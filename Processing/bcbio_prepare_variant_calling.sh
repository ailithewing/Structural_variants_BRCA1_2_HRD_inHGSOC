#!/bin/bash

# To run this script, do 
# bcbio_prepare_variant_calling.sh CONFIG IDS DATE NAME INDEX
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# DATE is the batch date for the group of samples
# NAME is the batch name for the group of samples
# INDEX is the line number in IDS to process

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG_FILE=$1
IDS=$2
DATE=$3
NAME=$4
INDEX=$5

source $CONFIG_FILE

ID=`head -n $INDEX $IDS | tail -n 1`

# Create the prepare_samples.csv file
cd $BCBIO_CONFIG

echo "samplename,description,batch,phenotype,sex" > ${ID}_prepare_variants.csv
echo "$ALIGNMENTS/${ID}N/${ID}N/${ID}N-ready.bam,${ID}N,${ID},normal,female" >> ${ID}_prepare_variants.csv
echo "$ALIGNMENTS/${ID}T/${ID}T/${ID}T-ready.bam,${ID}T,${ID},tumor,female" >> ${ID}_prepare_variants.csv

# Create the YAML template
bcbio_nextgen.py -w template $BCBIO_VARIANT_TEMPLATE ${ID}_prepare_variants.csv $ALIGNMENTS/${ID}*/$ID*/$ID*-ready.bam

# Change the template file name, add the fc date and the upload directory
perl $SCRIPTS/edit_bcbio_variant_config.pl --fc_name $NAME --fc_date $DATE --upload $BCBIO_VARIANTS/$ID < ${ID}_prepare_variants/config/${ID}_prepare_variants.yaml > ${ID}_variant.yaml

# Clean up the intermediate directories
rm -r ${ID}_prepare_variants
