#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# filter human_gene in the bac region
#
if (@ARGV<3) {
	print  "programm bac_region_file file_in file_out \n";
	exit;
}
($region_file,$file_in,$file_out) =@ARGV;

open REGION,"$region_file" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<REGION>) {
	chomp;
	@s = split /\t/,$_;
	$chr = $s[0];
	$start = $s[1]-50000;
	$end = $s[2]+50000;
}

#print  "$chr\t$start\t$end\n";
# 9999[0]	0	0	0	0	0	0	0	+[8]	NM_139021	2238	9999	9999	chr8[13]	9999	144904490[15]	144910607[16]	12	104,99,30,91,182,164,140,611,181,125,129,382,	9999,9999	144904490,144905844,144906197,144906362,144906874,144907143,144907493,144908380,144909381,144909699,144909902,144910225,

while (<IN>) {
	chomp ;
	@s = split /\t/,$_;
#	print  "$s[13]\t$s[15]\t$s[16]\n";
#	exit;
	if ($s[13] eq $chr && $s[15]<$end && $s[16]>$start) {
		print OUT "$_\n";
	}
}




