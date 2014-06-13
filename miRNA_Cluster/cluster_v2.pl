#!/usr/bin/perl -w
use strict;
use Cluster;

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";


#C_70872 C_51983 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_51983 100.00  17      0       0       8       24      22      6       0.008   34.2
#C_70872 C_49931 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_49931 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_47637 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_47637 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_41652 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_41652 100.00  17      0       0       8       24      22      6       0.008   34.2
#C_70872 C_41190 100.00  17      0       0       8       24      17      1       0.008   34.2
#C_70872 C_37345 100.00  17      0       0       8       24      6       22      0.008   34.2
#C_70872 C_35299 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_35299 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_30499 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_30499 100.00  17      0       0       8       24      22      6       0.008   34.2

#my $refgraphEdges;
#my $refgraphNodeDegs;
my $loaded;
my $isNewNode;
my %graphEdges;
my %graphNodeDegs;


while (<IN>) {
    chomp;
    my @s =split /\s+/,$_;
   # print  "$s[0]\t$s[1]\n";
    ($loaded, $isNewNode)=loadEdgeAndNodeLists(\%graphEdges, \%graphNodeDegs, $s[0], $s[1]);
}

print  "Load over!\n";
#print  "$loaded\n$isNewNode\n";
#my $test2 = $refgraphEdges->{"C_70778|C_793105"};
#if (exists ${$refgraphEdges}{"C_70778|C_793105"}) {
#    print  "OK\n";
#}
#if (exists $refgraphEdges->{"C_70778|C_793105"}) {
#     print "OK22\n";
#
#}
#print  "111$test2 111\n";
#my %test1 = %graphNodeDegs;


#print  "%test1\n";

my ($ref_compEdges,$ref_compNodes,$largestCompID) = getComponentSizes(\%graphNodeDegs);

my %compNodes = %$ref_compNodes;
my @nodes;
my $size;

foreach my $nodeID (keys %compNodes) {
    @nodes = keys %{$compNodes{$nodeID}};
    $size = scalar @nodes;
    print OUT "$nodeID\t$size\t@nodes\n";
}
