import matplotlib.pyplot as plt
import sys

try:
	file_in = sys.argv[1]
	file_title = sys.argv[2]
	file_x_axis = sys.argv[3]
	file_y_axis = sys.argv[4]
	y_total = sys.argv[5]
	fig_file = sys.argv[6]

except IndexError:
	print "Usage: python plot.py <file_in> <title> <x_label> <y_label> <y_total> <output_figure_file>"
	exit()

file = open(file_in,'r')

list1 = []
list2 = []
for line in file:
	line = line.rstrip()
	fields = line.split()
	list1.append(int(fields[0]))
	list2.append(int(fields[1])*100/float(y_total))

figure = plt.xlabel(file_x_axis)
figure = plt.ylabel(file_y_axis)
figure = plt.title(file_title)

figure = plt.plot(list1,list2,'ro')

figure.savefig(fig_file)


