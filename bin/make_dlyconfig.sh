#!/bin/bash

ls -1 *.sort.bam | sed 's/.bam//' > temp.cfg
awk '{if (NR == 1){print $0"\tcontrol"} if (NR == 2){print $0"\ttumor"}}' temp.cfg > $1
rm temp.cfg
