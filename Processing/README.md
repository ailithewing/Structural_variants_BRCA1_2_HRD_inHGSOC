# Processing samples

The file config.sh referred to as a parameter for the job submission scripts below was used to keep a consistent directory structure for the project, and to document paths to resources and some specific software. The version in this repository has been stripped of some identifying folder structure, but has kept the resource version information for reference.

## Alignment

Using [bcbio 1.0.7](https://bcbio-nextgen.readthedocs.io/en/latest/): [configuration template](align.yaml).

Preparing parameter files

1. Ensure all the reads for the samples have been renamed to the consistent id scheme and are in the folder reads/lane.
2. Create the file <batch>_ids.txt where <batch> is the date in yyyymmdd format. This file should contain one patient id per line.
3. Run the bcbio sample preparation script, where N is the number of patients in the batch.

```
qsub -t 1-<N> bcbio_prepare_alignment.sh config.sh <batch>_ids.txt <batch> <cohort>
```

Align the normal and tumour samples separately. The HPC used for this project would not allow bcbio to submit jobs directly - to work around this, we split the samples into separate config files and ran as job arrays.

```	
qsub -t 1-<N> bcbio_alignment.sh config.sh <batch>_ids.txt N
qsub -t 1-<N> bcbio_alignment.sh config.sh <batch>_ids.txt T
```
	    
Some alignment jobs choke on the BQSR step (a known issue with GATK Spark at the time). The process could be recovered via the bqsr_standalone.sh script for the sample(s) in question, followed by re-submitting the bcbio alignment job once the BQSR step has successfully completed. Bcbio is (usually) smart enough to pick up from there.

```
qsub -t <X> bqsr_standalone.sh config.sh <batch>_ids.txt <type>
qsub -t <X> bcbio_alignment.sh config.sh <batch>_ids.txt <type>
```
		
## Variant calling

Using [bcbio 1.0.7](https://bcbio-nextgen.readthedocs.io/en/latest/): [configuration template](variant.yaml).

Run the bcbio parameter preparation script using the <batch>.ids.txt file prepared for the alignment step.

```
for ((i = 1; i <= <N>; i = i + 1))
do
  bcbio_prepare_variant_calling.sh config.sh <batch>_ids.sh <date> <cohort> $i
done
```

Note: for the AOCS samples, use a [modified script](bcbio_prepare_variant_calling_AOCS.sh) to handle different id naming.

Submit the variant calling jobs.

```
qsub -t 1-<N> bcbio_variant.sh config.sh <batch>_ids.txt
```
 
### Filtering ensemble somatic variant calls for OxoG artifacts

Filtered variants are in the file variants/bcbio/$id/date_batch/$id-ensemble-annotated-oxog_filtered.vcf.gz, and filtering metrics are in the file metrics/$id-ensemble-annotated-oxog_filtered.vcf.gz.summary along with the output of the CollectSequencingArtifactMetrics tool called by submit_sequencing_artifact_metrics.sh.

```
qsub -t 1-N sequencing_artifact_metrics.sh config.sh <batch>_ids.txt T
qsub -t 1-N sequencing_artifact_metrics.sh config.sh <batch>_ids.txt N
qsub -t 1-N filter_by_orientation_bias.sh config.sh <batch>_ids.txt
```

Note: for the AOCS samples, use the script versions with suffix _AOCS.

## Checking for sample mix-ups

Bcbio uses Qsignature to generate VCFs of common SNPs for all samples, and the program can be used to check all these VCFs for sample mix-ups and to ensure that tumour-normal pairs are in fact from the same individual.

```
date=20180913
cd variants/bcbio
rsync `find . | grep qsig.vcf` ../../qc/qsignature/sample/
cd ../../qc/qsignature
java -Xmx4g -cp $BASE/software/qsignature/qsignature-0.1pre.jar org.qcmg.sig.SignatureCompareRelatedSimple -o $date.xml -log $date.log -d sample
perl $SCRIPTS/parse_qsig_compare_xml.pl < $date.xml > $date.txt
perl $SCRIPTS/best_match_per_qsig_file.pl < $date.txt | sort -u > $date.best_match_by_pair_id.txt
```

When samples are properly paired, the $date.best_match_by_pair.txt file will have 'match' in the 4th column (sample1, sample2, score, classification).
