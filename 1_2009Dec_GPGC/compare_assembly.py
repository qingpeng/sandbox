#!/usr/bin/env python
#
import sys

#NODE_47_length_68_cov_1.294118	100	95	33	73	11	136	29.5	0.42	10/21	47	NODE_280_length_104_cov_1.269231
#NODE_47_length_68_cov_1.294118	100	29	82	94	41	115	28.6	0.75	8/18	44	NODE_557_length_83_cov_1.481928
#NODE_48_length_77_cov_1.142857	109	108	1	108	1	109	84.5	1e-17	36/36	100	NODE_48_length_77_cov_1.142857
#NODE_48_length_77_cov_1.142857	109	107	3	107	3	109	82.2	5e-17	35/35	100	NODE_48_length_77_cov_1.142857
#NODE_48_length_77_cov_1.142857	109	1	108	1	108	109	81.3	1e-16	36/36	100	NODE_48_length_77_cov_1.142857
#NODE_48_length_77_cov_1.142857	109	56	109	56	109	109	46.0	4e-06	18/18	100	NODE_48_length_77_cov_1.142857
#NODE_48_length_77_cov_1.142857	109	63	107	63	107	109	40.5	2e-04	15/15	100	NODE_48_length_77_cov_1.142857
#NODE_48_length_77_cov_1.142857	109	109	65	109	65	109	37.5	0.002	15/15	100	NODE_48_length_77_cov_1.142857
#NODE_49_length_69_cov_1.086957	101	101	3	101	3	101	84.9	8e-18	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	1	99	1	99	101	83.5	2e-17	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	3	101	3	101	101	82.2	5e-17	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	100	2	100	2	101	77.6	1e-15	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	99	1	99	1	101	77.6	1e-15	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	2	100	2	100	101	76.7	2e-15	33/33	100	NODE_49_length_69_cov_1.086957
#NODE_49_length_69_cov_1.086957	101	101	21	61	141	246	38.2	0.001	16/27	59	NODE_159_length_214_cov_2.803738

file_in = sys.argv[1]
file_out = sys.argv[2]

f1 = open(file_in,'r')
number_with_hit = 0
last_name = ""
ok_100 = 0
f11 = open("ok100.fa",'w')
f12 = open("no100.fa",'w')
f21 = open("ok500.fa",'w')
f22 = open("no500.fa",'w')

ok_500 = 0
no_100 = 0
no_500 = 0

none = f1.readline()

# 100-500,500->

for line in f1:
#    print line
    line = line.rstrip()
    fields = line.split()
    if fields[0] != last_name:
        number_with_hit +=1
        #if abs(int(fields[2])-int(fields[3]))/float(fields[1])>0.9 and int(fields[-2])>90:
        if ((int(fields[2])<=3 and int(fields[3])>(int(fields[1])-3)) or (int(fields[3])<=3 and int(fields[2])>(int(fields[1])-3)) ) and int(fields[-2])==100:
            
            if int(fields[1])<500:
                #print line
                ok_100 +=1
                f11.write(line+'\n')
            else:
                ok_500 +=1
                f21.write(line+'\n')
        else:
            if int(fields[1])<500:
                no_100 +=1
                f12.write(line+'\n')
            else:
                no_500 +=1
                f22.write(line+'\n')
                
    last_name = fields[0]
    
f2 = open(file_out,'w')

f2.write("number_with_hit:"+str(number_with_hit)+'\n')
f2.write("ok100:"+str(ok_100)+"   no100:"+str(no_100)+"   ok500:"+str(ok_500)+"   no500:"+str(no_500))


            
    
        
    
