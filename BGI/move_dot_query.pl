#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp ;
	if ($_=~/^>(\S+)\s/) {
		@s = split /\s/,$_;
		$query = $1;
		$query =~s/\./_/g;
	#	print  "$query\n";
		print OUT ">$query $s[1]\n";
	}
	else {
		print OUT "$_\n";
	}
}