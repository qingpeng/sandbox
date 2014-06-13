#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts('i:n:d:s:t:e',\%opts);
die "$0: analyze program for perticular usage\nneed three\+one paras:\n\t\-i\tinput result file\n\t-d\tindex field in the result file(seperated by \'blank region\')\n\t-s\tsorted field in the result file(seperated by \'blank region\')\n\t[-t]\tmin percentage(\%) of the second value to the first,\n\t\tdefault: 0=no limit\n\t[-e]\tNo argu.\n\t\tIf the sorted field refers to E-value, then I do not do percentage work and cut the exponent\nNote: lines begin with \"\#\" will be passed!\n" if (not exists $opts{"i"} or not exists $opts{"d"} or not exists $opts{"s"} );

my $indexField=$opts{"d"};
my $sortField=$opts{"s"};
my $inFile=$opts{"i"};
my $time=($opts{"t"} or 0);
my $e=(exists $opts{"e"});

open (IN,"$inFile") || die "$!";

my %preHash;
#read result file
while (<IN>) {
    #bypass the "^\#" line
    next if (/^\#/);
    my @line=split(/\s+/,$_);
    if (not exists $preHash{$line[$indexField-1]}) {
	$preHash{$line[$indexField-1]}=[$_];
    } else {
	push @{$preHash{$line[$indexField-1]}},$_;
    }
}
close IN;
# reading over

my %distr;
my %distrItems;

foreach (sort keys %preHash) {
    my @tmp=@{$preHash{$_}};
    die "error in input file! It should be _ONLY_ 2 lines per item!" if (@tmp!=2);
    my @twoValues=();
    for (my $i=0;$i<2;$i++) {
	push @twoValues,((split(/\s+/,$tmp[$i]))[$sortField-1]);
    }
    #die "error in input file! lines must be sorted for each item!" if ($twoValues[0]<$twoValues[1]);
    my $t;
    if ($e) {
	if ($twoValues[0] != 0) {
	    $t=int ((log($twoValues[1]))/(log($twoValues[0])));	    
	} else {
	    #die "@tmp\n";
	    $t=999;
	}
    } else {
	$t=int ($twoValues[1]/$twoValues[0]*100);
    }
    #print "$t\n";
    $distr{$t} ? ($distr{$t}++) : ($distr{$t} =1);
    $distrItems{$t} ? ($distrItems{$t}.=join "",@tmp) : ($distrItems{$t} =join "",@tmp);
}

my $count;

open (OUT,">$inFile\.analysis$time\.sortAt$sortField") || die "$!";
foreach (sort {$b <=> $a}  keys %distr) {
    last if ($time!=0 and $_<$time);
    $count += $distr{$_} ;
    print "$_\t$distr{$_}\n";
    print OUT ">$_\tnumber:$distr{$_}\taccumulation\_$_:$count\n$distrItems{$_}";
}

print "total: $count\n";

print "check $inFile\.analysis$time\.sortAt$sortField\n";
close OUT;

