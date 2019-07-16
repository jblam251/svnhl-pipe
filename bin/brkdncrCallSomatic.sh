#!/bin/bash

## a script to seperate the somatic calls from a breakdancer outfile
## usage: $./grep_script.sh breakdancer.tsv new_somatic.tsv new_germ.tsv


grep -v "#" $1 > dat
grep "#" $1 > $2
#grep "#" $1 > $3
#grep B.sort.bam dat | grep F.sort.bam >> $3
grep -v B.sort.bam dat >> $2 
grep -v F.sort.bam dat >> $2

rm dat


