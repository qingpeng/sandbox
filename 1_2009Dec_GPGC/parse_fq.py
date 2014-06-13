#!/usr/bin/env python
# python parse_fq.py <fq_input_file> <fasta_file_output> <left_30_file_output> <middle_30_file_output> <right_30_file_output>


import sys
input_fh = open(sys.argv[1],'r')
output_fh1 = open(sys.argv[2],'w')
output_fh_left = open(sys.argv[3],'w')
output_fh_middle = open(sys.argv[4],'w')
output_fh_right = open(sys.argv[5],'w')

count= 0
for line in input_fh:
    if count == 0:
        line=line.replace('@','>')
        line=line.replace(':','_')
        output_fh1.write(line)
        name = line
        count+=1
    elif count == 1:
        left = line[0:30]
        middle = line[23:53]
        right = line[46:76]
        
        output_fh1.write(line)
        name=name.rstrip()
        left_name = name+'_left\n'
        middle_name = name+'_middle\n'
        right_name = name+'_right\n'
        
        output_fh_left.write(left_name)
        output_fh_left.write('%s\n' %(left))
        output_fh_middle.write(middle_name)
        output_fh_middle.write('%s\n' %(middle))
        output_fh_right.write(right_name)
        output_fh_right.write('%s\n' %(right))
        
        
        count+=1
    elif count == 2:
        count+=1
    elif count ==3:
        count=0

