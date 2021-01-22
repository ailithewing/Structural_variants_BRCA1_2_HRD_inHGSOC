#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=8G
#$ -pe sharedmem 4
#$ -N run_HRDetect

source dependencies/miniconda3/bin/activate dependencies

snakemake

#sh scripts/hrdetect/runDeconstructSigs.sh SHGSOC all

source dependencies/miniconda3/bin/deactivate 

