#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理phrap.out.list 
# 仅仅把x去掉！！ 为了确定正反向关系
#  Note: 假设 reads全部以scf结尾
#
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# Contig 38.  10 reads; 2019 bp (untrimmed), 1939 (trimmed).  Isolated contig.
#       1   573 rbsbmx0_000341.y1.scf  569 (  0)  0.17 0.00 0.00    0 (250)    0 (269) 

while (my $line = <IN>) {
	chomp $line;
	if ($line =~/^Contig\s(\d+\.)(.+)/) {
#		$new_line = "Contig".$1.$2;
		print OUT "$line\n";
	}
	else {
		$line=~s/_//g;
#		if ($line=~/(.+\s+)r(\S+\.scf\s+.*)/) {
#			$line = $1.$2;
#		}
#       1   573 bsbmx0_000341.y1.scf  569 (  0)  0.17 0.00 0.00    0 (250)    0 (269) 
		if ($line=~/(.+\s+\w\w\w\w)x(0\S+\.scf\s+.*)/) {
			$line = $1.$2;
		}
		print OUT "$line\n";
	}
}

