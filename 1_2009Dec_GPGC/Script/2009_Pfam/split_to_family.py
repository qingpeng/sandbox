#!/usr/bin/env python

import sys
input_file = open(sys.argv[1],'r')



#>PF02826.12__61_Q7W8K1_BORPA
#MRTSTMKCLIVQPIHEEGLALLREAGVECIAPASAAMADVAAAIADCDAAITRNAGLDTRAIEAGRRLRVIGNHGTGTNMIDLAAAERLGIPVVNTPGANARSVAELALAMAMALLKRTVP
#LNQAVRQGNWNIRYEAGLRELSGMSLGIVGFGQIGRALAAMAIGGFGMRVHVYSPSVAPQDIAAAGCQRADSLPALAREADIVSLHRPARPGAGPLVDDALLQAMKPGALLINTARADLVD
#EAALARHLEAGRLGGAGLDVFSSEPPPADHPLLRLPQVVLAPHAGGSTDQALARTARAVAEQVIEVLRDARPAHLIAPHAWPRRRGAR

last_family = "N/A"

for line in input_file:
    if '>' in line:
        line = line.rstrip()
        fields = line.split(">")
        fields2 = fields[1].split('.')
        family = fields2[0]
        head = line

    else:
        line = line.rstrip()
        if family == last_family:
            output.write('%s\n%s\n' %(head,line))
         
        else:
            output_name = family+'.fa'
            output = open(output_name,'w')
            output.write('%s\n%s\n' %(head,line))
        last_family = family

        