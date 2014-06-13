#!/usr/local/bin/perl -w
# 
# Copyright (c) Martin Xu 2004
# Author:         xujzh <xujzh@genomics.org.cn>
# Program Date:   2004.04.
# Modifier:       xujzh <xujzh@genomics.org.cn>
# Last Modified:  2004.04.
# Version:        1.0


use strict;
use Getopt::Long;
use Data::Dumper;
my %opts;
GetOptions(\%opts,"i=s","o=s","p=s","pa=s","h" );

#&help()if(defined $opts{h});
if(!defined($opts{i}) || !defined($opts{o}) || !defined($opts{p}) || defined($opts{h})){
	my $ver="1.0";
	print <<"	Usage End.";
	Description:
	
		Version: $ver
	Usage:

		-p	infile of the pep sequence	must be given
		-i	infile of the nt sequence	must be given
		-o	outfile		must be given
		-pa    	parameter of genewise
		
	example:	genewise_shell.pl -p all.pep -i all_bgi.seq -pa "-both -genesf -pretty" -o all.genewise.out	
	
	Usage End.

	exit;
}
my $protein=$opts{p};
my $out=$opts{o};
my $in=$opts{i};

$/="\>";
open (IN,"$protein")||die"Can't open $protein\n";

system "mkdir genewise_tmp" unless -d "genewise_tmp";
system "mkdir genewise_tmp\/pep" unless -d "genewise_tmp\/pep";
my $null=<IN>;
my @list_pep=();
my $i=0;

while(<IN>)
{
	chop if (/\>/);
	my @f=split/\n/;
	my @F=split(" ",$f[0]);
	$list_pep[$i++]="genewise_tmp\/pep\/$F[0].pep";
	open (OUT, ">genewise_tmp\/pep\/$F[0].pep");
	print OUT "\>$_";
	close OUT;
}
close IN;

system "mkdir genewise_tmp\/nt" unless -d "genewise_tmp\/nt";

open (IN,"$in")||die"Can't open $in\n";
$null=<IN>;
while(<IN>)
{
	chop if (/\>/);
	my @f=split/\n/;
	my @F=split(" ",$f[0]);
	#warn"$f[0]\n$F[0]\n";
	open (OUT, ">genewise_tmp\/nt\/$F[0].nt");
	print OUT "\>$_";
	close OUT;
	foreach(@list_pep)
	{
		system "genewise $_ genewise_tmp\/nt\/$F[0].nt $opts{pa} >> genewise_tmp\/$F[0].out_tmp 2> genewise_tmp\/all_warn";
	}
}
close IN;

system "cat genewise_tmp\/\*.out_tmp > $out";
exit;



	
	
