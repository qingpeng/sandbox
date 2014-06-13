#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";


#N_2751959	34.22966014820828596588302901347
#N_2506443	32.02690857038523033744067774327
#N_6347	30.00927926181062913806458923063
#N_3055263	29.35484318622670716041082594996
#N_2489447	29.35484318622670716041082594996



my %count;
while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    my $score = int($s[1]);
    if (exists $count{$score}) {
        $count{$score} ++;
    }
    else {
        $count{$score} = 1;
    }

}

foreach my $key (sort keys %count) {
    print OUT "$key\t$count{$key}\n";
}



