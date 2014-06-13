## using bloom filter to get the count of kmers
#
# hashtable size : from 1e7 
# hashtable number: 1-10


import khmer
import sys
import screed
from screed.fasta import fasta_iter

filename = sys.argv[1]
#K = int(sys.argv[2]) # size of kmer
#HT_SIZE= int(sys.argv[3])# size of hashtable
#N_HT = int(sys.argv[4]) # number of hashtables
N_HT = 4
K = 12
HT_SIZE_array = [100000,200000,400000,600000,800000,1000000,1200000]

for HT_SIZE in HT_SIZE_array:

    ht = khmer.new_counting_hash(K, HT_SIZE, N_HT)

    unique_kmer = []
    for n, record in enumerate(fasta_iter(open(filename))):
        sequence = record['sequence']
        seq_len = len(sequence)
        for n in range(0,seq_len+1-K):
            kmer = sequence[n:n+K]
            if (not ht.get(kmer)):
               unique_kmer.append(kmer) 
            ht.count(kmer)

#for kmer2 in unique_kmer:
#    print kmer2,ht.get(kmer2)
            
    ktable = khmer.new_ktable(K)
    for n, record in enumerate(fasta_iter(open(filename))):
        sequence = record['sequence']
        seq_len = len(sequence)
        for n in range(0,seq_len+1-K):
            kmer = sequence[n:n+K]
            ktable.count(kmer)

    false = 0
    all_n = 1
    for kmer2 in unique_kmer:
        if ht.get(kmer2) != ktable.get(kmer2):
	    false = false+1
        all_n = all_n +1
    fp = false*100.0/all_n
    
    print HT_SIZE, fp

 









