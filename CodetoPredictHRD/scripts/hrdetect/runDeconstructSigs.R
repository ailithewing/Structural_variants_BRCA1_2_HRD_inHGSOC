#DeconstructSigs
project="SHGSOC"
subproject="all"

#SNVs
library(deconstructSigs)
source("scripts/signatures/runDeconstructSigs.R")
deconstructSigs_cosmic<-runDeconstruct(sigs="signatures.cosmic",counts=paste('output/',project,'/',subproject,'/hrdetect/agg_snv_catalog.tsv',sep=""),sigcolnames=NULL)
countsigs<-deconstructSigs_cosmic$countsbysig
samples<-read.table(paste('output/',project,'/',subproject,'/hrdetect/sampleIDs.txt',sep=""),sep="\t",stringsAsFactors=F)
samples<-samples[,1]
rownames(countsigs)<-samples
write.table(countsigs,file=paste('output/',project,'/',subproject,'/hrdetect/SNV_signatures_counts.txt',sep=""),sep="\t",quote=F)

#SVs
source("scripts/sv/runDeconstructSigs_SVs.R")
deconstructSigs_SVs<-runDeconstruct_SVs(sigs="params/Nik_Zainal_rearrangement_sigs.csv",counts=paste('output/',project,'/',subproject,'/hrdetect/agg_sv_catalog.tsv',sep=""))
countSVsigs<-deconstructSigs_SVs$countsbysig
samples<-read.table(paste('output/',project,'/',subproject,'/hrdetect/sampleIDs.txt',sep=""),sep="\t",stringsAsFactors=F)
samples<-samples[,1]
rownames(countSVsigs)<-samples
write.table(countSVsigs,file=paste('output/',project,'/',subproject,'/hrdetect/SV_signatures_counts.txt',sep=""),sep="\t",quote=F)

#---------------------------------------------------------------------------------------------------------------------------------------------
snv_sigs<-read.table(paste('output/',project,'/',subproject,'/hrdetect/SNV_signatures_counts.txt',sep=""),sep="\t",row.names=1,header=T)

sv_sigs<-read.table(paste('output/',project,'/',subproject,'/hrdetect/SV_signatures_counts.txt',sep=""),sep="\t",row.names=1,header=T)

indel<-read.table(paste('output/',project,'/',subproject,'/hrdetect/microhomology_scores_aggregated.tsv',sep=""),sep="\t",header=T)
rownames(indel)<-sapply(strsplit(as.character(indel[,1]),"/"),function(x) x[[5]])
indel$Sample<-rownames(indel)

hrd<-read.table(paste('output/',project,'/',subproject,'/hrdetect/hrd_scores_aggregated.tsv',sep=""),sep="\t",header=T)
rownames(hrd)<-sapply(strsplit(as.character(hrd[,1]),"/"),function(x) x[[5]])
hrd$Sample<-rownames(hrd)
hrd$hrd_mean<-NA
for (i in 1:dim(hrd)[1]){
    hrd$hrd_mean[i]<-mean(c(hrd$loh[i],hrd$tai[i],hrd$lst[i]),na.rm=T)
}       

dat<-merge(snv_sigs[,c("Signature.3","Signature.8")],sv_sigs[,c("Re_sig3","Re_sig5")],by=0)
rownames(dat)<-as.character(dat[,1])
colnames(dat)[1]<-"Sample"

dat1<-merge(dat,indel[,c("Sample","deletion_microhomology_proportion")],by="Sample")
rownames(dat1)<-as.character(dat1[,1])

dat2<-merge(dat1,hrd[,c("Sample","hrd_mean")],by="Sample")
rownames(dat2)<-as.character(dat2[,1])      

         brca_means<-list(Re_sig3=1.260,Re_sig5=1.935, Signature.3=2.096, Signature.8=4.390, hrd_mean=2.195,deletion_microhomology_proportion=0.218)
brca_sd<-list(Re_sig3=1.657,Re_sig5=1.483, Signature.3=3.555, Signature.8=3.179, hrd_mean=0.750,deletion_microhomology_proportion=0.090)

vars<-colnames(dat2)[-1]
for (i in vars){
    a<-log(dat2[,i]+1)
    a2<-(a-brca_means[[i]])/brca_sd[[i]]
    dat2[,paste("norm_",i,sep="")]<-a2
}

         lp<- -(-3.364 + (1.611*dat2$norm_Signature.3) + (0.091*dat2$norm_Signature.8) + (1.153*dat2$norm_Re_sig3) + (0.847*dat2$norm_Re_sig5) + 
       (2.398*dat2$norm_deletion_microhomology_proportion)+(0.667*dat2$norm_hrd_mean))
dat2$HRDetect<-1/(1+exp(lp))

write.table(dat2,file=paste('output/',project,'/',subproject,'/hrdetect/HRDetect_results.txt',sep=""),sep="\t",quote=F)
