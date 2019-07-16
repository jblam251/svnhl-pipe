#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=100M
#SBATCH --array=1-38%12
#SBATCH --account=def-bcoomber

module load samtools

BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA
mkdir bam_splits

echo "bam split called at "
date

##### SAMTOOLS #########
########################
samtools view -h -b $1.sort.bam chr$SLURM_ARRAY_TASK_ID > ./bam_splits/$1chr$SLURM_ARRAY_TASK_ID.sort.bam
	if [ $? -ne 0 ]
	then				
		printf "problem at split bam step\n"
	        exit 1
	else
		printf "samtools split bam passed at time "
		date
	fi

	
samtools index ./bam_splits/$1chr$SLURM_ARRAY_TASK_ID.sort.bam
	if [ $? -ne 0 ]
	then				
		printf "problem at split bam indexing step\n"
	        exit 1
	else
		printf "samtools split bam indexing passed at time "
		date
	fi
