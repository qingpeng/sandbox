#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts('i:n:d:s:t:',\%opts);
die "$0: pick the best few results(note the format!!)\nneed five paras:\n\t\-i\tinput result file\n\t-n\tnumber of best results\n\t-d\tindex field in the result file(seperated by \'blank region\')\n\t-s\tsorted field in the result file(seperated by \'blank region\')\n\t-t\ttype of result file (n-> blastN;x-> blastX)\nNote: lines begin with \"\#\" will be passed!\n" if (not exists $opts{"i"} or not exists $opts{"n"} or not exists $opts{"d"} or not exists $opts{"s"} or not exists $opts{"t"} );

my $indexField=$opts{"d"}-1;
my $sortField=$opts{"s"}-1;
my $inFile=$opts{"i"};
my $number=$opts{"n"};
my $type=$opts{"t"};

open (IN,"$inFile") || die "$!";

if ($type ne "n" and $type ne "x") {
    die "\"$type\" is an invalid file type!\nNote: n-> blastN;x-> blastX\n";
}

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

foreach (sort keys %preHash) {
    my @tmp=@{$preHash{$_}};
    my $n=0;
    foreach my $tmp (sort {(split(/\s+/,$b))[$sortField] <=> (split(/\s+/,$a))[$sortField] }  @tmp) {
	print "$tmp";
	$n++;
	last if ($n==$number);
    }
}


close IN;

