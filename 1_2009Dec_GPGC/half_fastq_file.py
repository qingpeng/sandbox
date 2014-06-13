# split a file to 2 files randomly
#


import sys
import screed
from screed.fastq import fastq_iter
import random

filename = sys.argv[1]

outname1 = sys.argv[2]
outname2 = sys.argv[3]

f1 = open(outname1,'w')
f2 = open(outname2,'w')


for n, record in enumerate(fastq_iter(open(filename))):
    sequence = record['sequence']
    name = record['name']
    r=random.randint(0,1)
    if r==0:
        f1.write('>'+name+'\n')
        f1.write(sequence+'\n')
    else:
        f2.write('>'+name+'\n')
        f2.write(sequence+'\n')

