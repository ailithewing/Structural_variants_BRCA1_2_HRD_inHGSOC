#!/bin/bash

project=$1
subproject=$2
input=$3
output=$4

echo $project




awk '{out=$2; for (i=4;i<=NF;i+=2){out=out" "$i}; print out}' ${input} > output/${project}/${subproject}/hrdetect/agg_snv_catalog.tsv

ls -d output/${project}/${subproject}/patients/* > output/${project}/${subproject}/hrdetect/sampleIDs.txt

rm agg_snv_catalog_temp.tsv 

######################################

. /etc/profile.d/modules.sh
MODULEPATH=$MODULEPATH:/exports/igmm/software/etc/el7/modules

module load matlab/R2018a

matlab -r "run snvCatalogtoMatlab.m ${project} ${subproject}; quit;"

#####################################

cd SigProfilerSingleSample

matlab -r "run SigProfilerSingleSample_AOCS.m; quit;"

cd ..

#########################################

matlab -r "run snvExposuresMatlabtoHRDetect.m ${project} ${subproject}; quit;"

########################################


awk -F ',' '{out=$3"\t"$8; print out}' output/${project}/${subproject}/hrdetect/snv_sigprofiler_exposures.txt |awk  '$1!="E_3"' > output/${project}/${subproject}/hrdetect/snv_hrd_exposures.txt

ls output/${project}/${subproject}/patients/*/*/snv_signatures/mutation_catalog.tsv > output/${project}/${subproject}/hrdetect/snv_paths

paste output/${project}/${subproject}/hrdetect/snv_paths output/${project}/${subproject}/hrdetect/snv_hrd_exposures.txt > output/${project}/${subproject}/hrdetect/temp
cat output/${project}/${subproject}/hrdetect/agg_snv_header output/${project}/${subproject}/hrdetect/temp > ${output}

rm output/${project}/${subproject}/hrdetect/snv_paths output/${project}/${subproject}/hrdetect/temp 
