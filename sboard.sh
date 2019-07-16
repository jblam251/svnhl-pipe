#!/bin/bash

### THREE ARGUMENTS 
### $1 [INT]: the switch
### $2 [file]: the normal file prefix
### $3 [file]: the tumor file prefix
### sboard.sh [INT] [norm_file] [tumor_file]

###### SICKLE ##########################
########################################
if [ $1 = "1" ]; then
	sbatch ./scripts/filter.sh $2
	sbatch ./scripts/filter.sh $3


###### BWA & SAMBLASTER ################
########################################
elif [ $1 = "2" ]; then
	sbatch ./scripts/align-multithread.sh $2
	sbatch ./scripts/align-multithread.sh $3


###### SAMTOOLS ########################
########################################
elif [ $1 = "3" ]; then
	sbatch ./scripts/sam2bam.sh $2
	sbatch ./scripts/sam2bam.sh $3


###### SAMTOOLS and CNVNATOR ROOT ######
########################################
elif [ $1 = "4" ]; then
	sbatch ./scripts/samsort-multithread.sh $2
	sbatch ./scripts/cnvn-root.sh $2

	sbatch ./scripts/samsort-multithread.sh $3
	sbatch ./scripts/cnvn-root.sh $3


###### CNVNATOR ########################
########################################
elif [ $1 = "5" ]; then
	sbatch ./scripts/cnvn-partition.sh $2
	sbatch ./scripts/cnvn-partition.sh $3

elif [ $1 = "6" ]; then
	sbatch ./scripts/cnvn-call.sh $2
	sbatch ./scripts/cnvn-call.sh $3

elif [ $1 = "7" ]; then
	sbatch ./scripts/cnvn-soma.sh $2 $3


###### BREAKDANCER and SAMTOOLS ########
########################################
elif [ $1 = "8" ]; then
	sbatch ./scripts/brkdncr-config.sh $2 $3


###### BREAKDANCER ####################
#######################################
elif [ $1 = "9" ]; then
	sbatch ./scripts/brkdncr-max.sh
	
	sbatch ./scripts/bam_splits.sh $2
	sbatch ./scripts/bam_splits.sh $3


elif [ $1 = "10" ]; then
	sbatch ./scripts/brkdncr-call.sh


###### DELLY ###########################
########################################
elif [ $1 = "11" ]; then
	sbatch ./scripts/delly-parallel.sh $2 $3

elif [ $1 = "12" ]; then
	sbatch ./scripts/bcf_concat.sh

fi




