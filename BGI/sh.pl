#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


use strict;

for (my $k = 1;$k<51;$k++) {
	print  "ls *.masked.fa |awk \'{print \"blastall -p blastn -i Query/wm_d_$k.seq.RemoveVector -d DB/\"\$1,\"-o Out/wm_d_$k.seq.RemoveVecto__\"\$1\".blastn -e 1e-2 -m 8 &\"}\' > blast_$k.sh & \n";
}

