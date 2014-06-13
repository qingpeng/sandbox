#!/usr/bin/env python
import sys
file_in = sys.argv[1]
f1 = open(file_in,'r')

number_of_reads = {}

last_file_name = 0
last_freq = 0
for line in f1:
	line = line.rstrip()
	fields = line.split()
	file_name =fields[0]
	if file_name == last_file_name:
		if int(fields[2])>last_freq:
			last_freq = int(fields[2])
	else:
		if not last_freq == 0:
			if last_freq in number_of_reads:
				number_of_reads[last_freq] = number_of_reads[last_freq]+1
			else:
				number_of_reads[last_freq] = 1
		last_file_name = fields[0]
		last_freq = 0

		
if last_freq in number_of_reads:
		number_of_reads[last_freq] = number_of_reads[last_freq]+1
	else:
		number_of_reads[last_freq] = 1

