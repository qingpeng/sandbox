#!/usr/bin/perl -w
use strict;

if (@ARGV < 1) {
    print "perl *.pl file_in  \n";
    exit;
}
my ($file_in) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";




##bin	matches	misMatches	repMatches	nCount	qNumInsert	qBaseInsert	tNumInsert	tBaseInsert	strand	qName	qSize	qStart	qEnd	tName	tSize	tStart	tEnd	blockCount	blockSizes	qStarts	tStarts
#585	330	13	0	0	2	2	3	4	-[9]	AA663731	346	1	346	chr1[14]	247249719	2802[16]	3149[17]	6	47,26,73,27,165,5,[19]	0,47,74,147,174,340,	2802,2850,2876,2951,2979,3144,[21]
#585	393	7	0	0	0	0	0	0	+	AA936549	409	9	409	chr1	247249719	4224	4624	1	400,	9,	4224,
#585	372	8	0	0	0	0	0	0	+	AA293168	380	0	380	chr1	247249719	4263	4643	1	380,	0,	4263,
#585	391	8	0	0	0	0	0	0	+	AA458890	399	0	399	chr1	247249719	4263	4662	1	399,	0,	4263,




while (<IN>) {
    chomp;
    unless ($_=~/^\#/) {
    
    my @s =split /\t/,$_;
    my $file_tmp = $file_in.".$s[14]";
    open TMP,">>$file_tmp";
    print TMP "$_\n";

    }
}



