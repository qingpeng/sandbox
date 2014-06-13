#!/usr/bin/perl -w

use strict;

die "need para!" if (0==@ARGV);


open (LOG,"$ARGV[0]") || die "$!";

my ($read,$chr);

system "rm -f blastZ.out";

while (<LOG>) {
    s/\S+\s+(\S+)/$1/;
    $read=$1;
    $_=<LOG>;
    s/\S+\s+(\S+)/$1/;
    $chr=$1;
    system "blastz $read $chr >> blastZ.out";
}

close LOG;
