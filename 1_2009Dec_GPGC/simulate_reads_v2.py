#!/usr/bin/env python
import sys
import random
#>gi|48994873|gb|U00096.2| Escherichia coli str. K-12 substr. MG1655, complete genome
#AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC
#TTCTGAACTGGTTACCTGCCGTGAGTAAATTAAAATTTTATTGACTTAGGTCACTAAATACTTTAACCAA
#TATAGGCATAGCGCACAGACAGATAAAAATTACAGAGTACACAACATCCATGAAACGCATTAGCACCACC
#ATTACCACCACCATCACCATTACCACAGGTAACGGTGCGGGCTGACGCGTACAGGAAACACAGAAAAAAG
#CCCGCACCTGACAGTGCGGGCTTTTTTTTTCGACCAAAGGTAACGAGGTAACAACCATGCGAGTGTTGAA
#GTTCGGCGGTACATCAGTGGCAAATGCAGAACGTTTTCTGCGTGTTGCCGATATTCTGGAAAGCAATGCC
#AGGCAGGGGCAGGTGGCCACCGTCCTCTCTGCCCCCGCCAAAATCACCAACCACCTGGTGGCGATGATTG


def error(string,error_rate):
    string_list = list(string)
    error_rate = float(error_rate)
    size = len(string)
    error_num = int(size*error_rate)
    error = random.sample(xrange(size),error_num)
    for l in error:
        error_base = string_list[l]
        while error_base == string_list[l]:
            error_base_list = random.sample(['a','c','t','g'],1)
            error_base = error_base_list[0]
        string_list[l] = error_base
    
    new_string = ''.join(string_list)
    return new_string
    
    

    

filein = sys.argv[1]
fileout = sys.argv[2]
coverage = float(sys.argv[3])
error_rate = sys.argv[4]
length = int(sys.argv[5])



fh = open(filein,'r')
fw = open(fileout,'w')

all = ''

for line in fh:
    if line[0] != '>':
        newline = line.rstrip()
        all = all +newline




size = len(all)
size_list = range(0,size-length)

number_of_reads = int(size*coverage/length)

print size
print number_of_reads

count = 0
reads = ''
while count<number_of_reads:
    start = random.choice(size_list)
    read = all[start:start+length]
    reads = reads+read
#    fw.write('>%s\n%s\n' %(count,read))
    count = count+1
    #print count


reads_error = error(reads,error_rate)

count = 0
while count<number_of_reads:
    start = count*length
    read = reads_error[start:start+length]
    fw.write('>%s\n%s\n' %(count,read))
    count=count+1
    
    

