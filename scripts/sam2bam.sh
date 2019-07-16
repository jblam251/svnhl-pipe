#!/bin/bash
#SBATCH --time=10:00:00
#SBATCH --mem=100M
#SBATCH --account=def-bcoomber

module load samtools
module load bcftools

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA

###### SAMTOOLS: SAM TO BAM ################ #######
###################################################

samtools view -b -S $1.sam > $1.temp.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools view step\n"
	        exit 1
	else
		printf "samtools view passed at time "
		date
	fi


