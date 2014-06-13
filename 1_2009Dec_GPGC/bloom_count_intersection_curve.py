## using bloom filter to count intersection
# generate the curve~
#
# v3: add usage information 03-28-2011


import khmer
import sys
import screed
from screed.fasta import fasta_iter

try:
    filename = sys.argv[1] # 1st database file
    K = int(sys.argv[2]) # size of kmer
    HT_SIZE= int(sys.argv[3])# size of hashtable
    N_HT = int(sys.argv[4]) # number of hashtables
    filename2 = sys.argv[5] # 2nd database file
    filename3 = sys.argv[6] # output file for curve
    file_result = sys.argv[7] # general result of intersection



except IndexError:
    print "Usage: python bloom_count_intersection_curve.py <1st_dataset_file> <K_size> <Hashtable_size> <Hashtable_number> <2nd_dataset_file> <output_for_curve> <general_intersection_result>"
    exit()

count = 0
for n, record in enumerate(fasta_iter(open(filename2))):
    count = count+1

max_count = count/100
#max_count = 100000
print count
print max_count


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
printout = filename+":"+'\n'
printout =  printout+'# of unique kmers:'+str(n_unique)+'\n'
printout = printout + '# of occupied bin:'+str(ht.n_occupied())+'\n'


file_result_object = open(file_result,'w')



ht2 = khmer.new_hashbits(K, HT_SIZE, N_HT)
n_unique = 0
n_overlap = 0

seq_count = 0
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
    seq_count = seq_count + 1
    
    if seq_count == max_count:
        #n_occu = ht2.n_occupied
        string = str(n_unique)+' '+str(n_overlap)+'\n'
        file3 = open(filename3,'a')
        file3.write(string)
        file3.close()
        seq_count = 0
        
        
print filename2,'has been consumed.'

printout = printout+filename2+":"+'\n'
printout =  printout+'# of unique kmers:'+str(n_unique)+'\n'
printout = printout + '# of occupied bin:'+str(ht2.n_occupied())+'\n'
printout = printout + '# of overlap unique kmers:' + str(n_overlap) + '\n'


file_result_object.write(printout)





