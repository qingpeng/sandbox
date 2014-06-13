#!/usr/bin/perl -w
use strict;

die "need two paras: est list and oligo index file\n" if (@ARGV<2);

open (LIST,"$ARGV[0]")|| die;

my %estList;
while (<LIST>) {
	chomp;
	$estList{$_}=1;
}
close (LIST);

open (IN,"$ARGV[1]")|| die;
open (EST,">EST.part")|| die;
open (GENOME,">GENOME.part")|| die;

my $name;
while (<IN>) {
    if (/(.*)\_\d+\_\d+\_\d+\_\d+\_\d+/) {
		$name=$1;
    } elsif (/(.*)\_\d+\_\d+\_\d+/) {
		$name=$1;
    } else {die "check input files\n";}
	if (exists $estList{$name}) {
		print EST ;
	} else {
		print GENOME ;
	}
}

close IN;
close EST;
close GENOME;

