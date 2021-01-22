args <- commandArgs(trailingOnly=TRUE)

library(stringr)

sample<-as.character(args[1])
print(sample)

dat<-read.table(paste(sample,"-SV-type-filtered.INFO",sep=""),sep="\t",header=T,stringsAsFactors=F)

onetwo<-dat[,1:2]
colnames(onetwo)<-c("chr1","pos1")

trarows<-which(dat$SVTYPE=="BND")

threefour<-dat[,c(1,6)]
colnames(threefour)<-c("chr2","pos2")

trans<-dat[dat$SVTYPE=="BND",]
p2<-tolower(str_extract(trans$ALT, "CHR[0-9]*[XY]*:[0-9]*"))
chr_sec<-sapply(strsplit(p2,":"),function(x) x[1])
pos_sec<-sapply(strsplit(p2,":"),function(x) x[2])
threefour_tra<-data.frame(chr2=chr_sec,pos2=pos_sec)

threefour[trarows,"chr2"]<-as.character(threefour_tra[,1])
threefour[trarows,"pos2"]<-as.character(threefour_tra[,2])

alldat<-data.frame(onetwo,threefour,type=dat$SVTYPE)
alldat$type<-as.character(alldat$type)
alldat[alldat$type=="BND","type"]<-"TRA"

write.table(alldat,file="somatic_sv.tsv",sep="\t",row.names=F,quote=F)


