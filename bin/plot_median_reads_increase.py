import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


file_in = sys.argv[1]

file_in_obj = open(file_in,'r')

x_list = []
y1_list = []
y2_list = []
y3_list = []
y4_list = []
y5_list = []


for line in file_in_obj:
    line = line.rstrip()
    fields = line.split()
    #print fields[1]
    x_list.append(fields[0])
    y1_list.append(fields[1])
    y2_list.append(fields[2])
    y3_list.append(fields[3])
    y4_list.append(fields[4])
    y5_list.append(fields[5])


plt.xlabel("number of consumed reads")
plt.ylabel("number of reads with coverage")
plt.title("median k-mer coverage")

plt.plot(x_list,y1_list,'ro-',x_list,y2_list,'bo-',x_list,y3_list,'go-',x_list,y4_list,'yo-',x_list,y5_list,'bo-')
plt.legend(('coverage=1','coverage=2','coverage=3','coverage=4','coverage=5'),)


plot_file = file_in+'.png'
plt.savefig(plot_file)

    
