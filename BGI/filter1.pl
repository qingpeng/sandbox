#!/usr/bin/perl 
#this script is used for filtering the genewise result :
#同时满足以下条件的扔掉：
#1. 表明pseudogene的
#2.染色体位置有问题的
#

#->	ENSP00000169565	bsbq1	4	291.36	Gene 53074 66911 	ENSG00000075429	ENST00000169565
#	ENSP00000201943	bsbm	10	593.14	Gene 10351 883	ENSG00000067191	ENST00000201943
#->	ENSP00000215659	bsah	7	111.43	Gene 18343 21362 	ENSG00000188130	ENST00000215659
#->	ENSP00000215832	bsah	5	162.68	Gene 18843 21365 	ENSG00000100030	ENST00000215832

#->	ENSP00000237305	bsbq1	8	190.02	Gene 43818 49781 [pseudogene]	ENSG00000118515	ENST00000237305

#
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
	if (/\-/) {
		@s=split /\t/,$_;
		@ss=split /\s+/,$s[5];
		unless ( $ss[3] eq "[pseudogene]" | $s[4]<100) {
			print OUT "$_\n";
		}
	}
	else {
		@s=split /\t/,$_;
		if ($s[3]>1|$s[4]>100) {
			print OUT "$_\n";
		}

		
	}
}