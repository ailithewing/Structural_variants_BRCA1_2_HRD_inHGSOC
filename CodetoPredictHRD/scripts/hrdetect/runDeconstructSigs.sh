project=$1
subproject=$2

ls output/${project}/${subproject}/patients/*/*/snv_signatures/*catalog* > output/${project}/${subproject}/hrdetect/snv_signatures_mutpaths.tsv

ls output/${project}/${subproject}/patients/*/*/sv_signatures/*catalog* > output/${project}/${subproject}/hrdetect/sv_signatures_mutpaths.tsv

paste `cat output/${project}/${subproject}/hrdetect/snv_signatures_mutpaths.tsv` > output/${project}/${subproject}/hrdetect/snv_signatures_agg_catalog_temp.tsv

paste `cat output/${project}/${subproject}/hrdetect/sv_signatures_mutpaths.tsv` > output/${project}/${subproject}/hrdetect/sv_signatures_agg_catalog_temp.tsv

awk '{out=$2; for (i=4;i<=NF;i+=2){out=out" "$i}; print $1,out}' output/${project}/${subproject}/hrdetect/snv_signatures_agg_catalog_temp.tsv > output/${project}/${subproject}/hrdetect/agg_snv_catalog.tsv

awk '{out=$2; for (i=4;i<=NF;i+=2){out=out" "$i}; print $1,out}' output/${project}/${subproject}/hrdetect/sv_signatures_agg_catalog_temp.tsv > output/${project}/${subproject}/hrdetect/agg_sv_catalog.tsv

ls -d output/${project}/${subproject}/patients/* |cut -f 5 -d '/'  > output/${project}/${subproject}/hrdetect/sampleIDs.txt

rm output/${project}/${subproject}/hrdetect/snv_signatures_agg_catalog_temp.tsv output/${project}/${subproject}/hrdetect/sv_signatures_agg_catalog_temp.tsv 

Rscript --no-save scripts/hrdetect/runDeconstructSigs.R 
