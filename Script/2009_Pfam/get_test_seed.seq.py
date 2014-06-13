#!/usr/bin/env python
import sys
import random


#seed_file =sys.argv[1]
#output_query = sys.argv[2]
#output_target = sys.argv[3]
select_number = int(sys.argv[4])

seed_file = open(sys.argv[1],'r')
output_query = open(sys.argv[2],'w')
output_target = open(sys.argv[3],'w')

#full_file = open('Rfam.full','r')

#output = open('Rfam.test.fa','w')
#output_seed = open('Rfam.seed.fa','w')

block=False
seq_name_list={}
m=0


for line in seed_file:
    ##=GF AC   RF01040
    if '#=GF AC' in line:
        m+=1
        if m!=1:
            count = 0
            new_seq=[]
            for key in seq.keys():
                sequence = ''.join(seq[key])
                sequence=sequence.replace('.','')
                new_seq.append(sequence)
                count = count+1
             #   new_seq_name = family+'__'+count
              #  new_seq[new_seq_name] = sequence
#                output_seed.write('>%s\n%s\n' %(new_seq_name,sequence))            
            if count>=100:
                index=range(count)
                #print "count=",count,"\n"
		#print "select_number=",select_number,"\n",index,"\n"
                random_choose_index = random.sample(index,select_number)

                for i in index:
                    if i in random_choose_index:
                        new_seq_name = family+'__'+str(i)
                        output_query.write('>%s\n%s\n' %(new_seq_name,new_seq[i]))
                    else:
                        new_seq_name = family+'__'+str(i)
                        output_target.write('>%s\n%s\n' %(new_seq_name,new_seq[i]))
                
            
        line=line.rstrip()
        fields = line.split()
        family = fields[2]
        seq_name_list[family]=[]
        
        top = True
        seq={}
        

    elif (not "#" in line) and (line!='\n') and (not '//' in line):
        line=line.rstrip()
        fields = line.split()
        seq_name = fields[0]
        if top == True:
            seq[seq_name]=[]
            seq[seq_name].append(fields[1])
            seq_name_list[family].append(seq_name)
        else:
            seq[seq_name].append(fields[1])
        
    elif '#=GC SS_cons' in line:        
        top = False
    

        
count = 0
new_seq=[]
for key in seq.keys():
    sequence = ''.join(seq[key])
    sequence=sequence.replace('.','')
    new_seq.append(sequence)
    count = count+1
 #   new_seq_name = family+'__'+count
  #  new_seq[new_seq_name] = sequence
#                output_seed.write('>%s\n%s\n' %(new_seq_name,sequence))            
if count>=100:
    index=range(count)
    random_choose_index = random.sample(index,select_number)

    for i in index:
        if i in random_choose_index:
            new_seq_name = family+'__'+str(i)
            output_query.write('>%s\n%s\n' %(new_seq_name,new_seq[i]))
        else:
            new_seq_name = family+'__'+str(i)
            output_target.write('>%s\n%s\n' %(new_seq_name,new_seq[i]))
