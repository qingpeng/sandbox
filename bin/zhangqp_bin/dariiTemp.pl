#!/usr/bin/perl -w

use strict;

die "need 1 para: $0 <filename>\n" if @ARGV!=1;
open ( IN,"< $ARGV[0]" ) || die "cannot open $ARGV[0]:$!\n" ;

###templateSimple.pl### 

my $first;
my $second;
my %reads;


while (<IN>) {
    $first = (split(/\s+/,$_))[1];
    $second = <IN>; $second = (split(/\s+/,$second))[1];
    my $name = (split(/\s+/,$_))[0];
    $reads{$name} = sprintf("%.1f",((($first - $second)/$first)*100));
}

foreach (keys %reads) {
    print $_."\t".$reads{$_}."\n";
}
