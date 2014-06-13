
from matplotlib import *
from pylab import *

#5000000 255867978
#10000000 512686242
#15000000 773374479
#20000000 1028674307
#25000000 1283431144
#30000000 1528602094
#35000000 1761287081
#40000000 1997447125
#45000000 2241013711


file_in = sys.argv[1]
#f1= csv.reader(open(file_in,'r'))
f1=open(file_in,'r')
t=[]
data=[]
last_number = 0
for line in f1:
    line = line.rstrip()
#    print line
    fields = line.split()
#    print fields
#    print fields[0],fields[1]
    #print fields
    
    increase_number = float(fields[1])-last_number
    print increase_number
    t.append(float(fields[0]))
    data.append(increase_number/5000000)
    last_number = int(fields[1])
    
    

print t
print data

plot(t,data,'ro')

#for i in range(90):
#    print t[i],data[i],datafit[i],guessfit[i]

xlabel('# of consumed reads')
ylabel('# of novel kmers in every read')
title(sys.argv[2])
grid(True)
show()