#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=100M
#SBATCH --account=def-bcoomber

module load breakdancer/1.4.5
module load samtools
module load bcftools

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA

###### BREAKDANCER ########################## #######
######################################################

$BIN/bam2cfg.pl -g -h $1.sort.bam $2.sort.bam > brkdncr.cfg

	printf "[TIMESTAMP]: BRKDNCR Config File Created at "
	date

mkdir histograms
mv *histogram* ./histograms
