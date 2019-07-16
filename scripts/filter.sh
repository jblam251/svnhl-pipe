#!/bin/bash
#SBATCH --time=01:30:00
#SBATCH --mem=500M
#SBATCH --account=def-bcoomber

module load samtools
module load sickle

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA


###### SICKLE ############################ #######
###################################################
sickle pe -f $1_R1.fastq -r $1_R2.fastq -t sanger -o $1_R1.fltr.fastq -p $1_R2.fltr.fastq -s $1_singles.fltr.fastq
	
	if [ $? -ne 0 ]
	then				
		printf "problem at filtering step\n"
	        exit 1
	else
		printf "filtering passed at time "
		date
        fi



