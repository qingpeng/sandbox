import sys
file_in = sys.argv[1]

in_obj = open(file_in,'r')

count1 = 0
count2 = 0
for line in in_obj:
    line = line.rstrip()
    
    fields = line.split()
    if int(fields[0]) == 1:
        count1 = int(fields[1])
    elif int(fields[0]) == 2:
        count1 = count1 + int(fields[1])
    else:
        count2 = count2 + int(fields[1])
        
print count1
print count2


        
        
        