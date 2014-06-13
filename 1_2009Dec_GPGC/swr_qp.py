#! /usr/bin/env python
import khmer
import random
import sys
random.seed(10)

K = 12                                  # size of K
#N = 25000                               # 1/4 the size of the genome
#N = 61005
#P_ERROR = .01                           # per-base probability of error

###

filein = sys.argv[1]
P_ERROR = float(sys.argv[2])

fh = open(filein,'r')


all = ''

for line in fh:
    if line[0] != '>':
        newline = line.rstrip()
        all = all +newline


genome = all
N4 = len(genome)

print>>sys.stderr, 'length of genome ', N4

#
## construct a random genome
#genome = "A"*N + "C"*N + "G"*N + "T"*N
#genome = list(genome)
#random.shuffle(genome)
#genome = "".join(genome)

###

# count the number of unique k-mers
kt = khmer.new_ktable(K)
kt.consume(genome)

total = 0
for i in range(0, 4**K):
    if kt.get(i):
        total += 1

print >> sys.stderr, "%d unique k-mers in genome" % total

###

# go through, sample with replacement and mutation, and calculate
# number of novel k-mers picked as a function of sampling.

kt = khmer.new_ktable(K)
n = 0
for i in range(0, 20*N4):
    # pick random k-mer
    pos = random.randint(0, N4 - K)
    subseq = genome[pos:pos+K]

    # should we mutate?
    if random.uniform(0, 1) <= P_ERROR:
        z = random.choice(range(K))
        subseq = list(subseq)
        new_bp = random.choice('ACGT')
        while subseq[z] == new_bp:
            new_bp = random.choice('ACGT')
            
        subseq[z] = new_bp
        subseq = "".join(subseq)

    # count!
    kt.count(subseq)

    # is it novel?
    if kt.get(subseq) == 1:
        n += 1

    # progress report and output
    if i % 10000 == 0:
        if i % 100000 == 0:
            print>>sys.stderr, '...', i
        print i, n

