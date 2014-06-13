#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去除一定的序列
# 2004-3-10 14:40 
# 修改 重做时的scaffold_order.list 格式
# 2004-5-31 14:57

if (@ARGV<3) {
	print  "programm file_list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";


open L,"$file_list" || die"$!";
# +++	Scaffold000004	13090	-	11483	12291	809	46282	46938	657
# ++	Scaffold000002	15216	-	14579	14677	99	68620	68717	98
# ++	Scaffold000007	8328	-	6073	8303	2231	93187	95617	2431
# +++	Scaffold000003	14378	-	13278	14073	796	102052	102872	821

while (<L>) {
	chomp;
	@s = split /\t/,$_;
	$mark{$s[1]}=1;
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

