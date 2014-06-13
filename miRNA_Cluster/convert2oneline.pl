#!/usr/bin/perl -w
use strict;
# 去掉换行符~~
# 2006-7-4 11:22
# 
if (@ARGV < 2) {
	print "perl *.pl file_in file_out \n";
	exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";


#>NM_058167_2_-_1249_1502   hg17_refGene_NM_058167_2_1249_1502_-
#ttcaccgtattagcaaggatggtctggatctcctgacgagtttcact
#cttgtcacccaggctggaatacaacggcacgacctcggctcactgca
#acctccgcctcccgggttcaagtgattctcctgcctcagcctcccga
#gtagctgggattataggcatgcactaccacacccggctaattttgta
#tttttagtagagatggggtttctccgtgttggtcaggctggtctcga
#actcctgacctcagatgat
#>NM_194315_3_-_1249_1502   hg17_refGene_NM_194315_3_1249_1502_-
#ttcaccgtattagcaaggatggtctggatctcctgacgagtttcact
#cttgtcacccaggctggaatacaacggcacgacctcggctcactgca
#acctccgcctcccgggttcaagtgattctcctgcctcagcctcccga

my $seq = "";

while (<IN>) {
    chomp;
	if ($_=~/^>/) {
		if ($seq ne "") {
			print OUT "$seq\n";
			$seq = "";
		}
		print OUT ">1\n"; # 只用一个名称！~~~
	}
	else {
	    $seq = $seq.$_;
	}
}

print OUT "$seq\n";

