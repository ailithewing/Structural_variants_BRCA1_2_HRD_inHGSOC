' flank_indels.R

Pulls flanking sequences around insertions/deletions (indels) using the reference genome.
This is the necessary pre-processing step before computing microhomology scores.

Required input is insertion/deletion (indel) calls in Variant Call Format (VCF).

Usage: flank_indels.R -v VCF -o OUTPUT

Options:
    -v --vcf VCF            Variant call file with indels
    -o --output OUTPUT      Path to output table of annotated indels

Example: microhomology/flank_indels.R -v indel_calls.vcf -o annotated_indels.tsv
' -> doc

library(docopt)
args <- docopt(doc)

library(tidyverse, lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
library(BSgenome,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")
library(VariantAnnotation,lib.loc="/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/hrdetect-pipeline/dependencies/miniconda3/envs/dependencies/lib/R/library")

rev_char <- function(char) {
    sapply(char, function(a) {
           paste(rev(substring(a,1:nchar(a),1:nchar(a))),collapse="")
    })
}

get_match_length <- function(x, y) { 
    min_length <- min(nchar(x), nchar(y))
    if (min_length == 0) {
        return(0) 
    } else { 
        return(sum(sapply(1:min_length, function(i) {
            substr(x, 1, i) == substr(y, 1, i) 
        })))
    }
}

get_overlap_length <- function(seq1, seq2) {
  overlap_matrix <- sapply(1:nchar(seq1), function(i) {
    subseq1 <- substring(seq1, i, nchar(seq1))
    sapply(1:nchar(seq2), function(j) {
      subseq2 <- substring(seq2, j, nchar(seq2))
      get_match_length(subseq1, subseq2)
    })
  })
  
  return(max(overlap_matrix))
}

parse_indel <- function(indel_vcf_path) {
    vcf <- readVcf(indel_vcf_path)
    vr <- rowRanges(vcf)
    print(vr)
    rowsToKeep <- elementNROWS(vr$ALT) == 1
    vr$ALT <- unlist(CharacterList(vr$ALT))
    all_indels <- as_tibble(vr[rowsToKeep, ]) %>%
        mutate(
            seqnames = gsub('chr', '', seqnames),
            seqnames = gsub('23', 'X', seqnames),
            seqnames = gsub('24', 'Y', seqnames)
        )

    indels <- all_indels[all_indels$seqnames %in% seqlevels(GRCh38)
                         & nchar(all_indels$REF) > nchar(all_indels$ALT), ]
    return(indels)
}

get_flanking_sequence <- function(indel_vcf_path) {
    print(indel_vcf_path)
    indels <- parse_indel(as.character(indel_vcf_path))

    print(paste('Number of indels:', dim(indels)[1]))

    print('retrieving flanking sequences')

    if (dim(indels)[1] > 0) {
        five_prime_flank <- getSeq(GRCh38, indels$seqnames, indels$start - 25, indels$start)
        three_prime_flank <- getSeq(GRCh38, indels$seqnames, indels$end + 1, indels$end + 26)
        deleted <- as.character(sapply(indels$REF, function(z) {substring(z, 2, nchar(z))}))
    } else {
        five_prime_flank <- c()
        three_prime_flank <- c()
        deleted <- c()
    }
    return(cbind(indels, tibble(deleted = as.character(deleted),
                                five_prime_flank = as.character(five_prime_flank), 
                                three_prime_flank = as.character(three_prime_flank))))
}

get_match_length <- function(x, y) { 
    min_length <- min(nchar(x), nchar(y))
    if (min_length == 0) {
        return(0) 
    } else { 
        return(sum(sapply(1:min_length, function(i) {
            substr(x, 1, i) == substr(y, 1, i) 
        })))
    }
}

microhomology_summary <- function(indel_table) {
    indel_table <- indel_table %>% filter(
        ! is.na(deleted),
        ! is.na(three_prime_flank),
        ! is.na(five_prime_flank)
    ) 

    print('computing match statistics')

    if (dim(indel_table)[1] > 0) {
        three_prime <- apply(indel_table, 1, function(z) {
            get_match_length(z['deleted'], z['three_prime_flank'])
        })

        five_prime <- apply(indel_table, 1, function(z) {
            get_match_length(rev_char(z['deleted']), rev_char(z['five_prime_flank']))
        })

        max_match <- apply(cbind(three_prime, five_prime), 1, max)

        indel_table$microhomology_length <- max_match
        indel_table$is_microhomology <- max_match > 2
    } else {
        indel_table$microhomology_length <- numeric()
        indel_table$is_microhomology <- logical()
    }

    return(indel_table)
}

GRCh38 <- getBSgenome('BSgenome.Hsapiens.NCBI.GRCh38')

indel_flanked <- get_flanking_sequence(args[['vcf']]) %>% microhomology_summary()
write_tsv(indel_flanked, path = args[['output']])
print(paste('Wrote INDEL flanking data to', args[['output']]))
