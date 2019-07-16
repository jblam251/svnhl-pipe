#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --mem=100M
#SBATCH --account=def-bcoomber

module load bcftools
module load vcftools/0.1.14

BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA/bam_splits

##### BCF CONCAT ###########
###########################
ls -1 *-delly.bcf > dellyAll_files
bcftools concat -o $DATA/a.temp.bcf -f dellyAll_files
vcf-sort -c $DATA/a.temp.bcf > $DATA/delly_all.bcf
bcftools view $DATA/delly_all.bcf > $DATA/delly_all.vcf
	echo "VCFs Merged for ALL Delly Calls at "
	date

ls -1 *-delly_somatic.bcf > dellySomatic_files
bcftools concat -o $DATA/s.temp.bcf -f dellySomatic_files
vcf-sort -c $DATA/s.temp.bcf > $DATA/delly_somatic.bcf
bcftools view $DATA/delly_somatic.bcf > $DATA/delly_somatic.vcf
	echo "VCFs Merged for SOMATIC Delly Calls at "
	date

#cd $DATA
#rm -r $DATA/bam_splits

