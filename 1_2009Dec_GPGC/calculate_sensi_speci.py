#true positive: 8731411
#true negative: 77781153
#false positive: 9082644
#false negative: 4690722

import sys

file_in = sys.argv[1]

file_in_obj = open(file_in,'r')

for line in file_in_obj:
    line = line.rstrip()
    fields = line.split()
    if 'true positive' in line:
        tp = fields[2]
    elif 'true negative' in line:
        tn = fields[2]
    elif 'false positive' in line:
        fp = fields[2]
    elif 'false negative' in line:
        fn = fields[2]


sensi = float(tp)/(int(tp)+int(fn))
speci = float(tn)/(int(tn)+int(tp))

print "sensi"
print sensi
print "speci"
print speci


