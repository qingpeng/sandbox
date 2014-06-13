#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open LIST,"$file_list" || die "$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#ENSG00000020577	ENST00000305831	ENSP00000306381	530	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
#ENSG00000020577	ENST00000357634	ENSP00000350261	346	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
#ENSG00000020577	ENST00000251091	ENSP00000251091	346	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017

while (<LIST>) {
	chomp;
	@s=split /\t/,$_;
	$pep_name=$s[2];
	$gene_name=$s[0];
	$hash{$pep_name}=$gene_name;
}
#ENSP00000169565	bsbq1	4	291.36	Gene 53074 66911 
#ENSP00000201943	bsbm	10	593.14	Gene 10351 883
#ENSP00000237305	bsbq1	8	190.02	Gene 43818 49781 [pseudogene]



while (<IN>) {
	chomp;
	@ss=split /\t/,$_;
	@sss=split /\s/,$ss[4];
		if (exists $hash{$ss[0]} && !exists $sss[3]) {
		print OUT "$ss[1]\t$hash{$ss[0]}\t$ss[0]\n";
		}
		if (exists $hash{$ss[0]} && exists $sss[3]) {
		print OUT "$ss[1]\t\*$hash{$ss[0]}\t$ss[0]\n";
		}
	
}

