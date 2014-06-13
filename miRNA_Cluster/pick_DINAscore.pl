#!/usr/bin/perl -w
use strict;
# pick the score and to be positive
# 2006-12-18 10:21
#
if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";
#
##T	-RT ln Z	Z
#37	-52.5	9.86078e+036
#37	-80.9	1.01357e+057
#37	-68.7	2.56552e+048
#37	-56.3	4.69425e+039
#37	-48.3	1.08243e+034
#37	-73.2	3.80261e+051
#37	-58.3	1.20464e+041
#37	-50.9	7.35322e+035
#37	-66.3	5.22426e+046
#

my $score;

while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    unless ($_=~/^\#/) {
        $score = 0-$s[1];
        if ($score>0) {
        
        print OUT "$score\n";
        }
    }
}

