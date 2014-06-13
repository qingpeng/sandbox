#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 只要有-就去除 不按3的倍数
# 2005-4-8 21:17
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

$head=<IN>;
chomp $head;
$k = 0;
while (<IN>) {
	chomp;
	if ($_=~/^(\S+)\s+(.*)/) {
		$name[$k] = $1;
		$seq = $2;
		$seq =~s/\s//g;
		$seq[$k] = $seq;
		$k++;
	}
	elsif ($_ eq "") {
		$k=0;
	}
	else {
		$seq = $_;
		$seq =~s/\s//g;
		$seq[$k] = $seq[$k].$seq;
		$k++;	
	}
}

$full_length = length $seq[0];
#print  "$seq[0]\n$seq[1]\n$seq[2]\n$seq[3]\n$seq[4]\n";
#$block_num =int($full_length/50)+1; 
for (my $k = 0;$k<$full_length;$k = $k+1) {
	$substr_0 = substr $seq[0],$k,1;
#	print  "$substr_0\n";
	$substr_1 = substr $seq[1],$k,1;
#	print  "$substr_1\n";
	$substr_2 = substr $seq[2],$k,1;
#	print  "$substr_2\n";
	$substr_3 = substr $seq[3],$k,1;
#	print  "$substr_3\n";
	$substr_4 = substr $seq[4],$k,1;
#	print  "$substr_4\n";

	if ($substr_0 =~/\-/ || $substr_1 =~/\-/||$substr_2 =~/\-/||$substr_3 =~/\-/||$substr_4 =~/\-/) {
#		print  "here~~~\n";
		substr ($seq[0],$k,1)="";
#		print  "$seq[0]\n";
		substr ($seq[1],$k,1)="";
#		print  "$seq[1]\n";
		substr ($seq[2],$k,1)="";
#		print  "$seq[2]\n";
		substr ($seq[3],$k,1)="";
#		print  "$seq[3]\n";
		substr ($seq[4],$k,1)="";
#		print  "$seq[4]\n";
		$k = $k-1;
		$full_length = length $seq[0];
	}
}

print OUT "$head\n";
$full_length = length $seq[0];
#print  "fulllength == $full_length\n";
for (my $n = 0;$n<$full_length;$n= $n+50) {
	$ssubstr_0 = substr $seq[0],$n,50;
	$ssubstr_1 = substr $seq[1],$n,50;
	$ssubstr_2 = substr $seq[2],$n,50;
	$ssubstr_3 = substr $seq[3],$n,50;
	$ssubstr_4 = substr $seq[4],$n,50;

   if ($n ==0) {
	print OUT "$name[0]";
	&print_line ($ssubstr_0);
	print OUT "$name[1]";
	&print_line ($ssubstr_1);
	print OUT "$name[2]";
	&print_line ($ssubstr_2);
	print OUT "$name[3]";
	&print_line ($ssubstr_3);
	print OUT "$name[4]";
	&print_line ($ssubstr_4);
print OUT "\n";
   }
   else {
	print OUT "          ";
	&print_line ($ssubstr_0);
	print OUT "          ";
	&print_line ($ssubstr_1);
	print OUT "          ";
	&print_line ($ssubstr_2);
	print OUT "          ";
	&print_line ($ssubstr_3);
	print OUT "          ";
	&print_line ($ssubstr_4);
print OUT "\n";
   }
}


sub print_line{
	my ($line) = @_;
#	print  "$line\n";
	my $num = length $line;
	for (my $k = 0;$k<$num;$k=$k+10) {
		my $sub_line = substr $line,$k,10;
		#print  "sub_line==$sub_line--\n";
		if ($sub_line ne "") {
			print OUT " $sub_line";
		}
	}
	print OUT " \n";
}

