import sys
file_in = sys.argv[1]

filein_obj = open(file_in,'r')
hash_length = {}
for line in filein_obj:
	line = line.rstrip()
	if line[0] != ">":

		length = len(line)
		if length in hash_length:
			hash_length[length] +=1
		else:
			hash_length[length] = 1

for key in hash_length.keys():
	print key, hash_length[key]


