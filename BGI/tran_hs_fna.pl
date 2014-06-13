#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# 更改 hs.fna 文件的 说明行
# 2004-4-12 14:22

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# >gi|19923555|ref|NM_020141.2| Homo sapiens protein x 013 (AD-020), mRNA

# ===> >NM_020141 gi|19923555|ref|NM_020141.2| Homo sapiens protein x 013 (AD-020), mRNA

while (<IN>) {
	chomp;
	my $line = $_;
	if ($line =~/>gi\|\S+\|ref\|(\S+)\.\S+\|/ ) {
		$nm_id =  $1;
#		print  "$nm_id\n";
		if ($line =~/>(.+)/) {
			$title = $1;
		}
		$new_line = ">".$nm_id." ".$title;
		print OUT "$new_line\n";
	}
	else {
		
		print OUT  "$line\n";
	}
}


