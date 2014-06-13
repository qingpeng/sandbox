#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 生成画svg图的格式
# 过滤掉 length<100的record
#  2004-6-15 15:32
#
if (@ARGV<1) {
	print  "programm eblastn_file_in\n";
	exit;
}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";


while (<IN>) {
	chomp;
	if ($_ =~/^Scaffold/) {
		@s = split /\t/,$_;
		@ss = split /\//,$s[9];
		if ($ss[1]>100) {
			$start = $s[4];
			$end = $s[5];
			if ($s[5]<$s[4]) {
				$start = $s[5];
				$end = $s[4];
			}
			if (($s[5]-$s[4])*($s[3]-$s[2])>0) {
				$mark = "+";
			}
			else {
				$mark = "-";
			}
			$gene = $s[11];
			$scaffold = $s[0];
			$file_out = $gene.".for_svg";
#			$file_out =~s/[\|\(\)\[\]\,]/__/g;
			open OUT,">>$file_out" || die"$!";
			$out= $start.":".$end.":".$mark."::".$scaffold."\n";
			print OUT "$out";
		}
	}
}

