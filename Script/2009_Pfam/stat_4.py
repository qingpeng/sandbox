#!/usr/bin/env python
# to evaluate the relation between sequence similarity and classification accuracy

# family.txt
#Name	Accession	No.seed	Av.len(seed)	Av.%id(seed)	No.full	Av.len(full)	Av.%id(full)	Type	Description
#isrD	RF01388	2	51	100	17	51	100	Gene; sRNA;	isrD Hfq binding RNA
#CRISPR-DR52	RF01365	2	37	100	50	37	100	Gene; CRISPR;	CRISPR RNA direct repeat element
#CRISPR-DR45	RF01354	3	24	100	290	24	100	Gene; CRISPR;	CRISPR RNA direct repeat element
#CRISPR-DR29	RF01340	2	37	100	23	37	100	Gene; CRISPR;	CRISPR RNA direct repeat element
#
# analysis.result

#RF00921 13 0 0
#RF01315 2931 49 0
#RF01268 23 0 0
#RF01209 16 0 0
#RF01064 2 0 0
#RF01286 24 0 0
#RF01380 1537 0 0
#RF00708 61 0 22
#RF00709 37 0 0
#RF01372 13 1 0

input1 = open('Pfam.table','r')
input2 = open('all.result','r')

ratio = {}

for line in input2:
    line = line.rstrip()
    fields = line.split()
    n_fields = fields[0].split(".")
    correct_ratio = float(fields[1])/(float(fields[1])+float(fields[2])+float(fields[3]))
    ratio[n_fields[0]] = correct_ratio
    

#print ratio

out = open('relation4.txt','w')

sum={}
count={}


for line in input1:
    line = line.rstrip()
    fields = line.split()
    
    #bin = ((fields[7]-1)//10)*10
    if fields[1] in ratio:
#        print fields[7]
        look = fields[4]
#        print fields[1]
        look = str(int(float(look)))
        print look
        if look in sum:
            print "A\n"
            sum[look]+=ratio[fields[1]]
  #          print fields[7],sum[fields[7]]
            count[look]+=1
        else:
            print "B\n"
            sum[look]=ratio[fields[1]]
            count[look]=1
#print 'abc\n'
#print sum['99']

#print sum
#quit()
#print count
for i in range(50000):
 #   print 'cde\n'
    if str(i) in sum:
        print 'fff\n'
        average_ratio = sum[str(i)]*100/count[str(i)]
        print average_ratio
        print i
        out.write('%d %f\n' %(i,average_ratio))

        

    

