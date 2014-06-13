#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去除一定的序列
# 2004-3-10 14:40 
open L,"repeat_reads.list" || die"$!";

while (<L>) {
	chomp;
	$mark{$_}=1;
}

open I,"wm_d.seq.RemoveVector" || die"$!";

while (<I>) {
	if ($_=~/^>(\S+)\s+/) {
		$id = $1;
		$st =0;
		unless (exists $mark{$id}) {
			print  "$_";
			$st=5;
		}
	}
	else {
		if ($st==5) {
			print  "$_";
		}
	}
}