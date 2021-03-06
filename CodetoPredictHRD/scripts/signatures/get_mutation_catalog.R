' get_mutation_catalog.R - Computes counts table of mutation types.

Determines mutation catalog using a 96 type classification, as defined by Alexandrov et al. (2013).
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3588146/.

Required input is variants in either VCF or MAF format.
For MAF format, the column names are
Chromosome: chromosome names, matching the reference genome chromosome names
Start_Position: numeric value indicating the starting position
Reference_Allele: reference allele base (T, C, A, or G)
Allele: somatic mutation allele (T, C, A, or G)

Usage: get_mutation_catalog.R ( -m MAF | -v VCF ) -c CATALOG [ -x -r REFERENCE ]

Options:
    -m MAF              SNV input in MAF format
    -v VCF              SNV input in VCF format
    -c CATALOG          Output path - mutation catalog
    -r REFERENCE       	Reference genome name. Either hg19 or GRCh38. Default is hg19.

Examples:
    Somatic variants in MAF format, using GRCh38 (example: for TCGA)
    Rscript signatures/get_mutation_catalog.R -m somatic_variants.maf -c mutation_catalog.tsv -r GRCh38

    Somatic variants in VCF format, using hg19
    Rscript signatures/get_mutation_catalog.R -v somatic_variants.vcf -c mutation_catalog.tsv
' -> doc

library(docopt)
args <- docopt(doc)
print(args)

library(tidyverse,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library/")
library(stringr,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library/")
library(BSgenome.Hsapiens.NCBI.GRCh38,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library/")

if (! is.null(args[['m']])) {
    mutations <- read_tsv(args[['m']], 
                          col_types = cols(Chromosome = col_character(),
                                           Start_Position = col_number(),
                                           Reference_Allele = col_character(),
                                           Allele = col_character())) %>%
        select(chr = Chromosome,
               pos = Start_Position,
               ref = Reference_Allele,
               alt = Allele,
               sample = Tumor_Sample_Barcode) %>%
        mutate(chr = gsub('chr', '', chr)) %>%
        as.data.frame
} else {
    library(VariantAnnotation,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library/")
    vcf <- readVcf(args[['v']])
    mutations <- rowRanges(vcf)
    mutations <- mutations[
        elementNROWS(mutations$REF) == 1 &
        elementNROWS(mutations$ALT) == 1
    ]
    mutations$REF <- as.character(mutations$REF)
    mutations$ALT <- unlist(CharacterList(mutations$ALT))
    mutations <- as.data.frame(mutations) %>%
        dplyr::mutate(sample = args[['v']]) %>%
        dplyr::select(chr = seqnames,
               pos = start,
               ref = REF,
               alt = ALT,
               sample = sample) %>%
        as.data.frame()
}

print(mutations %>% as_tibble)
library(deconstructSigs,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library/")

if (!is.null(args[['r']])) {
    if (args[['r']] == 'GRCh38') {

	mutations<-mutations[setdiff(rownames(mutations),grep("v",mutations$chr)),]
        mutations$chr<-gsub("chr","",mutations$chr)
        mutations$chr<-gsub("^M$","MT",mutations$chr)
	mutations<-mutations[mutations[,1] %in% as.character(c(1:22,"X")),]
        
	catalog <- mut.to.sigs.input(mut.ref = mutations,
                                    sample.id = 'sample',
                                    chr = 'chr',
                                    pos = 'pos',
                                    ref = 'ref',
                                    alt = 'alt',
                                    bsg = BSgenome.Hsapiens.NCBI.GRCh38)
    } else {
        catalog <- mut.to.sigs.input(mut.ref = mutations,
                                    sample.id = 'sample',
                                    chr = 'chr',
                                    pos = 'pos',
                                    ref = 'ref',
                                    alt = 'alt')
    }
}

catalog %>% t %>% as.data.frame %>% `colnames<-`(c('count')) %>% rownames_to_column('mutation_type') %>% write_tsv(args[['c']])

print(paste('Wrote catalogs to', args[['c']]))
