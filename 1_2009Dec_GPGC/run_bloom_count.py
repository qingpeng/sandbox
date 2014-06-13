
import sys


files = ["reads_11111_1.fa","reads_11111_2.fa","reads_12345_1.fa","reads_12345_2.fa","reads_124816_1.fa","reads_124816_2.fa"]


for file in files:
    
    file_sh = file+".sh"
    fh = open(file_sh,'w')
    command1 = "python /u/qingpeng/1_2009Dec_GPGC/pick_fasta_randomly_90_10.py "+file+" "+file+".90 "+file+".10 \n"    
    command2 = "python /u/qingpeng/Github/khmer/scripts/bloom_count_intersection_v3.py "+file+".10 32 2000000000 4 "+file+".90 "+file+".curve "+file+".result & \n"
    fh.write(command1)
    fh.write(command2)
    fh.close()
    command3 = "bash "+file_sh+" &"
    os.system(command3)
    
    #print command2
    
    