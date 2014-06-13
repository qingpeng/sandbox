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
fasta_file = open(sys.argv[5],'r')


#>Q197F2.1 008L_IIV3 Uncharacterized protein 008L
#MSFKVYDPIAELIATQFPTSNPDLQIINNDVLVVSPHKITLPMGPQNAGDVTNKAYVDQ
#AVMSAAVPVASSTTVGTIQMAGDLEGSSGTNPIIAANKITLNKLQKIGPKMVIGNPNSD
#WNNTQEIELDSSFRIVDNRLNAGIVPISSTDPNKSNTVIPAPQQNGLFYLDSSGRVWVW
#AEHYYKCITPSRYISKWMGVGDFQELTVGQSVMWDSGRPSIETVSTQGLEVEWISSTNF
#TLSSLYLIPIVVKVTICIPLLGQPDQMAKFVLYSVSSAQQPRTGIVLTTDSSRSSAPIV
#SEYITVNWFEPKSYSVQLKEVNSDSGTTVTICSDKWLANPFLDCWITIEEVG
#>Q91G85.1 009R_IIV6 Uncharacterized protein 009R
#MIKLFCVLAAFISINSACQSSHQQREEFTVATYHSSSICTTYCYSNCVVASQHKGLNVE
#SYTCDKPDPYGRETVCKCTLIKCHDI
seq={}

for line in fasta_file:
    if '>' in line:
        line = line.rstrip()
        fields = line.split()
        seq_name2 = fields[1]
#        print seq_name2,'\n'
        seq[seq_name2] = ''
    else:
        line = line.rstrip()
        seq[seq_name2] = seq[seq_name2]+line
        
#print seq


#for key in seq.keys():
#    print key,'\n',seq[key],'\n'
        

print "step 1 over!!\n"


m=0


for line in seed_file:
    ##=GF AC   RF01040
    if '#=GF AC' in line:
        m+=1
	#print m,'\n'
        if m!=1:
            
            count = len(name)
#            print name,"   count=",count,"\n"
                
            if count>=100:
                index=range(count)
                #print "count=",count,"\n"
#print "select_number=",select_number,"\n",index,"\n"

                random_choose_index = random.sample(index,select_number)

                for i in index:
                    if i in random_choose_index:
                        seq_name = name[i]
			#print 'name=',seq_name,'\n'
			#if seq.has_key(seq_name):
			#print 'SSSSSSSS',seq,'\n'    
			sequence = seq[seq_name]
			#print 'Seq=',sequence,'\n'
			new_seq_name = family+'__'+str(i)+'_'+seq_name
			output_target.write('>%s\n%s\n' %(new_seq_name,sequence))
                    else:
                        seq_name = name[i]
			#print 'name=',seq_name,'\n'
			#if seq.has_key(seq_name):
			#print 'SSSSSSSS',seq,'\n'
			sequence = seq[seq_name]
			#print 'Seq=',sequence,'\n'
			new_seq_name = family+'__'+str(i)+'_'+seq_name
			output_query.write('>%s\n%s\n' %(new_seq_name,sequence))
                
            
        line=line.rstrip()
        fields = line.split()
        family = fields[2]

        
        top = True
        
        

    elif (not "#" in line) and (line!='\n') and (not '//' in line):
        line=line.rstrip()
        fields = line.split()
        fields2 = fields[0].split('/')
        seq_name= fields2[0]
        if top == True:
            name = []
            name.append(seq_name)
	    top = False
        else:
            name.append(seq_name)
        
    elif '#=GC SS_cons' in line:        
        top = False
            
	    
	    
	    
	    
	    
	    
	    
	    
	    
count = len(name)
print name,"   count=",count,"\n"
    
if count>=100:
    index=range(count)
    #print "count=",count,"\n"
#print "select_number=",select_number,"\n",index,"\n"

    random_choose_index = random.sample(index,select_number)

    for i in index:
	if i in random_choose_index:
	    seq_name = name[i]
	    print 'name=',seq_name,'\n'
	    if seq.has_key(seq_name):
		    
		sequence = seq[seq_name]
		print sequence,'\n'
		new_seq_name = family+'__'+str(i)+'_'+seq_name
		output_target.write('>%s\n%s\n' %(new_seq_name,sequence))
	else:
	    seq_name = name[i]
	    print 'name=',seq_name,'\n'
	    if seq.has_key(seq_name):
		sequence = seq[seq_name]
		print sequence,'\n'
		new_seq_name = family+'__'+str(i)+'_'+seq_name
		output_query.write('>%s\n%s\n' %(new_seq_name,sequence))
    
