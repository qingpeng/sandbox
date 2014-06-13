#fig|6666666.20750.peg.1307      fig|6666666.20450.peg.2703      40.00   40      24      0       64      183     34      153     1e-19   32.7
#fig|6666666.20750.peg.1307      fig|6666666.20450.peg.1173      39.08   87      53      0       406     666     352     612     5e-19   72.1

file_1 = open("Ofp1_A.fna",'r')
file_2 = open("Ofp2.fna",'r')
file_n = open("neptu.fna",'r')

gene_1 = 0
for line in file_1:
    if ">" in line:
        gene_1 +=1
        
gene_2 = 0

for line in file_2:
    if ">" in line:
        gene_2 += 1

gene_n = 0

for line in file_n:
    if ">" in line:
        gene_n += 1

def get_num_1(e_cutoff):
    
    file_1_2 = open("Ofp1_A_against_Ofp2.tblastx.m8",'r')
    file_1_n = open("Ofp1_A_against_neptu.tblastx.m8",'r')
    
    list_1_2 = {}
    list_1_n = {}

    for line in file_1_2:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_1_2[line_list[0]]=1
            
    for line in file_1_n:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_1_n[line_list[0]]=1

    gene_1_2_n = 0
    for gene in list_1_2.keys():
        if gene in list_1_n:
            gene_1_2_n +=1
    
    gene_1_2 = len(list_1_2.keys())
    gene_1_n = len(list_1_n.keys())
    
    print "file_1:",gene_1
    print "file_2:",gene_2
    print "file_n:",gene_n
    
    print "gene_1_2:",gene_1_2
    print "gene_1_n:",gene_1_n
    
    
    print "gene_1_2_n:",gene_1_2_n
    print "gene_1_only:",gene_1-gene_1_2-gene_1_n+gene_1_2_n
    print "gene_1_n_only:", gene_1_n - gene_1_2_n
    print "gene_1_2_only:", gene_1_2 -gene_1_2_n



def get_num_2(e_cutoff):
    
    file_2_1 = open("Ofp2_against_Ofp1_A.tblastx.m8",'r')
    file_2_n = open("Ofp2_against_neptu.tblastx.m8",'r')
    
    list_2_1 = {}
    list_2_n = {}

    for line in file_2_1:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_2_1[line_list[0]]=1
            
    for line in file_2_n:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_2_n[line_list[0]]=1

    gene_2_1_n = 0
    for gene in list_2_1.keys():
        if gene in list_2_n:
            gene_2_1_n +=1
    
    gene_2_1 = len(list_2_1.keys())
    gene_2_n = len(list_2_n.keys())
    
    print "file_1:",gene_1
    print "file_2:",gene_2
    print "file_n:",gene_n
    
    print "gene_2_1:",gene_2_1
    print "gene_2_n:",gene_2_n
    
    
    print "gene_2_1_n:",gene_2_1_n
    print "gene_2_only:",gene_2-gene_2_1-gene_2_n+gene_2_1_n
    print "gene_2_n_only:", gene_2_n - gene_2_1_n
    print "gene_2_1_only:", gene_2_1 -gene_2_1_n



def get_num_3(e_cutoff):
    
    file_n_2 = open("neptu_against_Ofp2.tblastx.m8",'r')
    file_n_1 = open("neptu_against_Ofp1_A.tblastx.m8",'r')
    
    list_n_1 = {}
    list_n_2 = {}

    for line in file_n_1:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_n_1[line_list[0]]=1
            
    for line in file_n_2:
        line_list = line.rstrip().split()
        if float(line_list[10])<e_cutoff:
            list_n_2[line_list[0]]=1

    gene_n_1_2 = 0
    for gene in list_n_1.keys():
        if gene in list_n_2:
            gene_n_1_2 +=1
    
    gene_n_1 = len(list_n_1.keys())
    gene_n_2 = len(list_n_2.keys())
    
    print "file_1:",gene_1
    print "file_2:",gene_2
    print "file_n:",gene_n
    
    print "gene_n_1:",gene_n_1
    print "gene_n_2:",gene_n_2
    
    
    print "gene_n_1_2:",gene_n_1_2
    print "gene_n_only:",gene_n-gene_n_1-gene_n_2+gene_n_1_2
    print "gene_n_1_only:", gene_n_1 - gene_n_1_2
    print "gene_n_2_only:", gene_n_2 -gene_n_1_2

    
e=1e-6
get_num_1(e)
get_num_2(e)
get_num_3(e)

