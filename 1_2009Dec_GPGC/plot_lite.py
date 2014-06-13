import matplotlib

matplotlib.use('Agg')

import matplotlib.pyplot as plt
import sys


try:
	file_in = sys.argv[1]
	file_title = sys.argv[2]
	file_x_axis = sys.argv[3]
	file_y_axis = sys.argv[4]
	fig_file = sys.argv[5]
        xlow = int(sys.argv[6])
        xhigh = int(sys.argv[7])
        ylow = int(sys.argv[8])
        yhigh = int(sys.argv[9])


except IndexError:
	print "Usage: python plot.py <file_in> <title> <x_label> <y_label> <output_figure_file> <xlow> <xhigh> <ylow> <yhigh>"
	exit()

file = open(file_in,'r')

list1 = []
list2 = []
for line in file:
	line = line.rstrip()
	fields = line.split()
	list1.append(float(fields[0]))
	list2.append(float(fields[1]))

plt.xlabel(file_x_axis)
plt.ylabel(file_y_axis)
plt.title(file_title)


	
plt.plot(list1,list2,'ro')

plt.ylim(ylow,yhigh)
plt.xlim(xlow,xhigh)

plt.savefig(fig_file)


