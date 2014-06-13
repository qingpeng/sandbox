#!/usr/bin/perl
#ENSP00000288816 592     325     583     +       bsbq1   76397   45416   49995   5       257     325,353;349,375;375,422;481,5
#38;546,583;     45416,45502;45579,45659;45773,45916;49614,49784;49882,49995;    +41;+39;+88;+54;+44;
#ENSP00000348148 392     2       250     -       bsah    94921   55555   56395   2       68      2,157;149,250;  56395,55925;5
#5845,55555;     -37;-33;
#ENSP00000348148 392     314     381     +       bsay    49005   8803    9009    1       48      314,381;        8803,9009;
#        +48;

#比上蛋白的序列<0.1的；只比上一段 90％以上都比上的 去掉
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
$line="";
$k=0;
while (<IN>) {
	chomp;
	
	@s=split /\s+/,$_;
	$pep_name = $s[0];
	$pep_length = $s[1];
	$pep_start = $s[2];
	$pep_end = $s[3];
	$bac_name = $s[5];
	$block_number=$s[9];
	$match_base= $s[10];
	unless ($block_number=1 && ($pep_end-$pep_start)/$pep_length>0.9|($pep_end-$pep_start)/$pep_length<0.1) {#如果大于90％长度的蛋白只比上一块genome序列
	print OUT "$_\n";

		

	}


}