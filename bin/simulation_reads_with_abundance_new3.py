# according to different abundance distribution (coverage)
# 
import random





def generate_reads(genome,coverage,length):
	size = len(genome)	
	number_of_reads = int(size*coverage/length)
	size_list = range(0,size-length)
	count = 0
	reads = []
	
	while count<number_of_reads:
		start = random.choice(size_list)
		read = genome[start:start+length]
		reads.append(read)
		count = count+1
	return reads


def combine_reads(distribution,coverage,genome_strs):
	coverages = [dis*coverage for dis in distribution] # fix bug 
	
	read_length = 75
	total_reads = []
	for i in range(5):
		genome = genome_strs[i]
		reads = generate_reads(genome,coverages[i],read_length)
		total_reads.extend(reads)
	
	random.shuffle(total_reads)
	return total_reads
	
	
def write_reads(reads,file_name):
	fileOb = open(file_name,'w')
	n = 0
	for read in reads:
		n = n+1
		fileOb.write('>%s\n%s\n' %(n,read))
	fileOb.close()		




	


def read_genomes(genome_files):
    
    genome_strs = []
    for i in range(5):
        file_handle = open(genome_files[i],'r')
        genome_str = ""
        for line in file_handle:
            line = line.rstrip()
            if len(line)>=1 and line[0]!=">":
                genome_str = genome_str + line
        genome_strs.append(genome_str)

    return genome_strs


genome_files1 = ["Lactococcus_IL1403.fasta","Lactobacillus_casei.fasta","Lactobacillus_brevis.fasta","Acidothermus_cellulolyticus.fasta","Halobacteriu_sp.fasta"]
genome_files2 = ["Lactococcus_IL1403.fasta","Pediococcus.fasta","Shewanella_amazonensis_SB2B.fasta","Myxococcus_xanthus.fasta","Saccharomyces_cerevisiae.fasta"]
genome_strs1 = read_genomes(genome_files1)
genome_strs2 = read_genomes(genome_files2)

#distribution1 = [3,3,3,3,3]
#distribution2 = [1,2,3,4,5]
#distribution3 = [0.484,0.968,1.935,3.871,7.742]# 15*1/31  

#11345, 12355, 15555, 11115

distribution1 = [15*1.0/14, 15*1.0/14, 15*3.0/14, 15*4.0/14, 15*5.0/14]
distribution2 = [15*1.0/16, 15*2.0/16, 15*3.0/16, 15*5.0/16, 15*5.0/16]
distribution3 = [15*1.0/21, 15*5.0/21, 15*5.0/21, 15*5.0/21, 15*5.0/21]
distribution4 = [15*1.0/9,  15*1.0/9,  15*1.0/9,  15*1.0/9,  15*5.0/9]
distribution5 = [15*1.0/5,  15*1.0/5,  15*1.0/5,  15*1.0/5,  15*1.0/5]
distribution6 = [15*1.0/15, 15*2.0/15, 15*3.0/15, 15*4.0/15, 15*5.0/15]
distribution7 = [15*1.0/31, 15*2.0/31, 15*4.0/31, 15*8.0/31, 15*16.0/31]

distributions = [distribution1,distribution2,distribution3,distribution4,distribution5,distribution6,distribution7]
coverage1 = 1
#coverage2 = 5

for i in range(7):
    distribution = distributions[i]
    reads = combine_reads(distribution,coverage1,genome_strs1)
    output_file = "reads_genome1_distribution_"+str(i)+".fa"
    write_reads(reads,output_file)

for i in range(7):
    distribution = distributions[i]
    reads = combine_reads(distribution,coverage1,genome_strs2)
    output_file = "reads_genome1_distribution_"+str(i)+".fa"
    write_reads(reads,output_file)