#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# change *.forfig-->区域内的相对坐标

if (@ARGV<3) {
	print  "programm bac_region_file file_in  file_out \n";
	exit;
}
($region_file,$file_in,$file_out) =@ARGV;

open REGION,"$region_file" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



while (<REGION>) {
	chomp;
	@s = split /\t/,$_;
	$start = $s[1]-50000;
}

# 144904491:144904594:+::NM_139021
# 144905845:144905943:+::NM_139021
# 144906198:144906227:+::NM_139021
# 144906363:144906453:+::NM_139021
# 144906875:144907056:+::NM_139021
# 144907144:144907307:+::NM_139021

while (<IN>) {
	chomp;
	@s = split /:/,$_;
	$new_0 = $s[0]-$start+1;
	$new_1 = $s[1]-$start+1;
	$new_line = $new_0.":".$new_1.":".$s[2]."::".$s[4];
	print OUT "$new_line\n";
}

