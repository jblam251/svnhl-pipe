#!/bin/bash
#BATCH --time=
#SBATCH --mem=


module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04
module load delly
module load breakdancer/1.4.5
module load bwa
module load samtools
module load bcftools

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/projects/def-lukens/jblamer/inputs/merged_script2"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"

cd $DATA
gunzip *.gz


###### SICKLE ############################ #######
###################################################

parallel sickle pe -f {}_R1.fastq -r {}_R2.fastq -t sanger -o {}_R1.fltr.fastq -p {}_R2.fltr.fastq -s singles.fltr ::: $(ls -1 *_R1.fastq | sed 's/_R1.fastq//')
	
	if [ $? -ne 0 ]
	then				
		printf "problem at filtering step\n"
	        exit 1
	else
		printf "filtering passed at time "
		date
        fi



###### BWA ALLIGNMENT & SAMBLASTER ################
###################################################

parallel bwa mem $REF {}_R1.fltr.fastq {}_R2.fltr.fastq "|" samblaster ">" {}.sam ::: $(ls -1 *_R1.fltr.fastq | sed 's/_R1.fltr.fastq//')	

	if [ $? -ne 0 ]
	then				
		printf "problem at bwa alignment step\n"
        exit 1
	else
		printf "bwa alignment passed at time "
		date
	fi	




###### SAMTOOLS ########################## #######
###################################################
parallel samtools view -b -S {}.sam ">" {}.temp.bam ::: $(ls -1 *.sam | sed 's/.sam//')	
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools view step\n"
	        exit 1
	else
		printf "samtools view passed at time "
		date
	fi

parallel samtools sort {}.temp.bam -o {}.sort.bam ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools sort step\n"
	        exit 1
	else
		printf "samtools sort passed at time "
		date
	fi

parallel samtools index {} ::: $(ls -1 *.sort.bam)
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools index step\n"
  	        exit 1
	else
		printf "samtools index passed at time "
		date
        fi




######### DELLY ########################## #######
###################################################

parallel delly call -o {}_delly.bcf -n -g $REF {}-B.sort.bam {}-F.sort.bam ::: $(ls -1 *-B.sort.bam | sed 's/-B.sort.bam//') 
	
	printf "[TIMESTAMP]: DELLY  VCF File Created at "
	date




###### BREAKDANCER ########################## #######
######################################################
parallel $BIN/bam2cfg.pl -g -h {}-B.temp.bam {}-F.temp.bam ">" {}_brkdncr.cfg ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR Config File Created at "
	date

parallel breakdancer-max -q 24 {}_brkdncr.cfg ">" {}_brkdncr.tsv ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR TSV  File Created at "
	date

parallel $BIN/breakdancer2vcf_JB.py -i {}_brkdncr.tsv -o {}_brkdncr.vcf ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR VCF Created at "
	date




###### CNVNATOR ########################## #######
###################################################
parallel cnvnator -root {}_cnvn.root -chrom chr13 -tree {}-B.temp.bam ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -tree completed "
	date

parallel cnvnator -root {}_cnvn.root -his 50 -chrom chr13 ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -his completed "
	date

parallel cnvnator -root {}_cnvn.root -stat 50 $REF ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date


printf "[TIMESTAMP]: CNVNator -root and -partition started "
parallel cnvnator -root {}_cnvn.root -partition 50 ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -partition completed "
	date

parallel cnvnator -root {}_cnvn.root -chrom chr13 -call 50 ">" {}_cnvn.tsv ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -call (TSV) completed "
	date
		
parallel cnvnator2VCF.pl -prefix {}-B.temp.bam {}_cnvn.tsv $REF ">" {}_cnvn.vcf ::: $(ls -1 *-B.temp.bam | sed 's/-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator (VCF) completed "
	date


