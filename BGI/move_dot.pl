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
	@s = split /\t/,$_;
	$query = $s[0];
	$query =~s/\./_/g;
	print OUT "$query\t";
	for (my $k = 1;$k<11;$k++) {
		print OUT "$s[$k]\t";
	}
	print OUT "$s[11]\n";
}