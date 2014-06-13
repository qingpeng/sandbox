#!/usr/bin/perl -w
use strict;
use List::Util qw(shuffle);


if (@ARGV < 2) {
	print "perl *.pl file_in file_out \n";
	exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";



my @lines;
while (<IN>) {
    push(@lines, $_);
}
my @reordered = shuffle(@lines);
foreach (@reordered) {
    print OUT $_;
}



