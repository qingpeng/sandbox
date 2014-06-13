#!/usr/bin/perl -w
use strict;

# for snp
# 2007-7-1915:17
# 
if (@ARGV < 1) {
    print "perl *.pl file_in  \n";
    exit;
}
my ($file_in) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";




#585    chr1    800     801     rs28853987      0       +       G       G       A/G     genomic single  unknown 0       0       locus   exact   1
#585    chr1    876     877     rs28484712      0       +       G       G       A/G     genomic single  unknown 0       0       locus   exact   1
#585    chr1    884     885     rs28775022      0       +       G       G       A/G     genomic single  unknown 0       0       locus   exact   1



while (<IN>) {
    chomp;
    unless ($_=~/^\#/) {
    
    my @s =split /\t/,$_;
    my $file_tmp = $file_in.".$s[1]";
    open TMP,">>$file_tmp";
    print TMP "$_\n";

    }
}



