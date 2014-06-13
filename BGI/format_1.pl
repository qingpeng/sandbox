#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# remove all the blanks and numbers in fasta sequences 
# 2004-6-11 10:55
# 修改fasta id 所有\W 改为 __
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

my $id;

while (my $line = <IN>) {
	chomp $line;
	if ($line=~/^>(.*)/) {
		$id = $1;
		$id =~s/\W/__/g;

		print OUT ">$id\n";
	}
	else {
		if ($line =~/\S/) {
			$line=~s/[\d\s\/]//g;
			print OUT "$line\n";
		}
	}
}



