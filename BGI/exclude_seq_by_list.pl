#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去除一定的序列
# 2004-3-10 14:40 
if (@ARGV<3) {
	print  "programm file_list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";


open L,"$file_list" || die"$!";
#	Scaffold000002	17797	+	31750	32731
#	Scaffold000004	14573	-	60171	67750

while (<L>) {
	chomp;
	@s = split /\t/,$_;
	$mark{$s[0]}=1;
}

open I,"$file_in" || die"$!";

while (<I>) {
	if ($_=~/^>(\S+)\s+/) {
		$id = $1;
		$st =0;
		unless (exists $mark{$id}) {
			print OUT "$_";
			$st=5;
		}
	}
	else {
		if ($st==5) {
			print OUT "$_";
		}
	}
}

