#!/usr/bin/env python
#usage python illumina_filtered_py input.fq output.fasta

from __future__ import division
import sys

def find(str, ch):
    index = 0
    while index < len(str):
        if str[index] == ch:
            return index
        index += 1
    return None

def fastq_parser(input):
    dict = {}
    count= 0
    for line in input:
        if count == 0:
            line=line.replace('@','>')
            line=line.replace(':','_')
            name = line.rstrip()
            count+=1
        elif count == 1:
            sequence = line.rstrip()
            count+=1
        elif count == 2:
            strand = line.rstrip()
            count+=1
        elif count ==3:
            qual = line.rstrip()
            dict[name] = [[sequence, strand, qual]]
            count=0
    return(dict)

def trimB(dict):
    count_removedB = 0
    trimmed_dict = {}

    for item in dict.items():
        for i in item[1]:
            location = find(i[2], 'B')
            trimmed_sequence = i[0][:(location)]
            trimmed_quality = i[2][:(location)]
            if not trimmed_sequence:
                    count_removedB += 1
            else:
                trimmed_dict[item[0]] = [[trimmed_sequence, i[1], trimmed_quality]]
    print 'Total reads processed was', len(dict.keys())
    print 'B-quality scores:  Total reads removed', count_removedB
    print 'B-quality scores:  Total reads trimmed', len(trimmed_dict.keys())    


  
    return(trimmed_dict)

def trimN(dict):
    countN = 0
    count_total_N = 0
    trimmed_dict2={}
    for item in dict.items():
        for i in item[1]:
            for j in i[0]:
                if j == 'N':
                    countN += 1
            if countN/len(i[0]) < 0.70:
                trimmed_dict2[item[0]] = [[i[0], i[1], i[2]]]
            else:
                count_total_N += 1
        countN = 0
    print 'N reads:  Total reads removed', count_total_N
    print 'Reads remaining:', len(trimmed_dict2.keys())
    return trimmed_dict2

if __name__ == '__main__':
    input = open(sys.argv[1],'r')
    output = open(sys.argv[2],'w')
   
    dict_raw = fastq_parser(input)
    dict_B = trimB(dict_raw)
    dict_N = trimN(dict_B)
    sorted_list = sorted(dict_N.items(), key = lambda x: (x[0]))
    for i in sorted_list:
        output.write('%s\n' %(i[0]))
        for j in i[1]:
            output.write('%s\n%s\n%s\n' % (str(j[0]), str(j[1]), str(j[2])))
