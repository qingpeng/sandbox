#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去除seq中含有小写字母的序列
# 2004-12-14 16:21
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";




$/=">";
my $null = <IN>;# 要特殊处理第一行！


while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	$seq = join "",@lines;
	unless ($seq =~/[actg]/) {
		print OUT ">$title\n";
		$length = length $seq;   ## bug 1 2004-12-2 14:53
		$modulus = $length % 50;
		$seq =~ s/(.{50})/$1\n/ig;
#	print  "modulus == $modulus\n";
		if ($modulus ==0) {
			print OUT "$seq";
				}
		else {
			print OUT "$seq\n";
		}
	}
}

