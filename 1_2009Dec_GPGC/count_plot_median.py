import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


file_in = sys.argv[1]

file_in_obj = open(file_in,'r')
file_out = file_in+'.count'
file_out_obj = open(file_out,'w')

count = [0]*100

for line in file_in_obj:
    line = line.rstrip()
    fields = line.split()
    #print fields[1]
    if int(fields[1]) <100:
        count[int(fields[1])] = count[int(fields[1])] + 1
    
x_list = []
y_list = []

for i in range(100):
    x_list.append(i)
    y_list.append(count[i])
    to_print = str(i)+' '+str(count[i])+'\n'
    file_out_obj.write(to_print)

plt.xlabel("median k-mer coverage")
plt.ylabel("number of reads")
plt.title("N/A")

plt.plot(x_list,y_list,'ro')

plot_file = file_out+'.png'
plt.savefig(plot_file)

    
