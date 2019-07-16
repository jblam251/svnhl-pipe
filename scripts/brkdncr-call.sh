#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --mem=500M
#SBATCH --account=def-bcoomber

module load breakdancer/1.4.5
module load samtools
module load bcftools
module load vcftools/0.1.14

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"
DATA="/home/jblamer/scratch/scratch_cases/case_31"

cd $DATA


###### BREAKDANCER ########################## #######
######################################################

for i in {38..1}
do
	if [ $i = 1 ]; then
		mv chr$i.tsv brkdncr_all.tsv
                break
        else
                echo "$(tail -n +7 chr$i.tsv)" > chr$i.tsv
                cat chr$i.tsv >> chr$((i-1)).tsv
                rm chr$i.tsv
        fi
	done


$BIN/brkdncrCallSomatic.sh brkdncr_all.tsv brkdncr_somatic.tsv
	printf "[TIMESTAMP]: BRKDNCR Somatic Call File Created at "
	date

$BIN/breakdancer2vcf_JB.py -i brkdncr_all.tsv -o ba.temp.vcf
vcf-sort -c ba.temp.vcf > brkdncr_all.vcf
	printf "[TIMESTAMP]: BRKDNCR SOMATIC VCF file Created at "
	date

$BIN/breakdancer2vcf_JB.py -i brkdncr_somatic.tsv -o bs.temp.vcf 
vcf-sort -c bs.temp.vcf > brkdncr_somatic.vcf
	printf "[TIMESTAMP]: BRKDNCR SOMATIC VCF file Created at "
	date


