#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l h_rt=01:00:00
#$ -l h_vmem=4G
#$ -N prepare_HRDetect_input

. /etc/profile.d/modules.sh
MODULEPATH=$MODULEPATH:/exports/igmm/software/etc/el7/modules

module load igmm/apps/vcftools/0.1.13 
module load igmm/apps/R/3.5.1 
module load igmm/apps/bcftools/1.9

PARAMS=$1
SAMPLE=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | awk '{ print $1 }'`
SNV=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | awk '{ print $2 }'`
SV=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | awk '{ print $3 }'`
LOH=`head -n $SGE_TASK_ID $PARAMS | tail -n 1 | awk '{ print $4 }'`

echo $SAMPLE

mkdir $SAMPLE
cd $SAMPLE

bcftools filter -i 'INFO/AF>0.1 & FILTER="PASS"' ${SNV} > tmp.vcf   

vcftools --vcf tmp.vcf --remove-indels  --remove-filtered-all --recode --out somatic_snvs

vcftools --vcf tmp.vcf --keep-only-indels  --remove-filtered-all --recode --out somatic_indels

rm tmp.vcf

#segments.tsv comes from DFExtract.results and is made in preprocessing to hrdtools.
rsync -rv ${LOH} segments_dat.tsv
cat ../loh_header segments_dat.tsv > segments.tsv

#SVs
vcftools --gzvcf ${SV} --chr chr1 --chr chr2 --chr chr3 --chr chr4 --chr chr5 --chr chr6 --chr chr7 --chr chr8 --chr chr9 --chr chr10 --chr chr11 --chr chr12 --chr chr13 --chr chr14 --chr chr15 --chr chr16 --chr chr17 --chr chr18 --chr chr19 --chr chr20 --chr chr21 --chr chr22 --chr chrX --chr chrY --get-INFO SVTYPE --get-INFO END --remove-filtered-all --out ${SAMPLE}-SV-type-filtered

Rscript --no-save /exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/scripts/format_somatic_svs.R $SAMPLE 

rm ${SAMPLE}-SV-type-filtered.*
rm segments_dat.tsv


mv somatic_indels.recode.vcf ${SAMPLE}T.somatic_indels.vcf
mv somatic_snvs.recode.vcf ${SAMPLE}T.somatic_snvs.vcf
mv segments.tsv ${SAMPLE}T.segments.tsv
mv somatic_sv.tsv ${SAMPLE}T.somatic_sv.tsv

sed -i 's/chrx/chrX/g' ${SAMPLE}T.somatic_sv.tsv
