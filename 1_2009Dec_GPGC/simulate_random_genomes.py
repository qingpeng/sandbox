import random
import sys
random.seed(0) # Reproducibility, FTW

# simulation reads with certain coverage and error rate from a random generated genome


#
## construct a random genome
def construct_genome(length):
    N=length/4
    genome = "A"*N + "C"*N + "G"*N + "T"*N
    genome = list(genome)
    random.shuffle(genome)
    genome = "".join(genome)
    return genome

for i in range(1,221):
    file_name = 'random_genome_'+ str(i)+'.fa'
    fw = open(file_name,'w')
    fw.write(">"+'random_genome_'+str(i)+'\n')
    print i
    genome_str = construct_genome(1000000)
    for i in range(0,1000000,80):
        bases = genome_str[i:i+80]
        line = "".join(bases)
        fw.write(line+'\n')
    fw.close()
