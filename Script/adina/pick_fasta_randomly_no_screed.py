# pick percentage% randomly from a fasta file

#


import sys

import random

filename = sys.argv[1]

outname1 = sys.argv[2]

num = int(sys.argv[3]) # percentage to pick randomly

f2 = open(filename,'r')
f1 = open(outname1,'w')


list_seq=[]
list_name=[]

for line in f2:
    if line[0] == '>':
        list_name.append(line)
    else:
        list_seq.append(line)
        
        

    if len(list_seq)==100:
        #print num
      
        r=random.sample(xrange(100),num)
        #print r 
        for i in r:
            f1.write('>' +list_name[i])
            f1.write(list_seq[i])
        list_seq=[]
        list_name = []
