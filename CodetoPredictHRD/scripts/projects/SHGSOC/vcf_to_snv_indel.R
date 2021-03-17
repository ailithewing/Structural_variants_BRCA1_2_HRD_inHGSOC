' vcf_to_snv_indel.R

Splits a VCF file into separate SNVs and Indel VCF files.

Usage: vcf_to_snv_indel.R -v VCF -i INDEL

Options:
    -v --vcf VCF        Path to input VCF file
    -i --indel INDEL    Path to output Indel VCF file
' -> doc

library(docopt)
args <- docopt(doc)

library(VariantAnnotation)
library(tidyverse)

vcf <- readVcf(args[['vcf']])

writeVcf(vcf, args[['indel']])
