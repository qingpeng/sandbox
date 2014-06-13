#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# ºÏ≤‚ bug”∞œÏ
# 2004-11-30 10:31
# 
if (@ARGV<2) {
	print  "programm file_sdiff file_best_oligo \n";
	exit;
}
($file_sdiff,$file_oligo) =@ARGV;

open SDIFF,"$file_sdiff" || die"$!";
open OLIGO,"$file_oligo" || die"$!";

# bda_22611.z1.abd_8_576
# bda_47604.z1.abd_280_507

while (<SDIFF>) {
	chomp;
	$a{$_} = 1;
}

# title:Gene	Have ORF position information	Oligo
# AB005216	Y	rdpcxb0_058712.y1.scf_42_171_7
# AB006589	Y	rcpg0_155476.y1.abd_429_558_3
# AB023191	Y	cluster30814_1_Step2_521_634_5
# AB023420	Y	cluster28879_1_Step1_1214_1440_12

while (<OLIGO>) {
	chomp;
	unless ($_=~/^title/) {
		@s = split /\t/,$_;
		unless ($s[2] eq "N/A") {
			if ($s[2]=~/(.*)_\d+/) {
				$segment = $1;
				if (exists $a{$segment}) {
					print  "$_\n";
				}
			}
		}
	}
}
