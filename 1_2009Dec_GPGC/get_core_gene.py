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
    perc =float(abs(int(fields[9])-int(fields[8]))/float(leng[fields[1]]))
    print fields[2],perc,leng[fields[1]]

    if float(fields[2])>30 and perc>0.3:
        to_print = fields[1]+'\n'
        out_obj.write(to_print)

    
        print fields[1]
       


