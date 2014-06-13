## using bloom filter to count intersection

# Aug. 4th.
# add output file
# add error input


import khmer
import sys
import screed
from screed.fasta import fasta_iter

try:
    filename = sys.argv[1]# 1st database file
    K = int(sys.argv[2]) # size of kmer
    HT_SIZE= int(sys.argv[3])# size of hashtable
    N_HT = int(sys.argv[4]) # number of hashtables
    filename2 = sys.argv[5]# 2nd database file
    file_result = sys.argv[6]# general result of intersection




except IndexError:
    print "Usage: python bloom_count_intersection_v1.1.py <1st_dataset_file> <K_size> <Hashtable_size> <Hashtable_number> <2nd_dataset_file> <general_intersection_result>"
    exit()



file_result_object = open(file_result,'w')


ht = khmer.new_hashbits(K, HT_SIZE, N_HT)

n_unique = 0
for n, record in enumerate(fasta_iter(open(filename))):
    sequence = record['sequence']
    seq_len = len(sequence)
    for n in range(0,seq_len+1-K):
        kmer = sequence[n:n+K]
        if (not ht.get(kmer)):
            n_unique+=1
        ht.count(kmer)
print filename,'has been consumed.'        
print '# of unique kmers:',n_unique
print '# of occupied bin:',ht.n_occupied()
printout = filename+":"+'\n'
printout =  printout+'# of unique kmers:'+str(n_unique)+'\n'
printout = printout + '# of occupied bin:'+str(ht.n_occupied())+'\n'



ht2 = khmer.new_hashbits(K, HT_SIZE, N_HT)
n_unique = 0
n_overlap = 0
for n, record in enumerate(fasta_iter(open(filename2))):
    sequence = record['sequence']
    seq_len = len(sequence)
    for n in range(0,seq_len+1-K):
        kmer = sequence[n:n+K]
        if (not ht2.get(kmer)):
            n_unique+=1
            if (ht.get(kmer)):
                n_overlap+=1
        ht2.count(kmer)
        
print filename2,'has been consumed.'        
print '# of unique kmers:',n_unique
print '# of occupied bin:',ht2.n_occupied()

print n_overlap,'unique kmers appears in both ',filename,' and ',filename2


printout = printout+filename2+":"+'\n'
printout =  printout+'# of unique kmers:'+str(n_unique)+'\n'
printout = printout + '# of occupied bin:'+str(ht2.n_occupied())+'\n'
printout = printout + '# of overlap unique kmers:' + str(n_overlap) + '\n'

file_result_object.write(printout)





