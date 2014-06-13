#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 连成一行
# 2005-4-5 19:58
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#
#     5   2279
#ENSMUSP000 ---------- ---------- ---------- ---------- ---------- 
#ENSGALP000 ATGGTGGTTT TCAATGGCTT GCTGAAGATC AAGATCTGCG AGGCGGTGAA 
#ENSP000003 ATGGTAGTGT TCAATGGCCT TCTTAAGATC AAAATCTGCG AGGCCGTGAG 
#ENSCAFP000 ATGGTAGTGT TCAATGGCCT CCTTAAGATC AAAATCTGCG AGGCCGTGAG 
#bsbq1_gw1_ ---------- ---------- ---------- ---------- ---------- 
#
#           ---------- ---------- ---------- ---------- ---------- 
#           TCTGAAGCCC ACGGCGTGGT CCTTGAGGCA TGCGGTGGGC CCCAGGCCGC 
#           CTTGAAGCCC ACAGCCTGGT CGCTGCGCCA TGCGGTGGGA CCCCGGCCGC 
#           CTTGAAGCCC ACAGCCTGGT CGCTGCGCCA TGCGGTGGGA CCCCGGCCGC 
#           ---------- ---------- ---------- ---------- ---------- 
#
#           ---------- ---------- ---------- ---------- ---------- 
#           AGACCTTCCT GCTGGACCCT TACATAGCTC TCAATGTGGA CGACTCCAGG 
#           AGACTTTCCT TCTCGACCCC TACATTGCCC TCAATGTGGA CGACTCGCGC 
#           AGACTTTCCT CCTCGACCCC TACATCGCCC TCAACGTGGA CGACTCGCGC 
#           ---------- ---------- ---------- ---------- ---------- 
#
#           ---------- ---------- ---------- ---------- ---------- 
#           ATTGGGCAGA CCTCCACCAA GCAAAAGACC AACAGTCCCG CGTGGAACGA 
#

$full_length = 0;
$block_num = 0;
$k = 0;
			$block_seq[0] ="";
			$block_seq[1] ="";
			$block_seq[2] ="";
			$block_seq[3] ="";
			$block_seq[4] ="";
			$seq[0] ="";
			$seq[1] ="";
			$seq[2] ="";
			$seq[3] ="";
			$seq[4] ="";
while (<IN>) {
	chomp;
	if ($_=~/^\s\s\s\s\s5/) {
		$block_num++;
		if ($block_num>1) {
			$block_length = length $block_seq[0];
			$seq[0] = $seq[0].$block_seq[0];
			$seq[1] = $seq[1].$block_seq[1];
			$seq[2] = $seq[2].$block_seq[2];
			$seq[3] = $seq[3].$block_seq[3];
			$seq[4] = $seq[4].$block_seq[4];
			$block_seq[0] ="";
			$block_seq[1] ="";
			$block_seq[2] ="";
			$block_seq[3] ="";
			$block_seq[4] ="";
			if ($block_num == 2) {
				$lengths = $block_length;
			}
			else {
				$lengths = $lengths." ".$block_length;
			}
			$full_length = $full_length+$block_length;
			print  "full_length = $full_length\n";
		}
	}
	elsif ($_=~/^.{11}(.*)/) {
		$seq = $1;
		$seq =~s/\s//g;
		$block_seq[$k] =$block_seq[$k].$seq;
		$k++;
	}
	elsif ($_ eq "") {
		$k=0;
	}
}

		$block_num++;
		if ($block_num>1) {
			$block_length = length $block_seq[0];
			$seq[0] = $seq[0].$block_seq[0];
			$seq[1] = $seq[1].$block_seq[1];
			$seq[2] = $seq[2].$block_seq[2];
			$seq[3] = $seq[3].$block_seq[3];
			$seq[4] = $seq[4].$block_seq[4];
			if ($block_num == 2) {
				$lengths = $block_length;
			}
			else {
				$lengths = $lengths." ".$block_length;
			}
			$full_length = $full_length+$block_length;
			print  "full_length = $full_length\n";
		}

#4 1000 G
#G 4 300 400 500
#Sequence
#ACTG


print OUT "5 $full_length G\n";
print OUT "G $block_num $lengths\n";
print OUT "Sequence\n";
print OUT "$seq[0]\n$seq[1]\n$seq[2]\n$seq[3]\n$seq[4]\n";


