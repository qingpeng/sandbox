#!/usr/bin/env python
import sys
file_in = sys.argv[1]
file_in2 = sys.argv[2]
file_out = sys.argv[3]
f1 = open(file_in,'r')
f2 = open(file_in2,'r')
f_out = open(file_out,'w')
title=[]
seq=[]

for line2 in f2:
        if line2[0] == '>':
             title.append(line2)
        else:
             seq.append(line2)
dict = {}

for line in f1:
	line = line.rstrip()
	fields = line.split()
	file_name =fields[0]
        if file_name in dict:
            dict[file_name] = dict[file_name]+1
        else:
            dict[file_name]=1


for i in range(len(title)):
        if str(i) in dict and dict[str(i)] == 60 :
            f_out.write(title[i])
            f_out.write(seq[i])
            print i,title[i],seq[i]

#key = dict.keys()

#for key in key.sort():
#        if dict[key] == 60:
#            f_out.write(title[int(key)])
#            f_out.write(seq[int(key)])
 
#	    print key
