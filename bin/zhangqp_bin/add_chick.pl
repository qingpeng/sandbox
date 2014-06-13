#!/usr/bin/perl

if (@ARGV<3) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die "$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
#ENSG00000006611	ENST00000358979	ENSP00000351866	553	ENSMUSG00000030838.2	0.0794165	ENSMUSP00000009667	ENSCAFG00000008995.1	ENSCAFP00000013245
#ENSG00000020577	ENST00000305831	ENSP00000306381	530	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
	chomp;
	@s=split /\t/,$_;
	$human_pep=$s[2];
	$hash{$human_pep}=$_;
}

while (<LIST>) {
	chomp;
#	ENSG00000100030	ENST00000215832	ENSP00000215832	ENSGALG00000001501.1	99	ENSGALP00000002278
	@ss=split /\t/,$_;
	$human_pr=$ss[2];
	if (exists $hash{$human_pr} && $ss[3] ne "") {
		print OUT "$hash{$human_pr}\t$ss[3]\t$ss[5]\n";
	}

}