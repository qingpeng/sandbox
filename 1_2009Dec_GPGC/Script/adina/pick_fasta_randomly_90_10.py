# pick percentage% randomly from a fasta file

#
# modify to pick num from 200, for 1%
#

import sys
import screed
from screed.fasta import fasta_iter
import random

filename = sys.argv[1]

outname1 = sys.argv[2]
outname2 = sys.argv[3]



f1 = open(outname1,'w')
f2 = open(outname2,'w')


list_seq=[]
list_name=[]

for n, record in enumerate(fasta_iter(open(filename))):
    sequence = record['sequence']
    name = record['name']
    list_seq.append(sequence)
    list_name.append(name)
    if len(list_seq)==100:
        #print num
      
        r=random.sample(xrange(100),100)
        #print r 
        for i in r[:90]:
            f1.write('>' +list_name[i]+'\n')
            #print '>' +list_name[i]+'\n'
            f1.write(list_seq[i]+'\n')
            #print list_seq[i]+'\n'
        for j in r[90:]:
            f2.write('>' +list_name[j]+'\n')
            f2.write(list_seq[j]+'\n')        
        list_seq=[]
        list_name = []

f1.close()
f2.close()

