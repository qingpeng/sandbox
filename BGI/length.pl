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

$/=">";

$null = <IN>;
while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];
	
		$seq = join "",@lines;
		$length = length $seq;
		print OUT "$id\t$length\n";
}

