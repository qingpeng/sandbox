#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# »Ö¸´×ø±ê£¡
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# bsbp/bsbp.fa.Contig2	985	351	375	9023615[4]	9023639[5]	10000000	50.1	0.003	25/25	100	chr8_146308819_129350000[11]

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	$id = $s[11];
	@s_2 = split /_/,$id;
	$chr=$s_2[0];
	$start = $s_2[2];
	$real_start = $s[4]+$start-1;
	$real_end = $s[5]+$start-1;
	print OUT "$s[0]\t$s[1]\t$s[2]\t$s[3]\t$real_start\t$real_end\t$s[6]\t$s[7]\t$s[8]\t$s[9]\t$s[10]\t$chr\n";
}

