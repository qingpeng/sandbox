#!/usr/bin/perl -w
use strict;
# clear the zero-length line
# 2007-11-20 13:25
# 
#


if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";
#
#>NM_001039577_1_-_1907_1935   hg17_refGene_NM_001039577_1_1907_1935_-
#>NM_001039577_1_-_853_875   hg17_refGene_NM_001039577_1_853_875_-
#>NM_001039577_2_-_2292_2317   hg17_refGene_NM_001039577_2_2292_2317_-
#gcctgtaatcccagcactttgggagg
#>NM_001039577_2_-_2143_2171   hg17_refGene_NM_001039577_2_2143_2171_-
#ccagctactcaggaggctgaggcaggaga
#>NM_001039577_2_-_2292_2316   hg17_refGene_NM_001039577_2_2292_2316_-
#cctgtaatcccagcactttgggagg

my $title;


while (<IN>) {
    chomp;
    if ($_ =~/^>/) {
        $title = $_;
    }
    else {
        print OUT "$title\n";
        print OUT "$_\n";
    }
}

