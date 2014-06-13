#!/usr/bin/env python

#988	+1	2	gcatcaccgtttcacta
#990	+0	1	gcgtgagaatctcttct
#990	+1	1	cgtgagaatctcttctt
#992	+0	3	gtcccttggcgaagtca
#992	+1	3	tcccttggcgaagtcac
#992	+2	2	cccttggcgaagtcact
#992	+3	2	ccttggcgaagtcactg
#992	+4	2	cttggcgaagtcactga
#992	+5	2	ttggcgaagtcactgac

import sys
filein = sys.argv[1]
fileout = sys.argv[2]

f1 = open(filein,'r')
f2 = open(fileout,'w')

start = "0"

for line in f1:
    line = line.rstrip()
    fields = line.split()
    #print fields
    if fields[0] !=start:
        if start !="0":
            max_number = max(list_number)
            min_number = min(list_number)
            output = start+'\n'+str(min_number)+' '+str(max_number)+'\n'
            f2.write(output)
        list_number=[]
        #print fields[2]
        list_number.append(int(fields[2]))
        start=fields[0]
         
    else:
        list_number.append(int(fields[2]))

max_number = max(list_number)
min_number = min(list_number)
output = start+'\n'+str(min_number)+' '+str(max_number)+'\n'
f2.write(output)

        

        
