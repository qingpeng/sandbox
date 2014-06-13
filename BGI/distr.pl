#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts('i:n:d:s:',\%opts);
die "$0: cal the distr\nneed four paras:\n\t\-i\tinput result file\n\t-d\tindex field in the result file(seperated by \'blank region\')\n\t-s\tsorted field in the result file(seperated by \'blank region\')\n\t-n\trow u wanted\nNote: lines begin with \"\#\" will be passed!\n" if (not exists $opts{"i"} or not exists $opts{"d"} or not exists $opts{"s"} or not exists $opts{"n"} );

my $indexField=$opts{"d"};
my $sortField=$opts{"s"};
my $inFile=$opts{"i"};
my $row=$opts{"n"};

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
    die "error in input file! It should be >$row lines per item!" if (@tmp<$row-1);

    my $t=int ((split(/\s+/,$tmp[$row-1]))[$sortField-1]);

    $distr{$t} ? ($distr{$t}++) : ($distr{$t} =1);
    $distrItems{$t} ? ($distrItems{$t}.=$tmp[$row-1]) : ($distrItems{$t} =$tmp[$row-1]);

}

my $count;

open (OUT,">distrOfRow$row.$inFile\.sortAt$sortField") || die "$!";
foreach (sort {$b <=> $a}  keys %distr) {
    $count += $distr{$_} ;
    print "$_\t$distr{$_}\n";
    print OUT ">$_\t$distr{$_}\t$count\n$distrItems{$_}";
}

print "total: $count\n";

print "check distrOfRow$row.$inFile\.sortAt$sortField\n";
close OUT;

