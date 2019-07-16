#!/bin/bash

module load sickle
module load samtools
module load samblaster
module load bwa
module load bcftools
module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04
module load breakdancer/1.4.5
module load vcftools/0.1.14
module load delly

REF="jblamer/ref/canFam3.fa"
BIN="jblamer/bin"
DATA="jblamer/scratch/scratch_cases"

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

cd $DATA

###### SICKLE ############################ #######
###################################################
sickle pe -f $1_R1.fastq -r $1_R2.fastq -t sanger -o $1_R1.fltr.fastq -p $1_R2.fltr.fastq -s $1_singles.fltr.fastq
	
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

bwa mem -t 16 -R $(echo "@RG\tID:$1_id\tLB:$1_lb\tSM:$1_sm\tPL:illumina") $REF $1_R1.fltr.fastq $1_R2.fltr.fastq | samblaster > $1.sam

	if [ $? -ne 0 ]
	then				
		printf "problem at samtools view step\n"
	        exit 1
	else
		printf "samtools view passed at time "
		date
	fi


###### SAMTOOLS: SAM TO BAM ################ #######
###################################################

samtools view -b -S $1.sam > $1.temp.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools view step\n"
	        exit 1
	else
		printf "samtools view passed at time "
		date
	fi


###### SAMTOOLS ########################## #######
###################################################

samtools sort -@ 6 -m 2000M $1.temp.bam -o $1.sort.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools sort step\n"
	        exit 1
	else
		printf "samtools sort passed at time "
		date
	fi

samtools index $1.sort.bam 
	if [ $? -ne 0 ]
	then				
		printf "problem at samtools index step\n"
 	        exit 1
	else
		printf "samtools index passed at time "
		date
        fi


###### CNVNATOR ########################## #######
###################################################

cnvnator -root $1_cnvn.root -tree $1.temp.bam -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -tree completed "
	date

cnvnator -root $1_cnvn.root -his 50 -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -his completed "
	date

cnvnator -root $1_cnvn.root -stat 50 $REF -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38
	printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date


srun cnvnator -root $1_cnvn.root -partition 50 -chrom chr$SLURM_ARRAY_TASK_ID chr$((SLURM_ARRAY_TASK_ID+1))
        printf "[TIMESTAMP]: CNVNator -root and -stat completed "
	date


cnvnator -root $1_cnvn.root -call 50 -chrom chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38 > $1_cnvn.tsv

	printf "[TIMESTAMP]: CNVNator -root and -call (TSV) completed "
	date
		
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

vcf-sort -c cs.temp.vcf > cnvn_somatic.vcf
vcf-sort -c ca.temp.vcf > cnvn_all.vcf
	printf "[TIMESTAMP]: VCF files Sorted at "
	date



##### SAMTOOLS SPLIT #########
##############################

mkdir bam_splits

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


###### BREAKDANCER ########################## #######
######################################################

$BIN/bam2cfg.pl -g -h $1.sort.bam $2.sort.bam > brkdncr.cfg

	printf "[TIMESTAMP]: BRKDNCR Config File Created at "
	date

mkdir histograms
mv *histogram* ./histograms

srun breakdancer-max -o chr$SLURM_ARRAY_TASK_ID -q 24 brkdncr.cfg > chr$SLURM_ARRAY_TASK_ID.tsv 


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


