#!/usr/bin/perl

if (@ARGV<3) {
	print  "programm file_list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;
open ENSEMBL,"$file_list" || die "$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<ENSEMBL>) {
#14	ENSG00000100490	ENST00000216378	ENSP00000216378	Serine/threonine-protein kinase KKIALRE (EC 2.7.1.37) (Cyclin- dependent kinase-like 1). [Source:Uniprot/SWISSPROT;Acc:Q00532]
	chomp;
	@s=split /\t/,$_;
	$hash{$s[3]}=$_;

}
while (<IN>) {
	chomp;
#ENSP00000201943	bsbm	10	593.14	Gene 10351 883
#ENSP00000237305	bsbq1	8	190.02	Gene 43818 49781 [pseudogene]

	@ss=split /\t/,$_;
	@sss=split /\s/,$ss[4];
	if (exists $hash{$ss[0]}) {
		@info=split /\t/,$hash{$ss[0]};
		if ($sss[3] eq "") {
			$gene{$info[1]}=[$ss[1],$info[0],$info[1],$info[2],$info[3],$info[4]];
		}
		else {
			$gene{$info[1]}=[$ss[1],$info[0],"*".$info[1],$info[2],$info[3],$info[4]];

		}
	}


}
foreach $name (keys %gene) {
	print OUT "$gene{$name}->[0]\t$gene{$name}->[1]\t$gene{$name}->[2]\t$gene{$name}->[3]\t$gene{$name}->[4]\t$gene{$name}->[5]\n";
}