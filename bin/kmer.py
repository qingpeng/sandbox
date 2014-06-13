import sys
file_name = sys.argv[1]

fh = open (file_name,'r')
k=20
hash = {}
count = 0
for line in fh:
    if '>' not in line:
        line = line.rstrip()
        length = len(line)
        for i in range(0,length-k):
            kmer = line[i:i+k]
            if kmer not in hash:
                count +=1
                hash[kmer] = 1
            else:
                hash[kmer] = hash[kmer]+1
            
keys = hash.keys()
print keys
print count
print hash