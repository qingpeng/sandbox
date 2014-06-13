#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts('i:l:f:',\%opts);
die "$0: pick the results from result file according to a specific list(note the format!!)\nneed three paras:\n\t\-i\tinput result file\n\t-l\tinput reads list\n\t-f\tindex field in the result file(seperated by \'blank region\')\nNote: lines begin with \"\#\" will be passed!\n" if (not exists $opts{"i"} or not exists $opts{"l"} or not exists $opts{"f"});

my $field=$opts{"f"}-1;
my $inFile=$opts{"i"};
my $listFile=$opts{"l"};



open (IN,"$inFile") || die "$!";
open (LIST,"$listFile") || die "$!";

my %list;
#read list file
while(<LIST>) {
    chomp;
    s/^\s*(\S+).*/$1/;
    $list{$_}=1;
}
# reading over

#read result file
while (<IN>) {
    #bypass the "^\#" line
    next if (/^\#/);
    my @tmp=split(/\s+/,$_);
    if (exists $list{$tmp[$field]}) {
	print $_;
    }
} 

# over





close IN;
close LIST;

