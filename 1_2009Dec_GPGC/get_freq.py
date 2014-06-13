## using bloom filter to get the count of kmers
#
# hashtable size : from 1e7 
# hashtable number: 1-10


import khmer
import sys
import screed
from screed.fasta import fasta_iter

filename = sys.argv[1]

########## different hashtable size ###############
N_HT = 4
K = 12
HT_SIZE_array = [100000,200000,400000,600000,800000,1000000,1200000]

fp1 = []
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

            
    ktable = khmer.new_ktable(K)
    for n, record in enumerate(fasta_iter(open(filename))):
        sequence = record['sequence']
        seq_len = len(sequence)
        for n in range(0,seq_len+1-K):
            kmer = sequence[n:n+K]
            ktable.count(kmer)


    file_out = str(HT_SIZE)+".freq"
    file_out_obj = open(file_out,'w')
    for i in range(0, ktable.n_entries()):
        n = ktable.get(i)
        if n:
            kmer2 = ktable.reverse_hash(i)
            to_write = str(ktable.get(kmer2))+' '+str(ht.get(kmer2))+'\n'
            file_out_obj.write(to_write)
    file_out_obj.close()
    

##### diffefrent hashtable number #######
HT_SIZE = 400000
N_HT_array = [1,2,3,4,5,6,7,8,9,10]

fp2 = [] 
for N_HT in N_HT_array:

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


    ktable = khmer.new_ktable(K)
    for n, record in enumerate(fasta_iter(open(filename))):
        sequence = record['sequence']
        seq_len = len(sequence)
        for n in range(0,seq_len+1-K):
            kmer = sequence[n:n+K]
            ktable.count(kmer)

    file_out = str(N_HT)+".freq"
    file_out_obj = open(file_out,'w')
    for i in range(0, ktable.n_entries()):
        n = ktable.get(i)
        if n:
            kmer2 = ktable.reverse_hash(i)
            to_write = str(ktable.get(kmer2))+' '+str(ht.get(kmer2))+'\n'
            file_out_obj.write(to_write)
    file_out_obj.close()







