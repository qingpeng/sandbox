#!/usr/bin/env python
# python parse_fq.py <fq_input_file> <fasta_file_output> <left_30_file_output> <middle_30_file_output> <right_30_file_output>


import sys
input_fh = open(sys.argv[1],'r')
output_fh1 = open(sys.argv[2],'w')

for line in input_fh:
    if line[0] == '>':
        output_fh1.write(line)
    else:
        newline = line[0:21]+'\n'
        output_fh1.write(newline)
        
