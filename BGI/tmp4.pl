#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open ENSEMBL,"$file_list" || die "$!";


while (<ENSEMBL>) {
#14	ENSG00000100490	ENST00000216378	ENSP00000216378	Serine/threonine-protein kinase KKIALRE (EC 2.7.1.37) (Cyclin- dependent kinase-like 1). [Source:Uniprot/SWISSPROT;Acc:Q00532]
	chomp;
	@s=split /\t/,$_;
	$hash{$s[3]}=$_;

}
while (<IN>) {
#bsbf	ENSG00000054654	ENSP00000308694
	chomp;
	@ss=split /\t/,$_;
	if (exists $hash{$ss[2]}) {
		@info=split /\t/,$hash{$ss[2]};
		print OUT "$ss[0]\t$info[0]\t$ss[1]\t$info[2]\t$info[3]\t$info[4]\n";
	}
	

}