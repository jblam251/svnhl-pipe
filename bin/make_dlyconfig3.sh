#!/bin/bash

ls -1 *chr1.sort.bam | sed 's/chr1.sort.bam//' | awk '{print $0"_sm"}' > temp.cfg
awk '{if (NR == 1){print $0"\tcontrol"} if (NR == 2){print $0"\ttumor"}}' temp.cfg > $1
rm temp.cfg

