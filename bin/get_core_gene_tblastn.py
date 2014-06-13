import sys
import screed


core_file = sys.argv[1]
align_file = sys.argv[2]
out_file = sys.argv[3]
out_obj =open(out_file,'w')

leng = {}
for n, record in enumerate(screed.open(core_file)):
    sequence = record['sequence']
    length = len(sequence)
    name=record['name']
    leng[name] = length

fo = open(align_file,'r')
for line in fo:
    line = line.rstrip()
    fields = line.split()
    print line
    perc =float(abs(int(fields[7])-int(fields[6]))/float(leng[fields[0]]))
    print fields[2],perc,leng[fields[0]]

    if float(fields[2])>30 and perc>0.6 :
        to_print = fields[0]+'\n'
        out_obj.write(to_print)
        print fields[0]
       


