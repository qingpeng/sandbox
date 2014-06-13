#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# remove list with certain string start with list
# 2004-3-10 14:40 

if (@ARGV<2) {
	print  "programm list_file file_remained \n";
	exit;
}
($list,$file_in) =@ARGV;

open L,"$list" || die"$!";
open I,"$file_in" || die"$!";

while (<L>) {
	chomp;
	$mark{$_}=1;
}

# rbsbm0_000412.y1.scf	gi|37543714|ref|XP_292673.3|	94.29	35	2	0	428	324	477	511	1.1e-10	68.17
while (<I>) {
	@s=split /\s+/,$_;
	unless (exists $mark{$s[0]}) {
		print  "$_";
	}
}

