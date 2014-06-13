import sys


#qingpeng@lyorn:/scratch/qingpeng/2_Khmer_Paper/0_Check_Math$ more 200000.freq
#3 12
#3 18
#3 14
#3 18
#5 12
#5 18
#3 12
#3 11

file_in = sys.argv[1]
file_out = sys.argv[2]

file_in_obj = open(file_in,'r')
file_out_obj = open(file_out,'w')

total_count = 0
hash_diff = {}
count_kmer = 0
for line in file_in_obj:
    count_kmer = count_kmer + 1
    line = line.rstrip()
    fields = line.split()
    total_count = total_count + int(fields[0])
    difference = int(fields[1]) - int(fields[0])
    if difference in hash_diff:
        hash_diff[difference] = hash_diff[difference] + 1
    else:
        hash_diff[difference] = 1
    
max_diff = max(hash_diff.keys())
print total_count
print max_diff
to_write = "total_count: "+str(total_count)+'\n'
file_out_obj.write(to_write)

count = 0
for i in range(max_diff):
    if i in hash_diff:
        count = count+hash_diff[i]
        
    perc = count*100.0/count_kmer
    to_write = str(i)+' '+str(count)+' '+str(perc)+'\n'
    file_out_obj.write(to_write)
count = count+hash_diff[max_diff]
perc = count*100.0/count_kmer
to_write = str(max_diff)+' '+str(count)+' '+str(perc)+'\n'
file_out_obj.write(to_write)




