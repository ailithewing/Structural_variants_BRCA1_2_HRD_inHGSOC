#Run deconstructSigs
#Input: sigs, counts


library("deconstructSigs",lib.loc="/Volumes/igmm/HGS-OvarianCancerA-SGP-WGS/signatures/software/")
library(dplyr)
runDeconstruct<-function(sigs,counts,sigcolnames){
	
	input<-read.table(counts,header=T,row.names=1)
	decon_input<-data.frame(t(input))
	colnames(decon_input)<-as.character(rownames(input))
	#colnames(decon_input)<-c(paste(substr(colnames(decon_input),4,4),"[",substr(colnames(decon_input),1,1),">",substr(colnames(decon_input),2,2),"]",substr(colnames(decon_input),6,6),sep=""))
 	
 	mutation_counts<-rowSums(decon_input)
 	
    if (sigs!="signatures.cosmic"){
	sigs<-read.csv(sigs)
	contexts<-as.character(colnames(decon_input))
	rownames(sigs)<-contexts
	colnames(sigs)<-sigcolnames
	t.sigs<-as.data.frame(t(sigs))
    }else{
        t.sigs<-signatures.cosmic
        sigcolnames<-rownames(signatures.cosmic)
    }
	allcountsbysig<-data.frame()
	allweights<-data.frame()
	
	for (i in 1:dim(decon_input)[1]){
		
    	decomp<- whichSignatures(tumor.ref = decon_input, signatures.ref=t.sigs,contexts.needed=TRUE,sample.id=rownames(decon_input)[i])
    	
    	weights<-decomp$weights
    	countsbysig<-weights*mutation_counts[i]
    
    	allweights<-bind_rows(allweights,weights)
    	allcountsbysig<-bind_rows(allcountsbysig,countsbysig)
	}
	rownames(allweights)<-rownames(decon_input)
	rownames(allcountsbysig)<-rownames(decon_input)
	
	out<-list(weights=allweights,countsbysig=allcountsbysig)
	return(out)
}
#deconstructSigs_AF<-runDeconstruct(sigs="SigsbyContext_full.txt",counts="HGSOC-SNVs_trinuc_counts_filtAF0.1.txt",sigcolnames=c("MuSig1","MuSig2"))


