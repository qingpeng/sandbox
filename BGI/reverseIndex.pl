#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","o:s");
my $ver="1.0-compact";
my $usage=<<"Usage";
    Name: $0
    Description: 
    Version: $ver
    Contact: "liut AT genomics DOT org DOT cn"
    Usage: $0 [options]
    -i filein oligoGene.index
    -o  fileout 
Usage

die $usage unless $opts{"i"} and $opts{"o"};

my $filein=$opts{"i"};
my $fileout=$opts{"o"};

open(IN,"$filein") || die;
open(OUT,">$fileout") || die;

#my %oligoGene;
my %geneOligo;


print "making index, wait...\n";

while(<IN>){
    chomp;
    #print "line::$_\n";
    my @eList=split(/\s+/);
    my ($oligoName,$geneName)=@eList;
    
    if (not exists $geneOligo{$geneName}) {$geneOligo{$geneName}="";}
    $geneOligo{$geneName}.="$oligoName\n";
}

print "index ready...\nwait while I write the index to $fileout...\n";

#my $n;
foreach my $gene (sort {(split(/\,/,$a))[0] cmp (split(/\,/,$b))[0] } keys %geneOligo){
    print OUT "\@$gene\n";
    #$n++;
    print OUT "$geneOligo{$gene}";
}

#print "$n lines output!\n";
print "done!\n";

close IN;
close OUT;
