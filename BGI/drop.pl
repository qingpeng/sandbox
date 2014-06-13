#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 丢掉list中出现的的行
# 2004-8-21 22:27
# 
if (@ARGV<3) {
	print  "programm list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open LIST,"$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<LIST>) {
	chomp;
	$mark{$_} =5;
}

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	unless (defined $mark{$s[0]}) {
		print OUT "$_\n";
	}
}

