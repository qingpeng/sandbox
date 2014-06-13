#!/usr/bin/env python
import sys
import random


input = open (sys.argv[1],'r')
output = open(sys.argv[2],'w')

name = {}
last_family  = "A"
seq={}

for line in input:
    if ">" in line:
        line = line.rstrip()
        fields = line.split(">")
        fields2 = fields[1].split('__')
        family = fields2[0]
        seq_name = line
        if family == last_family:
            name[family].append(seq_name)
        else:
            name[family]=[]
            name[family].append(seq_name)
            last_family = family
    else:
        line = line.rstrip()
        seq[seq_name] = line
        
for family in name.keys():
    #print family,'\n'
    #print name[family]
    random_name = random.sample(name[family],50)
    for seq_name in random_name:
        output.write('%s\n%s\n' %(seq_name,seq[seq_name]))

