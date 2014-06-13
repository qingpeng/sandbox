import sys
import matplotlib

matplotlib.use('Agg')

import matplotlib.pyplot as plt


file_in = sys.argv[1]

file_in_obj = open(file_in,'r')
hist = {}
sum_reads = 0
x_list = []
y_list1 = []
y_list2 = []


for line in file_in_obj:
    line = line.rstrip()
    fields = line.split()
    sum_reads = sum_reads + int(fields[1])
    hist[int(fields[0])] = int(fields[1])

maxk = max(hist.keys())

y_accu = 0
accu = 0
for i in range(maxk+1):
    x_list.append(i)
    accu = accu + hist[i]
    y_accu = accu*100.0/sum_reads
    y_list2.append(y_accu)
    y_list1.append(hist[i])



plt.subplot(211)

plt.xlabel('Median k-mer Coverage in read')
plt.ylabel('% of cumulative Reads')
plt.title('Hist of reads')

plt.plot(x_list,y_list2,'ro-')
plt.xlim(0,40)



plt.subplot(212)
plt.xlabel('Median k-mer Coverage in read')
plt.ylabel('number of Reads')
	
plt.plot(x_list,y_list1,'ro-')
plt.xlim(0,40)
	

fig_file = file_in+'.png'

plt.savefig(fig_file)





