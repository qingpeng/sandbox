#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# remove fasta sequence in SMALL file from BIG file
# 2004-3-10 14:40 
# 2004-8-10 10:24 modified from remove_fasta_by_list.pl
# 

if (@ARGV<2) {
	print  "programm small_file big_file \n";
	exit;
}
($small,$big) =@ARGV;

open S,"$small" || die"$!";
open B,"$big" || die"$!";



while (<S>) {
	chomp;
	if ($_=~/^>(\S+)\s*/) {
		$id = $1;
		$mark{$id}=1;
	}
}

while (<B>) {
	if ($_=~/^>(\S+)\s*/) {
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