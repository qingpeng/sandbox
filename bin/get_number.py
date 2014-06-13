#fig|6666666.20750.peg.1307      fig|6666666.20450.peg.2703      40.00   40      24      0       64      183     34      153     1e-19   32.7
#fig|6666666.20750.peg.1307      fig|6666666.20450.peg.1173      39.08   87      53      0       406     666     352     612     5e-19   72.1

#>fig|6666666.20450.peg.2
#MNCRKVGNGLPALKYLSRYLYRGVLHDQNIIGEKDGEIICKYRKNTAPVLCLYSTHPVSFATCLT

file_1 = open("Ofp1_A.faa",'r')
file_2 = open("Ofp2.faa",'r')

genome15 = [1,3,4,5,6,9,10,11,14,16,17,18]
gene_1 = {}
for line in file_1:
    if ">" in line:
        line_list = line.rstrip().split('>')
        gene_1[line_list[1]]=1


gene_2 = {}
for line in file_2:
    if ">" in line:
        line_list = line.rstrip().split('>')
        gene_2[line_list[1]]=1


list1_17 = {}
list2_17 = {}

file1_17 = open("Ofp1_A_against_17.blastp.m8",'r')
file2_17 = open("Ofp2_against_17.blastp.m8",'r')

e=1e-12

for line in file1_17:
    line_list = line.rstrip().split()
    if float(line_list[10])<e:
        list1_17[line_list[0]]=1


for line in file2_17:
    line_list = line.rstrip().split()
    if  float(line_list[10])<e:
        list2_17[line_list[0]]=1
        



count_gene1={}
count_gene2={}

for g in genome15:
    file1_blastp = "Ofp1_A_against_"+str(g)+'.blastp.m8'
    file2_blastp = "Ofp2_against_"+str(g)+'.blastp.m8'
    file_1 = open(file1_blastp,'r')
    for line in file_1:
        line_list = line.rstrip().split()
        if float(line_list[10])<e:
            if line_list[0] in count_gene1:
                count_gene1[line_list[0]] +=1
            else:
                count_gene1[line_list[0]] = 1
   

        
    file_2 = open(file2_blastp,'r')
    for line in file_2:
        line_list = line.rstrip().split()
        if float(line_list[10])<e:
            if line_list[0] in count_gene2:
                count_gene2[line_list[0]] +=1
            else:
                count_gene2[line_list[0]] = 1


    
file_1_2 = open("Ofp1_A_against_Ofp2.blastp.m8",'r')
file_2_1 = open("Ofp2_against_Ofp1_A.blastp.m8",'r')


    
list1_2 = {}
list2_1 = {}

for line in file_1_2:
    line_list = line.rstrip().split()
    if float(line_list[10])<e:
        list1_2[line_list[0]]=1
        

for line in file_2_1:
    line_list = line.rstrip().split()

    if len(line_list)>=11 and float(line_list[10])<e:
        list2_1[line_list[0]]=1



anno1=open("Ofp1_A.tsv",'r')
anno2=open("Ofp2.tsv",'r')

a1={}
a2={}

for line in anno1:
    line_list = line.rstrip().split()
    a1[line_list[-1]]=line


for line in anno2:
    line_list = line.rstrip().split()
    a2[line_list[-1]]=line


n_1_in_17 = 0
n_1_in_more = 0
n_1_in_2 = 0
n_1_unique = 0
n_1_in_2_dict=[]
n_1_unique_dict=[]


for gene in gene_1.keys():
    if gene in list1_17 and count_gene1[gene]==1:
        n_1_in_17 += 1

    if gene in count_gene1 and count_gene1[gene]>1:
        n_1_in_more +=1

    if not gene in count_gene1:
        
        if gene in list1_2:
            n_1_in_2 += 1
            n_1_in_2_dict.append(gene)
        else:
            n_1_unique += 1
            n_1_unique_dict.append(gene)

n_1_in_2_file = open("n_1_in_2_file.list",'w')
for n in n_1_in_2_dict:
    if n in a1:
        n_1_in_2_file.write(n+'\t'+a1[n]+'\n')

n_1_unique_file = open("n_1_unqiue_file.list",'w')
for n in n_1_unique_dict:
    if n in a1:
        n_1_unique_file.write(n+'\t'+a1[n]+'\n')


n_2_in_17 = 0
n_2_in_more = 0
n_2_in_1 = 0
n_2_in_1_dict=[]
n_2_unique = 0
n_2_unique_dict=[]


for gene in gene_2.keys():
    if gene in list2_17 and count_gene2[gene]==1:
        
        n_2_in_17 += 1

    if gene in count_gene2 and count_gene2[gene]>1:
        n_2_in_more +=1

    if not gene in count_gene2:
        if gene in list2_1:
            n_2_in_1 += 1
            n_2_in_1_dict.append(gene)
        else:
            
            n_2_unique += 1
            n_2_unique_dict.append(gene)

n_2_in_1_file = open("n_2_in_1_file.list",'w')
for n in n_2_in_1_dict:
    if n in a2:
        n_2_in_1_file.write(n+'\t'+a2[n]+'\n')
        #else:
        #print n

n_2_unique_file = open("n_2_unqiue_file.list",'w')
for n in n_2_unique_dict:
    if n in a2:
        n_2_unique_file.write(n+'\t'+a2[n]+'\n')



print "all_opf2:",len(gene_2.keys())
print "ofp2 shared with Tere only:",n_2_in_17
print "ofp2 shared with more than 1 close relative:",n_2_in_more
print "ofp2 unique to only type II:",n_2_unique
print "ofp2 unique to both type II and type I:",n_2_in_1
print "ofp2 unique:",n_2_in_1+n_2_unique
            
print "-------------"
print "all_opf1:",len(gene_1.keys())
print "ofp1 shared with Tere only:",n_1_in_17
print "ofp1 shared with more than 1 close relative:",n_1_in_more
print "ofp1 unique to only type II:",n_1_unique
print "ofp1 unique to both type II and type I:",n_1_in_2
print "ofp1 unique:",n_1_in_2+n_1_unique

            




