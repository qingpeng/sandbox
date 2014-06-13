
import sys
file_in = sys.argv[1]

file_obj = open(file_in,'r')

count = [0]*100000

for line in file_obj:
    line = line.rstrip()
    fields = line.split()
    count[int(fields[1])] = count[int(fields[1])]+1
 
for n, i in enumerate(count):
    print n, i

        
