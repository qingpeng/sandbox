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
#771	C_266178 C_266178 C_421769 C_421769 C_421769 C_301466 C_301466 C_3
#665	C_414635 C_414635 C_480086 C_480086 C_58577 C_58577 C_58577 C_5857
#663	C_538649 C_558863 C_558863 C_544477 C_544477 C_538649 C_20596 C_20
#598	C_14279 C_14279 C_800482 C_800482 C_800482 C_800481 C_800481 C_800
#594	C_608377 C_608377 C_414635 C_414635 C_480086 C_480086 C_58577 C_58
#558	C_157789 C_782317 C_782317 C_782317 C_782317 C_782317 C_782317 C_7
#551	C_24282 C_618115 C_606874 C_606874 C_24282 C_256906 C_256906 C_256
#549	C_650176 C_676568 C_650176 C_68034 C_187963 C_187963 C_767787 C_55
#549	C_676568 C_676568 C_650176 C_68034 C_187963 C_187963 C_767787 C_55
#545	C_68034 C_68034 C_676568 C_650176 C_187963 C_187963 C_767787 C_755
#


my %group;

while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    my @ss = split /\s/,$s[1];
#    print  "$ss[0]\n";
    if (exists $group{$ss[0]} ) {
#        print  "drop\n";
        next;
    }
    else {
        print OUT "$s[0]\t$ss[0]";
        $group{$ss[0]} = 1;
        for (my $k=1;$k<scalar @ss ;$k++) {
            unless (exists $group{$ss[$k]}) {
                $group{$ss[$k]} = 1;
                print OUT " $ss[$k]";
            }
        }
        print OUT "\n";
    }        
}



