#!/bin/bash

project=$1
subproject=$2
input=$3
output=$4

awk '{out=$2; for (i=4;i<=NF;i+=2){out=out" "$i}; print out}' ${input} > output/${project}/${subproject}/hrdetect/agg_sv_catalog.tsv

ls -d output/${project}/${subproject}/patients/* > output/${project}/${subproject}/hrdetect/sampleIDs.txt

rm agg_sv_catalog_temp.tsv 

######################################

. /etc/profile.d/modules.sh
MODULEPATH=$MODULEPATH:/exports/igmm/software/etc/el7/modules

module load matlab/R2018a

matlab -r "run svCatalogtoMatlab.m ${project} ${subproject}; quit;"

#####################################

cd SigProfilerSingleSample

matlab -r "run SigProfilerSingleSample_SV.m; quit;"

cd ..

#########################################

matlab -r "run svExposuresMatlabtoHRDetect.m ${project} ${subproject}; quit;"

########################################


awk -F ',' '{out=$3"\t"$5; print out}' output/${project}/${subproject}/hrdetect/sv_sigprofiler_exposures.txt |awk  '$1!="E_3"' > output/${project}/${subproject}/hrdetect/sv_hrd_exposures.txt

ls output/${project}/${subproject}/patients/*/*/sv_signatures/sv_catalog.tsv > output/${project}/${subproject}/hrdetect/sv_paths

paste output/${project}/${subproject}/hrdetect/snv_paths output/${project}/${subproject}/hrdetect/sv_hrd_exposures.txt > output/${project}/${subproject}/hrdetect/temp
cat output/${project}/${subproject}/hrdetect/agg_snv_header output/${project}/${subproject}/hrdetect/temp > ${output}

rm output/${project}/${subproject}/hrdetect/snv_paths output/${project}/${subproject}/hrdetect/temp 
