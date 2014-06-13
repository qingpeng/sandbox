import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


#file_in1 = sys.argv[1]
file_in1 = "I200_s_2.fq.median.count"

#file_in2 = sys.argv[2]
file_in2 = "I200_s_23456.fq.median.count"
#file_out = sys.argv[3]
plot_file = "I200_s_2_vs_23456.fq.median.count.x5-20.png"

file_in1_obj = open(file_in1,'r')
file_in2_obj = open(file_in2,'r')

x_list = []
y1_list = []
y2_list = []

for line in file_in1_obj:
    line = line.rstrip()
    fields = line.split()
    x_list.append(fields[0])
    y1_list.append(fields[1])
    
for line in file_in2_obj:
    line = line.rstrip()
    fields = line.split()
    y2_list.append(fields[1])

plt.xlabel("median k-mer coverage")
plt.ylabel("number of reads")
plt.title("Coverage of Rumen data set")

plt.plot(x_list,y1_list,'ro-',x_list,y2_list,'bo-')
plt.legend(('20 million reads','100 million reads'),)
plt.xlim(5,20)
plt.ylim(0,0.5e7)

plt.savefig(plot_file)

    
