#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=500M
#SBATCH --array=[1-37:2]%10
#SBATCH --account=def-bcoomber

module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA

echo "[TIMESTAMP] program call at "
date

srun cnvnator -root $1_cnvn.root -partition 50 -chrom chr$SLURM_ARRAY_TASK_ID chr$((SLURM_ARRAY_TASK_ID+1))
        printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date

