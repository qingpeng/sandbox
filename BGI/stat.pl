#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm dir_list file_out \n";
	exit;
}
($dir_list,$file_out) =@ARGV;

open LIST,"$dir_list" || die"$!";
open OUT,">$file_out" || die"$!";

while ($dir = <LIST>) {
	chomp $dir;
	$result =`ls $dir/SCF/|grep -v txt|wc`;
	print  "$result\n";
	@s = split /\s+/,$result;
	$num = $s[1];
	print OUT "$dir\t$num\n";
}


