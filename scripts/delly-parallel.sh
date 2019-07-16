#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=3000M
#SBATCH --array=1-38%16
#SBATCH --account=def-bcoomber

module load delly
module load samtools
module load bcftools

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA/bam_splits


######### DELLY ########################## #######
###################################################

$BIN/make_dlyconfig3.sh delly.cfg 
	printf "[TIMESTAMP]: DELLY Config Files Created at "
	date

delly call -o chr$SLURM_ARRAY_TASK_ID-delly.bcf -n -g $REF $1chr$SLURM_ARRAY_TASK_ID.sort.bam $2chr$SLURM_ARRAY_TASK_ID.sort.bam 
	printf "[TIMESTAMP]: DELLY BCF File Created at "
	date

delly filter -f somatic -o chr$SLURM_ARRAY_TASK_ID-delly_somatic.bcf -s delly.cfg chr$SLURM_ARRAY_TASK_ID-delly.bcf 
	printf "[TIMESTAMP]: DELLY Somatic BCF Created at "
	date

