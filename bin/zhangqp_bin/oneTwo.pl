#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts('i:d:',\%opts);
die "$0: seperate items with one and >=2 results(note the format!!)\nneed three paras:\n\t\-i\tinput result file\n\t-d\tindex field in the result file(seperated by \'blank region\')\nNote: lines begin with \"\#\" will be passed!\n" if (not exists $opts{"i"} or not exists $opts{"d"} );

my $indexField=$opts{"d"}-1;
my $inFile=$opts{"i"};

open (IN,"$inFile") || die "$!";

my %preHash;
#read result file
while (<IN>) {
    #bypass the "^\#" line
    next if (/^\#/);
    my @line=split(/\s+/,$_);
    if (not exists $preHash{$line[$indexField]}) {
	$preHash{$line[$indexField]}=[$_];
    } else {
	push @{$preHash{$line[$indexField]}},$_;
    }
}

# reading over

close IN;


open (ONE,">$inFile\.one") || die "$!";
open (TWO,">$inFile\.two") || die "$!";


foreach (sort keys %preHash) {
    my @tmp=@{$preHash{$_}};
    if (1==@tmp) {
	print ONE @tmp;
    } elsif (2<=@tmp) {
	print TWO @tmp;
    } else {die"I"}
}

print "check:\n$inFile\.one for single hitted item \n$inFile\.two for multiply hitted ones\n";

close ONE;
close TWO;

