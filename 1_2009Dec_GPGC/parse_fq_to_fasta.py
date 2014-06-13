#!/usr/bin/env python
# python parse_fq.py <fq_input_file> <fasta_file_output> 


import sys
input_fh = open(sys.argv[1],'r')
output_fh1 = open(sys.argv[2],'w')

count= 0
for line in input_fh:
    if count == 0:
        line=line.replace('@','>')
        line=line.replace(':','_')
        output_fh1.write(line)
        name = line
        count+=1
    elif count == 1:
        
        output_fh1.write(line)
        name=name.rstrip()
        count+=1
    elif count == 2:
        count+=1
    elif count ==3:
        count=0

