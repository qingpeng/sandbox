#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm transcript.txt.table list_File file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";

#	1	core	ensembl	ensembl	15630	ENST00000322424	1	2	72266542	72267558	1	72266542	72267558	15630	ENSP00000315660	1	11571	ENSG00000178455	1	1017	111605			

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	$pep{$s[5]}=$s[14];
}

# Transcript:ENST00000320195
# Transcript:ENST00000295269
# Transcript:ENST00000311501
# Transcript:ENST00000265900
# Transcript:ENST00000309078
# Transcript:ENST00000329428
# Transcript:ENST00000185907


while (<LIST>) {
	chomp;
	@s = split ":",$_;
	$pep = $pep{$s[1]};
	if ($pep ne "") {
		$p_pep = "Translation:".$pep;
		print OUT "$p_pep\n";
	}
}