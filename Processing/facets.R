library(optparse)
library(facets)
library(data.table)

source(system.file("extRfns", "readSnpMatrixDT.R", package="facets"))

option_list = list(
  make_option(c("-i", "--id"), type="character", help="Sample id"),
  make_option(c("-f", "--file"), type="character", help="Input pileup.csv.gz file"),
  make_option(c("-o", "--out"), type="character", help="Output directory"),
  make_option(c("-c", "--cval"), type="numeric", help="cval parameter for procSample"))

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

if (is.null(opt$file) | is.null(opt$id) | is.null(opt$out) | is.null(opt$cval))
{
  print_help(opt_parser)
  stop()
}

# Open a log file
log_file_name = paste(opt$out, "/", opt$id, ".facets.log", sep="") 
log = file(log_file_name)
cat(paste(Sys.time(), " Starting FACETS\n", sep=""), file = log)

log_text <- function(text) {
  cat(paste(Sys.time(), " ", text, "\n", sep=""), file = log_file_name, append = TRUE)
}

# Read in the SNPs
log_text(paste("Reading file", opt$file))
rcmat = readSnpMatrixDT(opt$file)
log_text(paste("Read", length(rcmat$Chromosome), "entries in SNP matrix"))

# Set the random seed for FACETS
seed=sample(1:10000, 1)
set.seed(seed)
log_text(paste("Random seed:", seed))

# Pre-process the sample
log_text("Pre-processing the SNP matrix")
xx = preProcSample(rcmat, gbuild="hg38", ndepth=25)
log_text(paste(length(xx$pmat$chrom), " SNPs selected"))

# Process the sample
log_text(paste("Processing the sample with cval", opt$cval))
oo = procSample(xx, cval=opt$cval)
log_text(paste("LogR for the 2-copy state:", oo$dipLogR))
log_text(paste("Identified", length(oo$jointseg$chrom), "joint segments"))

# Output any warning flags
for (i in seq(length(oo$flags))) {
  log_text(paste("Warning:", oo$flags[i]))
}

# Fit the copy number states
log_text("Fitting copy number")
fit = emcncf(oo)
log_text(paste("Log-likelihood:", fit$loglik))
log_text(paste("Purity:", fit$purity))
log_text(paste("Ploidy:", fit$ploidy))
log_text(paste("Identified", length(fit$seglen), "segments"))

# Output the copy number matrix
out_file = paste(opt$out, "/", opt$id, ".facets.cn.tsv", sep="")
write.table(fit$cncf, out_file, col.names=T, row.names=F, quote=F, sep="\t")
log_text(paste("Output copy number segments to", out_file))

# Plot the copy segments
sample_plot = paste(opt$out, "/", opt$id, ".facets.sampleplot.pdf", sep="")
pdf(sample_plot, width=6, height=6)
plotSample(x=oo, emfit=fit, sname=opt$id)
dev.off()
log_text(paste("Copy segments plot", sample_plot))

# Plot the diagnostic fit plot
fit_plot = paste(opt$out, "/", opt$id, ".facets.fitplot.pdf", sep="")
pdf(fit_plot, width=6, height=6)
logRlogORspider(oo$out, oo$dipLogR)
dev.off()
log_text(paste("Fit plot", fit_plot))

# Calculate the proportion of the autosomal genome with MCN >= 2
x = subset(fit$cncf, fit$cncf$chrom != 23)
x$length = x$end - x$start + 1

# Major allele copy number is total minus minor allele copy number
x$mcn.em = x$tcn.em - x$lcn.em 

# Split the segments by major allele copy number < 2 (or undetermined) or >= 2
x$mcn_split = 0 
x$mcn_split[x$mcn.em >= 2] = 1

# Calculate length fraction
y = aggregate(x$length, by = list(x$mcn_split), sum)
mcn_frac = y$x[2] / sum(x$length) # if this is >= 50%, then call the tumour WGD
log_text(paste("Fraction of autosomal genome with MCN >= 2:", sprintf("%0.3f", mcn_frac)))
log_text(paste("Length of autosomal genome with MCN >= 2:", y$x[2]))
log_text(paste("Total length of autosomal genome:", sum(x$length)))

# Call it a binary YES/NO
if (mcn_frac >= 0.5) {
  log_text("Evidence for whole genome duplication: YES")
} else {
  log_text("Evidence for whole genome duplication: NO")
}
