#!/bin/bash

#
# qsub -t 1-n bqsr_standalone.sh CONFIG IDS TYPE
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script
# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.
# TYPE is T for tumor, N for normal
#
#$ -N bqsr_standalone
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=32G
#$ -l h_rt=192:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

module load igmm/libs/htslib/1.6
module load igmm/apps/samtools/1.6

CONFIG=$1
IDS=$2
TYPE=$3

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}

WORK_DIR=$BCBIO_WORK/$SAMPLE_ID
ALIGN_DIR=$WORK_DIR/align/$SAMPLE_ID

JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR/bcbiotx"

cd $ALIGN_DIR

if [ ! -f $SAMPLE_ID-sort-recal.grp ]
then
  java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR BaseRecalibrator \
    -I $SAMPLE_ID-sort.bam \
    --output $SAMPLE_ID-sort-recal.grp \
    --reference $REFERENCE \
    --knownSites $KNOWN_SITES \
    -L $WORK_DIR/bedprep/$SAMPLE_ID-variant_regions.quantized-vrsubset-callableblocks.bed \
    --interval_set_rule INTERSECTION
fi

if [ ! -f $SAMPLE_ID-sort-recal.bam ]
then
  java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR ApplyBQSR \
    --input $SAMPLE_ID-sort.bam \
    --output $SAMPLE_ID-sort-recal.bam \
    --bqsr_recal_file $SAMPLE_ID-sort-recal.grp \
    -jdk_deflater -jdk_inflater
fi

samtools index $SAMPLE_ID-sort-recal.bam
