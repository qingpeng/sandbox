#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

($file_a,$file_b) = @ARGV;

open A,"$file_a" || die"$!";
open	B,"$file_b" || die"$!";


while (<A>) {
	chomp;
	$mark{$_} = 1;
}

while (<B>) {
	chomp;
	unless (exists $mark{$_}) {
		print  "$_\n";
	}
}

