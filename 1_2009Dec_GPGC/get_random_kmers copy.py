#
## construct a random genome
# from swr_qp.py
import random
import sys

#10000000
N=2500000
genome = "A"*N + "C"*N + "G"*N + "T"*N
genome = list(genome)
random.shuffle(genome)
#line2 = "".join(genome)
#print line2

count = 0

for i in range(0,10000000,75):
    count = count +1
    bases = genome[i:i+75]
    line = "".join(bases)
    head = ">"+str(count)
    print head
    print line



