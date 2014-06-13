# pick percentage% randomly from a fasta file

#


import sys
filename = sys.argv[1]

outname = sys.argv[2]

f1 = open(filename,'r')
f2 = open(outname,'w')

for line in f1:
    if line[1] in 'ACTG':
        newline = line[1:]
        f2.write(newline)
    else:
        f2.write(line)
        


