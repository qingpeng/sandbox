#!/usr/bin/env python
import sys
import random
import screed


filein = sys.argv[1]
fileout = sys.argv[2]
num_to_choose = int(sys.argv[3])

fw = open(fileout,'w')





db=screed.ScreedDB(filein)
names = db.keys()

size = len(names)




print size
print num_to_choose
to_choose_list = random.sample(range(size),num_to_choose)
#to_choose_list = random.sample(xrange(2000),200)


for i in to_choose_list:
    record = db.loadRecordByIndex(i)
    fw.write('>'+str(record.name)+'\n')
    fw.write(str(record.sequence)+'\n')
    #print record.name
    #print record.sequence

