#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=1000M
#SBATCH --array=1-38%8
#SBATCH --account=def-bcoomber

module load breakdancer/1.4.5

BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

echo "breakdancer max called at "
date

cd $DATA

srun breakdancer-max -o chr$SLURM_ARRAY_TASK_ID -q 24 brkdncr.cfg > chr$SLURM_ARRAY_TASK_ID.tsv 

echo "breakdancer max finished at "
date
