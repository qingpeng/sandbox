#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";



#
#N_1139391       4
#N_3176463       1
#N_1487116       1
#N_1737346       1
#N_751407        1
#



#my $last = 3653787;
my $last = 73785;
my %cover;

while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    $cover{$s[0]} = $s[1];
}


for (my $k = 0;$k<$last+1 ;$k++) {
    my $id = "N_".$k;
    if (exists $cover{$id}) {
        print OUT "$id\t$cover{$id}\n";
    }
    else {
        print OUT "$id\t0\n";
    }
}




