#!/usr/bin/env python
# python  <fa_input_file> <left_30_file_output> <middle_30_file_output> <right_30_file_output>


import sys
input_fh = open(sys.argv[1],'r')

output_fh_left = open(sys.argv[2],'w')
output_fh_middle = open(sys.argv[3],'w')
output_fh_right = open(sys.argv[4],'w')

count= 0
for line in input_fh:
    if line[0] == '>':
        name = line

    else :
        line=line.rstrip()
        left = line[0:32]
        middle_index = len(line)/2-16
        right_index = len(line)-32
        middle = line[middle_index:middle_index+32]
        right = line[right_index:]
        
 
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
