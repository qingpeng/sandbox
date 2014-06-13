#!/usr/bin/env python
# 1. get the test set by removing seed sequences from full dataset
# 2. get the seed fasta files for next step

seed_file = open('Pfam-A.seed','r')
full_file = open('Pfam-A.full','r')

output = open('Pfam.test.fa','w')
output_seed = open('Pfam.seed.fa','w')

block=False
seq_name_list={}
m=0
for line in seed_file:
    ##=GF AC   RF01040
    if '#=GF AC' in line:
        m+=1
        if m!=1:
                
            for key in seq.keys():
                sequence = ''.join(seq[key])
                sequence=sequence.replace('.','')
                sequence=sequence.replace('-','')
                new_seq_name = family+'__'+key
                output_seed.write('>%s\n%s\n' %(new_seq_name,sequence))            

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

for key in seq.keys():
    sequence = ''.join(seq[key])
    sequence=sequence.replace('.','')
    new_seq_name = family+'__'+key
    output_seed.write('>%s\n%s\n' %(new_seq_name,sequence))      

print "step1 over!\n"
        
m=0
for line in full_file:
    if '#=GF AC' in line:

        m+=1
        print m
        if m!=1:
            for key in seq.keys():
                sequence = ''.join(seq[key])
                sequence=sequence.replace('.','')
                sequence=sequence.replace('-','') 
                new_seq_name = family+'__'+key
                output.write('>%s\n%s\n' %(new_seq_name,sequence))           

        line=line.rstrip()
        fields = line.split()
        family = fields[2]
        top = True
        seq={}      
        
    elif (not "#" in line) and (line!='\n') and (not '//' in line):
        line=line.rstrip()
        fields = line.split()
        seq_name = fields[0]
        if (not seq_name in seq_name_list[family]):
            if top == True:
                seq[seq_name]=[]
                seq[seq_name].append(fields[1])
            else:
                seq[seq_name].append(fields[1])
    elif '#=GC SS_cons' in line:
        top = False

for key in seq.keys():
    sequence = ''.join(seq[key])
    sequence=sequence.replace('.','')
    new_seq_name = family+'__'+key
    output.write('>%s\n%s\n' %(new_seq_name,sequence))     


    
