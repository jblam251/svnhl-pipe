#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mem=6000M
#SBATCH --account=def-bcoomber

module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA


###### CNVNATOR ########################## #######
###################################################

cnvnator -root $1_cnvn.root -tree $1.temp.bam -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -tree completed "
	date

cnvnator -root $1_cnvn.root -his 50 -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -his completed "
	date

cnvnator -root $1_cnvn.root -stat 50 $REF -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date



