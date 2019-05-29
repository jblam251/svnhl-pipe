#!/bin/bash
awk '{print $2;}' chr13_cnvn.vcf | tail -555 > temp

input="./temp"
##while IFS= read -r var
while read name
do
	x = $(($name +  1))
	##print "$x\n"
	##echo $name
done < "$input"
