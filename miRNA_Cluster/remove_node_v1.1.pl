#!/usr/bin/perl -w
use strict;
# 去冗余，hub已经出现过，不要，优先考虑degree高的
# 2007-12-13 14:44
# 

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";

#
#771	C_266178	C_266178 C_421769 C_421769 C_421769 C_301466 C_301466 C_3
#665	C_414635	C_414635 C_480086 C_480086 C_58577 C_58577 C_58577 C_5857
#663	C_538649	C_558863 C_558863 C_544477 C_544477 C_538649 C_20596 C_20
#598	C_14279	C_14279 C_800482 C_800482 C_800482 C_800481 C_800481 C_800
#594	C_608377	C_608377 C_414635 C_414635 C_480086 C_480086 C_58577 C_58
#


my %group;

while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    my @ss = split /\s/,$s[2];
#    print  "$ss[0]\n";
    if (exists $group{$s[1]} ) {
#        print  "drop\n";
        next;
    }
    else {
        print OUT "$s[0]\t$s[1]\t";
        $group{$s[1]} = 1;
        for (my $k=1;$k<scalar @ss ;$k++) {
            unless (exists $group{$ss[$k]}) {
                $group{$ss[$k]} = 1;
                print OUT "$ss[$k] ";
            }
        }
        print OUT "\n";
    }        
}



