

import sys
file_in = sys.argv[1]

file_obj = open(file_in,'r')

order = 0
coverage = []
count = 0
lines = []
for line in file_obj:
    line = line.rstrip()
    fields = line.split()
    if int(fields[0]) == order:
        coverage.append(int(fields[2]))
        lines.append(line)
    else:
        coverage.sort()
        if coverage[len(coverage)/2]>=5:
            count = count+1
            print lines
            
        coverage = []
        order = int(fields[0])
        lines = []
        
print count

        
        