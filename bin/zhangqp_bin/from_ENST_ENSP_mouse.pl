#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm tran_pep.tsv list_File file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";

# mouse
# ENSMUST00000027252.2	ENSMUSP00000027252.2

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	@s0= split /\./,$s[0];
	@s1 = split /\./,$s[1];
	$pep{$s0[0]}=$s1[0];
}

# ENST00000320195


while (<LIST>) {
	chomp;
	$pep = $pep{$_};
	if ($pep ne "") {
		$p_pep = "Translation:".$pep;
		print OUT "$p_pep\n";
	}
}