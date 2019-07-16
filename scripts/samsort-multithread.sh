#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --mem=16000M
#SBATCH --cpus-per-task=6
#SBATCH --account=def-bcoomber

module load bwa
module load samtools
module load bcftools

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "[TIMESTAMP] called at "
date

###### SAMTOOLS ########################## #######
###################################################

samtools sort -@ 6 -m 2000M $1.temp.bam -o $1.sort.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools sort step\n"
	        exit 1
	else
		printf "samtools sort passed at time "
		date
	fi

samtools index $1.sort.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools index step\n"
 	        exit 1
	else
		printf "samtools index passed at time "
		date
        fi


