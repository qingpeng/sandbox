#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# remove fasta sequence with certain id by list
# 2004-3-10 14:40 

if (@ARGV<2) {
	print  "programm list_file fasta_file \n";
	exit;
}
($list,$file_in) =@ARGV;

open L,"$list" || die"$!";
open I,"$file_in" || die"$!";

while (<L>) {
	chomp;
	$mark{$_}=1;
}

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