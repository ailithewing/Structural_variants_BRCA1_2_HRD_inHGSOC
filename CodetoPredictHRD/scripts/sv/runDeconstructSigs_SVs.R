project="SHGSOC"
subproject="all"

library(deconstructSigs)
library(dplyr)

runDeconstruct_SVs<-function(sigs,counts){
    
    input<-read.table(counts,header=T,row.names=1)
    decon_input<-data.frame(t(input))
    col_order<-c("clustered.DEL.1.10kb","clustered.DEL.10.100kb","clustered.DEL.100kb.1Mb","clustered.DEL.1Mb.10Mb","clustered.DEL..10Mb",
"clustered.DUP.1.10kb","clustered.DUP.10.100kb","clustered.DUP.100kb.1Mb","clustered.DUP.1Mb.10Mb","clustered.DUP..10Mb",
"clustered.INV.1.10kb","clustered.INV.10.100kb","clustered.INV.100kb.1Mb","clustered.INV.1Mb.10Mb","clustered.INV..10Mb","clustered.TRA.",
"non.clustered.DEL.1.10kb","non.clustered.DEL.10.100kb","non.clustered.DEL.100kb.1Mb","non.clustered.DEL.1Mb.10Mb","non.clustered.DEL..10Mb",
"non.clustered.DUP.1.10kb","non.clustered.DUP.10.100kb","non.clustered.DUP.100kb.1Mb","non.clustered.DUP.1Mb.10Mb","non.clustered.DUP..10Mb",
"non.clustered.INV.1.10kb","non.clustered.INV.10.100kb","non.clustered.INV.100kb.1Mb","non.clustered.INV.1Mb.10Mb","non.clustered.INV..10Mb","non.clustered.TRA.")
           
    decon_input<-decon_input[,col_order]    

    rearrange_sigs<-read.csv(sigs)
    rownames(rearrange_sigs)<-as.character(rearrange_sigs[,1])
    rearrange_sigs<-t(rearrange_sigs[,-1])
    rearrange_sigs<-data.frame(rearrange_sigs)
	
    colnames(decon_input)<-colnames(rearrange_sigs)	

    mutation_counts<-rowSums(decon_input)
    allcountsbysig<-data.frame()
    allweights<-data.frame()
    
    for (i in 1:dim(decon_input)[1]){
        decomp<- whichSignatures(tumor.ref = decon_input, signatures.ref = rearrange_sigs,contexts.needed=TRUE,sample.id=rownames(decon_input)[i])
    
        weights<-decomp$weights
        countsbysig<-weights*mutation_counts[i]
    
        allweights<-rbind(allweights,weights)
        allcountsbysig<-rbind(allcountsbysig,countsbysig)
    }
    rownames(allweights)<-rownames(decon_input)
    rownames(allcountsbysig)<-rownames(decon_input)
    
    out<-list(weights=allweights,countsbysig=allcountsbysig)
    return(out)
}

#counts<-"/Volumes/igmm/HGS-OvarianCancerA-SGP-WGS/signatures/SVs/SVsigs/HGSOC-A-43-3Apr-SV_contexts_counts.txt"
#sigs<-"/Volumes/igmm/HGS-OvarianCancerA-SGP-WGS/signatures/External_resources/Nik_Zainal_rearrangement_sigs.csv"

