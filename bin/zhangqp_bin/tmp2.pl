#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
#bsaa	*ENSG00000122224	ENSP00000342921
#bsaa	ENSG00000117090	ENSP00000235739
#bsaa	ENSG00000117090	ENSP00000342054
#bsaa	ENSG00000117090	ENSP00000347333
#bsaa	ENSG00000122223	ENSP00000263289
#bsaa	ENSG00000122223	ENSP00000313619
#bsaa	ENSG00000122224	ENSP00000263285

while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	if ($s[1]=~/\*(\w+)/) {
		$name=$1;
		$hash{$name}=$_;

	}
	else {
		$hash{$s[1]}=$_;
	}
}
foreach $n (keys %hash) {
	print OUT "$hash{$n}\n"
}