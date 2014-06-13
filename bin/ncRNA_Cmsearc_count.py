#!/usr/bin/env python

#MH0001.seq.fa.RF00001.cmsearch
#MH0001.seq.fa.RF00010.cmsearch
#MH0001.seq.fa.RF00013.cmsearch
#MH0001.seq.fa.RF00018.cmsearch
#MH0001.seq.fa.RF00021.cmsearch
#MH0001.seq.fa.RF00022.cmsearch
#MH0001.seq.fa.RF00023.cmsearch
#MH0001.seq.fa.RF00028.cmsearch

# command:    cmsearch --tabfile MH0001.seq.fa.RF00001.cmsearch CM/RF00001.cm ./Fa/MH0001.seq.fa.RF00001
# date:       Tue Jun  1 01:15:26 2010
# num seqs:   16022
# dbsize(Mb): 4.401054
#
# Pre-search info for CM 1: 5S_rRNA
#
#                                  cutoffs            predictions     
#                            -------------------  --------------------
# rnd  mod  alg  cfg   beta     E value   bit sc     surv     run time
# ---  ---  ---  ---  -----  ----------  -------  -------  -----------
#   1   cm  cyk  loc  1e-10     635.231     2.42   0.0237  00:18:54.70
#   2   cm  ins  loc  1e-15       1.000    15.73  2.5e-05  00:01:53.56
# ---  ---  ---  ---  -----  ----------  -------  -------  -----------
# all    -    -    -      -           -        -        -  00:20:48.27
#
#
# CM: 5S_rRNA
#                                                            target coord   query coord                         
#                                                  ----------------------  ------------                         
# model name  target name                               start        stop  start   stop    bit sc   E-value  GC%
# ----------  -----------------------------------  ----------  ----------  -----  -----  --------  --------  ---
#
# Post-search info for CM 1: 5S_rRNA
#
#                              number of hits       surv fraction  
#                            -------------------  -----------------
# rnd  mod  alg  cfg   beta    expected   actual  expected   actual
# ---  ---  ---  ---  -----  ----------  -------  --------  -------
#   1   cm  cyk  loc  1e-10     635.231      420    0.0237   0.0131
#   2   cm  ins  loc  1e-15       1.000        0   2.5e-05  0.0e+00
#
# expected time    actual time
# -------------  -------------
#   00:20:48.27    00:13:06.00


f1 = open('cmsearch.list','r')
f3 = open('result.v1','w')
for line in f1:
    line=line.rstrip()
    fields = line.split('.')
    f2 = open(line,'r')
    number = 0
    switch = 0
    for line2 in f2:
        line2 = line2.rstrip()
        if 'beta' in line2 and 'expected' in line2 and 'actual' in line2:
            switch = 1
        elif 'cm' in line2 and switch == 1:
            fields2 = line2.split()
            number = number + int(fields2[7])
    
    out = fields[0]+' '+fields[3]+' '+str(number)+'\n'
    f3.write(out)
    f2.close()
