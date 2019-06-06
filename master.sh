#!/bin/bash
#SBATCH --time=00:45:00
#SBATCH --mem-per-cpu=8000M
#SBATCH --ntasks=2

module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04
module load delly
module load breakdancer/1.4.5
module load bwa
module load samtools
module load bcftools
module load sickle
module load samblaster

REF="/home/jblamer/projects/def-lukens/jblamer/ref/canFam3.fa"
DATA="/home/jblamer/projects/def-lukens/jblamer/data/hundKfq_sample"
BIN="/home/jblamer/projects/def-lukens/jblamer/bin"


cd $DATA
gunzip *.gz


###### SICKLE ############################ #######
###################################################

parallel sickle pe -f {}_R1.fastq -r {}_R2.fastq -t sanger -o {}_R1.fltr.fastq -p {}_R2.fltr.fastq ::: $(ls -1 *_R1.fastq | sed 's/_R1.fastq//')
	
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

parallel bwa mem -R "@RG'\t'ID:{}_ID'\t'LB:{}_LB'\t'PL:illumna" $REF {}_R1.fltr.fastq {}_R2.fltr.fastq "|" samblaster ">" {}.sam ::: $(ls -1 *_R1.fltr.fastq | sed 's/_R1.fltr.fastq//')	

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

parallel $BIN/make_dlyconfig.sh {}_delly.cfg ::: $(ls -1 *_1.2-B.sort.bam | sed 's/_1.2-B.sort.bam//')

parallel delly call -o {}_delly.bcf -n -g $REF {}_1.2-B.sort.bam {}_2.2-F.sort.bam ::: $(ls -1 *_1.2-B.sort.bam | sed 's/_1.2-B.sort.bam//')

	printf "[TIMESTAMP]: DELLY  VCF File Created at "
	date

parallel delly filter -f somatic -o {}_delly_somatic.bcf -s {}_delly.cfg {}_delly.bcf ::: $(ls -1 *_1.2-B.sort.bam | sed 's/_1.2-B.sort.bam//')

parallel delly filter -f germline -o {}_delly_germline.bcf -s {}_delly.cfg {}_delly.bcf ::: $(ls -1 *_1.2-B.sort.bam | sed 's/_1.2-B.sort.bam//')

	printf "[TIMESTAMP]: DELLY  Somatic and Germline Files Created at "
	date




###### BREAKDANCER ########################## #######
######################################################

parallel $BIN/bam2cfg.pl -g -h {}_1.2-B.sort.bam {}_2.2-F.sort.bam ">" {}_brkdncr.cfg ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR Config File Created at "
	date

parallel breakdancer-max -q 24 {}_brkdncr.cfg ">" {}_brkdncr.tsv ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR TSV  File Created at "
	date

parallel $BIN/brkdncrCallSomatic.sh {}_brkdncr.tsv {}_brkdncr_somatic.tsv {}_brkdncr_germline.tsv ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR Somatic Call File Created at "
	date


parallel $BIN/breakdancer2vcf_JB.py -i {}_brkdncr_somatic.tsv -o {}_brkdncr_somatic.vcf ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')
parallel $BIN/breakdancer2vcf_JB.py -i {}_brkdncr_germline.tsv -o {}_brkdncr_germline.vcf ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')

	printf "[TIMESTAMP]: BRKDNCR VCF files Created at "
	date





###### CNVNATOR ########################## #######
###################################################

parallel cnvnator -root {}_cnvn.root -tree {}.temp.bam -chrom chr1 chr2 chr3 chr4 chr5 chr6 ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -tree completed "
	date

parallel cnvnator -root {}_cnvn.root -his 50 -chrom chr1 chr2 chr3 chr4 chr5 chr6 ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -his completed "
	date

parallel cnvnator -root {}_cnvn.root -stat 50 $REF -chrom chr1 chr2 chr3 chr4 chr5 chr6 ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date

parallel cnvnator -root {}_cnvn.root -partition 50 -chrom chr1 chr2 chr3 ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date

parallel cnvnator -root {}_cnvn.root -call 50 -chrom chr1 chr2 chr3 ">" {}_cnvn.tsv ::: $(ls -1 *.temp.bam | sed 's/.temp.bam//')
	printf "[TIMESTAMP]: CNVNator -root and -call (TSV) completed "
	date
		
parallel python $BIN/cnvnCallSomatic.py -normal {}_1.2-B_cnvn.tsv -tumor {}_2.2-F_cnvn.tsv -somatic_out {}_cnvn_somatic.tsv -germline_out {}_cnvn_germline.tsv ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator Somatic and Germline Calls Files Created  "
	date
	
parallel cnvnator2VCF.pl {}_cnvn_somatic.tsv $REF ">" {}_cnvn_somatic.vcf ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')
parallel cnvnator2VCF.pl {}_cnvn_germline.tsv $REF ">" {}_cnvn_germline.vcf ::: $(ls -1 *_1.2-B.temp.bam | sed 's/_1.2-B.temp.bam//')
	printf "[TIMESTAMP]: CNVNator VCF files completed "
	date
