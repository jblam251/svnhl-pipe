#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --mem=24000M
#SBATCH --cpus-per-task=16
#SBATCH --account=def-bcoomber

module load samtools
module load samblaster
module load bwa

BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

cd $DATA

###### BWA ALLIGNMENT & SAMBLASTER ################
###################################################

bwa mem -t 16 -R $(echo "@RG\tID:$1_id\tLB:$1_lb\tSM:$1_sm\tPL:illumina") $REF $1_R1.fltr.fastq $1_R2.fltr.fastq | samblaster > $1.sam

	if [ $? -ne 0 ]
	then				
		printf "problem at samtools view step\n"
	        exit 1
	else
		printf "samtools view passed at time "
		date
	fi
