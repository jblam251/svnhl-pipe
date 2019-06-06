import sys
import os

if sys.argv[1] == "-normal":
    normalfile = sys.argv[2]
if sys.argv[3] == "-tumor":
    tumorfile = sys.argv[4]
if sys.argv[5] == "-somatic_out":
    somatic_outfile = sys.argv[6]
if sys.argv[7] == "-germline_out":
    germline_outfile = sys.argv[8]



nf_open = open(normalfile)
nf_as_list = nf_open.readlines()
nf_line_count = 0
for line in nf_as_list:
    nf_line_count += 1

tf_open = open(tumorfile)
tf_as_list = tf_open.readlines()
tf_line_count = 0
for line in tf_as_list:
    tf_line_count += 1

of_open = open(somatic_outfile, "w+")
ofg_open = open(germline_outfile, "w+")
for i in range(0, nf_line_count):
    triVal1 = nf_as_list[i].split("\t")[1]
    chromosome1 = int(str(triVal1.split(":")[0])[3:])
    begend1 = str(triVal1.split(":")[1])
    beg1 = int(begend1.split("-")[0])
    end1 = int(begend1.split("-")[1])
    max = round(float(nf_as_list[i].split("\t")[2]) / 2)
    CN1 = float(nf_as_list[i].split("\t")[3]) * 2
    for j in range(0, tf_line_count):
        triVal2 = tf_as_list[j].split("\t")[1]
        chromosome2 = int(str(triVal2.split(":")[0])[3:])
        begend2 = str(triVal2.split(":")[1])
        beg2 = int(begend2.split("-")[0])
        end2 = int(begend2.split("-")[1])
        CN2 = float(tf_as_list[j].split("\t")[3]) * 2
        if chromosome1 > chromosome2:
            pass
        elif chromosome1 == chromosome2:
            if abs((beg1-beg2) + (end1-end2)) < max:
                if (abs(CN1 - CN2) < 0.5) and (CN1 > 2.5 and CN2 > 2.5) or (CN1 < 1.5 and CN2 < 1.5):
                    ## GERMLINE CALL
                    ofg_open.writelines(tf_as_list[j])
                    break
                elif (abs(CN1 - CN2) > 0.5) and (CN2 > 2.5 and CN1 < 2.5) or (CN2 < 1.5 and CN1 > 1.5):
                    ## SOMATIC CALL (BOTH SVS COMPARED TO REF)
                    of_open.writelines(tf_as_list[j])
                    break
            elif j == tf_line_count-1:
                ## SOMATIC CALL (ONE SV, FOR LAST CHROMOSOME)
                of_open.writelines(nf_as_list[i])
                break
        elif chromosome1 < chromosome2:
            ## SOMATIC CALL (ONE SV COMPARED TO REF)
            of_open.writelines(nf_as_list[i])
            break


for i in range(0, tf_line_count):
    triVal1 = tf_as_list[i].split("\t")[1]
    chromosome1 = int(str(triVal1.split(":")[0])[3:])
    begend1 = str(triVal1.split(":")[1])
    beg1 = int(begend1.split("-")[0])
    end1 = int(begend1.split("-")[1])
    max = round(float(tf_as_list[i].split("\t")[2]) / 2)
    for j in range(0, nf_line_count):
        triVal2 = nf_as_list[j].split("\t")[1]
        chromosome2 = int(str(triVal2.split(":")[0])[3:])
        begend2 = str(triVal2.split(":")[1])
        beg2 = int(begend2.split("-")[0])
        end2 = int(begend2.split("-")[1])
        if chromosome1 > chromosome2:
            pass
        elif chromosome1 == chromosome2:
            if abs((beg1-beg2) + (end1-end2)) < max:
                break
            elif j == nf_line_count-1:
                ## SOMATIC CALL (ONE SV, LAST CHROMOSOME)
                of_open.writelines(tf_as_list[i])
                break
        elif chromosome1 < chromosome2:
            ## SOMATIC CALL (ONE SV COMPARED TO REF)
            of_open.writelines(tf_as_list[i])
            break

of_open.close()
ofg_open.close()
