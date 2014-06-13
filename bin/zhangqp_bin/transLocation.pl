#!/usr/bin/perl -w
#$Title: locate.pl
#$Version:
#$Usage:
#$Parameter:
#$Author:
#$Date:

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","o:s");
my $ver="1.0";
my $usage=<<"Usage";
    Name: $0
    Description:  
    Version: $ver
    Contact: "liut AT genomics DOT org DOT cn"
    Usage: $0 [options]
    -i filein
    -o fileout
Usage

die $usage unless $opts{"i"} and $opts{"o"};

########end of template.pl####################

my ($infile,$outfile)=($opts{"i"},$opts{"o"});
open (IN,$infile) || die;
open (OUT,">$outfile") || die;

########################
###input file
##read score R_A_L R_X R_Y total id e_value |Chr Chr_A_L Chr_X Chr_Y|mis gap
##plate name:BDB_797
#BDB_79703.z1.abd 73.84 124 339 462 127 82.68 6.4e-09 |chr10_135037215_60000000   127 301364 301490 |19 1
#
###ouput file
###location in chromosome
##Read AlignmentLen Read_start ------ Read_end |Chromosome AlignmentLen Chr_start ------ Chr_end 
##plate name:BDB_797
#BDB_79703.z1.abd 124 339 ------ 462 |chr10 127 60301364 ------ 60301490 
########################

#my @line;
my ($read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrStart,$chrEnd);
my $interval;

print OUT "#Read AlignmentLen Read_start ------ Read_end |Chromosome AlignmentLen Chr_start ------ Chr_end\n";
while (<IN>) {
    (print OUT),next if (/^\#/);
    @_=split(/\s+/);
    ($read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrStart,$chrEnd)=@_[0,2,3,4,8,9,10,11];
    @_=split(/\_/,$chr);  #chr10_135037215_60000000
    $chr=$_[0];
    if (exists $_[2]) {$interval=$_[2];} else {$interval=0;}
    $chrStart+=$interval,$chrEnd+=$interval;
    printf OUT ("%-25s%4d\t%4d ------ %4d\t%-10s%4d\t%10d ------ %10d\n",$read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrStart,$chrEnd);
}

close IN;
close OUT;
