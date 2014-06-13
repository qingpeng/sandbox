#!/usr/bin/env python
import sys

#
#
#RF00002__AY825522.1/156-2	RF00002__M36008.1/959-1112	100.00	17	0	0	33	49	33	49	0.022	34.2
#RF00002__AY825522.1/156-2	RF00002__AF158725.1/345-497	100.00	17	0	0	61	77	61	77	0.022	34.2
#RF00002__AY825522.1/156-2	RF00002__M63701.1/247-415	84.09	44	7	0	37	80	38	81	0.088	32.2
#RF00002__AY825522.1/156-2	RF00002__M63701.1/247-415	100.00	16	0	0	93	108	93	108	0.088	32.2
#RF00002__AY825522.1/156-2	RF00002__AF306774.1/466-634	84.09	44	7	0	37	80	38	81	0.088	32.2
#RF00002__AY825522.1/156-2	RF00002__Y00055.1/4327-4494	100.00	16	0	0	93	108	93	108	0.088	32.2
#RF00002__AY825522.1/156-2	RF00002__U58510.1/2022-2198	87.50	32	4	0	14	45	13	44	0.088	32.2
#RF00002__AY082118.1/145-300	RF00002__X15589.1/256-410	96.15	156	5	1	1	156	1	155	1e-68	 254
#RF00002__AY082118.1/145-300	RF00002__AF307619.1/287-442	94.87	156	8	0	1	156	1	156	3e-66	 246
#RF00002__AY082118.1/145-300	RF00002__AF169230.1/225-380	94.23	156	9	0	1	156	1	156	8e-64	 238
#RF00002__AY082118.1/145-300	RF00002__D10840.1/200-355	94.23	156	9	0	1	156	1	156	8e-64	 238
#RF00002__AY082118.1/145-300	RF00002__AF223066.1/5881-6030	93.59	156	4	1	1	156	1	150	5e-62	 232
#RF00002__AY082118.1/145-300	RF00002__X66325.1/2369-2523	92.31	156	11	1	1	156	1	155	3e-54	 206
#RF00002__AY082118.1/145-300	RF00002__X80212.2/2104-2256	90.60	117	11	0	2	118	2	118	9e-36	 145

inputfile=sys.argv[1]
testfile = sys.argv[2]
outputfile = sys.argv[3]
last_query = sys.argv[4]

input = open(inputfile,'r')

test_file = open(testfile,'r')

#>RF00002__DQ091621.1/256-411
#GACUCUCGACAAUGGAUAUCUCGGCUCUCGCAUCGAUGAAGAGCGCAGCGAAAUGCGAUACGUGGUGCGAAUUGCAGAAUCCCGCGAACCAUCGAGUCUUUGAACGCAAGUUGCGCCCGAGGCCAACCGGCCGAGGGCACGUCCGCCUGGGCGUCA
#>RF00002__AY351997.1/216-371
#GACUCUCGGCAAUGGAUAUCUCGGCUCUUGCAUCGAUGAAGAACGUAGUGAAAUGCGAUACUUGGUGUGAAUUGCAGAAUCUCGUGAACCAUUGAGUCUUUGAACGCAAGUUGUGCCCGAGGCCUUGUGGUCGAGGGCACGCCUGCUUGGGCGUCA
#>RF00002__AF309167.1/222-377
#GACUCUCGGCAACGGAUAUCUCGGCUCUCGC

# get the number of seqeunces in each family
number_of_sequence={}

for line in test_file:
    if '>' in line:
        line=line.rstrip()
        fields = line.split('>')
        query = fields[1]
        if query == last_query:
            print "here\n"
            break
        fields = query.split('__')
        family = fields[0]

        if family in number_of_sequence:
            number_of_sequence[family]+=1
        else:
            number_of_sequence[family]=1


        
log=open('sequence_number.log','w')

for family in number_of_sequence.keys():
    log.write('%s %s\n' %(family,number_of_sequence[family]))
    
print "Step1 over!\n"


log2=open('run.log','w')


last_query_name = 'start'

dict_target_sequence_name={}

positive_in_family={}
negative_in_family={}



for line in input:
    line = line.rstrip()
    fields = line.split()
    if len(fields)<2:
        break
    query_sequence_name = fields[0]

    target_sequence_name = fields[1]
    #query_fields = query_sequence_name.split('__')
    #target_fields = target_sequence_name.split('__')
    if (query_sequence_name != last_query_name) and (last_query_name !='start'):
        log2.write('%s\n' %(query_sequence_name))
        
        list_target_sequence_name = dict_target_sequence_name.keys()
        count={}
        for target_sequence in list_target_sequence_name:
            target_fields = target_sequence.split('__')
            target_family = target_fields[0]
            if target_family in count:
                count[target_family]+=1
            else:
                count[target_family]=1
        
        top_count = 0
        for family in count.keys():
            if count[family] > top_count:
                top_count = count[family]
                top_family = family
        
        query_family = last_query_name.split('__')[0]
        if top_family == query_family:
            if query_family in positive_in_family:
                positive_in_family[query_family]+=1
            else:
                positive_in_family[query_family]=1
        else:
            if query_family in negative_in_family:
                negative_in_family[query_family]+=1
            else:
                negative_in_family[query_family]=1
        
        dict_target_sequence_name={}   

    dict_target_sequence_name[target_sequence_name]=1
   
        
    last_query_name = query_sequence_name    
        


# deal with last block

list_target_sequence_name = dict_target_sequence_name.keys()
count={}
for target_sequence in list_target_sequence_name:
    target_fields = target_sequence.split('__')
    target_family = target_fields[0]
    if target_family in count:
        count[target_family]+=1
    else:
        count[target_family]=1

top_count = 0
for family in count.keys():
    if count[family] > top_count:
        top_count = count[family]
        top_family = family

query_family = last_query_name.split('__')[0]
if top_family == query_family:
    if query_family in positive_in_family:
        positive_in_family[query_family]+=1
    else:
        positive_in_family[query_family]=1
else:
    if query_family in negative_in_family:
        negative_in_family[query_family]+=1
    else:
        negative_in_family[query_family]=1

dict_target_sequence_name={}   









all_family = number_of_sequence.keys()
#all_family=['RF00002','RF00003','RF00004']


output = open(outputfile,'w')
for family in all_family:
    if not family in positive_in_family:
        positive_in_family[family]=0
    if not family in negative_in_family:
        negative_in_family[family]=0
        
    no_hit = number_of_sequence[family] - positive_in_family[family] - negative_in_family[family]
    output.write('%s %s %s %s\n' %(family, positive_in_family[family],negative_in_family[family],no_hit))
    #print family,positive_in_family[family],negative_in_family[family]



        
