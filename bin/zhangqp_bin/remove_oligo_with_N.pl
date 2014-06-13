#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# remove oligo with N
# 2005-1-25 14:26
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



#>AB005216_3_2
#TGGGACGCTGCCTACATCTGTCCTTGTGGCTCCGATGGGGTCTTCCTTGCAGTCTTTCCCCCTACCTCCG
#>AB005216_3_3
#CCTACATCTGTCCTTGTGGCTCCGATGGGGTCTTCCTTGCAGTCTTTCCCCCTACCTCCGCCTCCTCCAC
#>AB005216_4_1
#ATGCATTTCCCCGGATTGCTCCCATCCGAGCAGCTGAATCCCTGCACAGCCAACCCCCACAGCACCTCCA
#>AB005216_4_7
#AGCACCTCCAGTGTCCCCTCTACCGGCCTGACTCGAGCAGCTTTGCAGCCAGCCTTCGAGAGTTGGAGAA
#
while (<IN>) {
	chomp;
	if ($_ =~/^>(.*)/) {
		$title = $1;
	}
	else {
		unless ($_ =~/N/) {
			print OUT ">$title\n";
			print OUT "$_\n";
		}
	}
}

