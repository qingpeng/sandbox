#!/usr/bin/perl -w


use strict;

die "need two para: thrown file list and input fasta file!\n"if (@ARGV<2);

open (LIST,"$ARGV[0]") || die;

my %list;
while (<LIST>) {
    chomp;
    $list{$_}=1;
}


close LIST;

open (IN,"$ARGV[1]") || die;
open (REMAIN,">remain.fasta") || die;
open (THROWN,">thrown.fasta") || die; 

$/="\>";

<IN>;
while (<IN>) {
    chomp;
    if (/^(\S+)\s+/) {
	my $name=$1;
	if (exists $list{$name}) {
	    print THROWN "\>$_";
	} else {
	    print REMAIN "\>$_";
	}
    } else {die "check input file!\n";}
}

close IN;
close REMAIN;
close THROWN;
