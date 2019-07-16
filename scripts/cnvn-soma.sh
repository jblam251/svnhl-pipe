#!/bin/bash
#SBATCH --time=00:45:00
#SBATCH --mem=100M
#SBATCH --account=def-bcoomber

module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA


###### CNVNATOR ########################## #######
###################################################

python $BIN/cnvnCallSomatic.py -normal $1_cnvn.tsv -tumor $2_cnvn.tsv -somatic_out cnvn_somatic.tsv
	printf "[TIMESTAMP]: CNVNator Somatic and Germline Calls Files Created "
	date
	
cnvnator2VCF.pl cnvn_somatic.tsv $REF > cs.temp.vcf 
	printf "[TIMESTAMP]: CNVNator Somatic VCF file completed "
	date

cat $1_cnvn.tsv >> cnvn_all.tsv
cat $2_cnvn.tsv >> cnvn_all.tsv
cnvnator2VCF.pl cnvn_all.tsv $REF > ca.temp.vcf 
	printf "[TIMESTAMP]: CNVNator Combined VCF file completed "
	date


###### VCFTOOLS ########################## #######
###################################################

module load nixpkgs/16.09 
module load intel/2016.4
module load vcftools/0.1.14

vcf-sort -c cs.temp.vcf > cnvn_somatic.vcf
vcf-sort -c ca.temp.vcf > cnvn_all.vcf
	printf "[TIMESTAMP]: VCF files Sorted at "
	date
