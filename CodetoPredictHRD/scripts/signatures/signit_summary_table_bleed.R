' signit_summary_table.R

Extracts data from serialized SignIT output file into a tabular format.
After running signit_exposures.R, you will obtain a .Rds file.
This script reads tabular output from that Rds file.

Usage: signit_summary_table.R -i INPUT -o OUTPUT [ -s SIGNIT --fraction ]

Options:
    -i --input INPUT            Path to serialized output from SignIT (.Rds file)

    -o --output OUTPUT          Path to output summary stats table (.tsv file)

    -s --signit SIGNIT          Path to SignIT R library files. If not provided, will assume that SignIT is installed
                                and load the package using library(signit) instead.

    --fraction                  If using this flag, summary table will report all values as exposure fractions instead
                                of number of mutations.

Examples:
    To get mutation catalogs:
    Rscript signatures/get_mutation_catalog.R -v somatic_variants.vcf -c mutation_catalog.tsv

    To compute signatures:
    Rscript signatures/signit_exposures.R -c mutation_catalog.tsv -o signit_output.Rds

    To extract tabular results:
    Rscript signatures/signit_summary_table.R -i signit_output.Rds -o signit_results.tsv
' -> doc

library(docopt)
args <- docopt(doc)

if (is.null(args[['signit']])) {
    library(signit,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
} else {
    library(devtools,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(tidyverse,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(rjags,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(nnls,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(dbscan,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(Rtsne,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
    library(supraHex,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
		
    load_all(args[['signit']])
}

message('Reading SignIT data')

exposures <- readRDS(args[['input']])

# Impose bleeding filter - threshold from vignette
collapsed<-collapse_signatures_by_bleed(exposures,bleed_threshold=0.4)

summary_table2 <- get_exposure_summary_table(collapsed, alpha = c(0, 0.05, 0.5))
collapsed_out<-as.data.frame(summary_table2)

summary_table2_frac <- get_exposure_summary_table(collapsed, alpha = c(0, 0.05, 0.5),fraction=TRUE)
collapsed_out_frac<-as.data.frame(summary_table2_frac)

sigs<-as.data.frame(collapsed$reference_signatures)

# Compare new sigs to original sigs
refsigs<-read.table('/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/reference_sigs.tsv',sep="\t",header=T)
merged_sig<-sigs[,setdiff(colnames(sigs),colnames(refsigs))]

if (is.null(dim(merged_sig))){
	
	allres<- numeric()
	for (i in 2:dim(refsigs)[2]-1){	
        	count.mat<-t(cbind(refsigs[,i],merged_sig))
        	sim<-sDistance(count.mat, metric = "cos")
        	allres[i-1]<- 1-sim[1,2]       
	}
}else{

	if (dim(merged_sig)[2]>1){
		allres<- mat.or.vec(dim(merged_sig)[2],30)
        	for (i in 2:dim(refsigs)[2]-1){
			for (j in 1:dim(merged_sig)[2]){

	                count.mat<-t(cbind(refsigs[,i],merged_sig[,j]))
	                sim<-sDistance(count.mat, metric = "cos")
	                allres[j,i-1]<- 1-sim[1,2]
        	}
	}
}
}
rownames(collapsed_out)<-gsub("/",".",gsub(" ",".",as.character(collapsed_out[,1])))

#Rename new signature as most similar (cosine similarity) cosmic signature
if (is.null(dim(merged_sig))){
	collapsed_out[which(rownames(collapsed_out)==setdiff(colnames(sigs),colnames(refsigs))),1]<-paste("Signature ",which.max(allres),sep="")
}else{
	if (dim(merged_sig)[2]>1){
		collapsed_out[which(rownames(collapsed_out) %in% setdiff(colnames(sigs),colnames(refsigs))),1]<-paste("Signature ",apply(allres, 1, which.max),sep="")
	}
}

#Filter out signatures with less 0.06 contribution to fit (as per deconstructSigs)
collapsed_out[collapsed_out_frac<0.06]<-0
collapsed_out<-collapsed_out[,1:4]

if (("Signature 3" %in% as.character(collapsed_out[,1]))==FALSE){
	collapsed_out<-rbind(collapsed_out, data.frame(signature="Signature 3",mode_exposure=0, mean_exposure=0, median_exposure=0))
}
if (("Signature 8" %in% as.character(collapsed_out[,1]))==FALSE){
	collapsed_out<-rbind(collapsed_out, data.frame(signature="Signature 8",mode_exposure=0, mean_exposure=0, median_exposure=0))
}

write.table(collapsed_out,args[['output']],sep="\t",quote=F,row.names=F)

message('Created summary table.')

print(paste0('Results saved as TSV at ', args[['output']]))
