import sys
import random


file_in  = sys.argv[1]
file_out = sys.argv[2]
read_length = int(sys.argv[3])
coverage = int(sys.argv[4])




filein = open(file_in,'r')
fileout = open(file_out,'w')

fasta = ''
for line in filein:
    line = line.rstrip()
    if line[0] !='>':
        fasta = fasta+line
    
length = len(fasta)
num = length*coverage/read_length
print num
print length
print read_length

r=random.sample(xrange(length),num)

for i in r:
    seq = fasta[i:i+read_length]+'\n'
#    print seq
    head = '>'+str(i)+'\n'
    
#    print head
    fileout.write(head)
    fileout.write(seq)
    
    

    