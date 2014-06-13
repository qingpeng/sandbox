#!/usr/bin/perl -w
use strict;

my $file_in="HS_RefLink";
open OUT, ">GENEID_NAME_REF";
open IN, "$file_in"     or die "Can't open $file_in $!";
while (<IN>) {
	chomp;
	my @s=split /\t/,$_;
	print OUT "$s[-2]\t$s[0]\t$s[2]\t$s[3]\n";  #geneid genename rnaACC proteinAcc
}
close OUT;

