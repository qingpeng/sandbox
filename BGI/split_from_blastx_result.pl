#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#
# split list by reads database
# 取比的最好的pep
if (@ARGV<1) {
	print  "programm file_in(blastx result) \n";
	exit;
}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";

my %mark;

while (<IN>) {
	chomp ;
	@s = split /\t/,$_;
	$reads = $s[0];
#	print  "$reads\n";
	unless (exists $mark{$reads}) {
#		print  "==$reads\n";
	
	$mark{$reads} = 1;
	@t = split /_/,$s[0];
	$file_out = $t[0].".list";
	open O,">>$file_out" || die"$!";
#	print  "$s[1]\n";
	print O "$s[1]\n";
	close O;

	}
	
}


