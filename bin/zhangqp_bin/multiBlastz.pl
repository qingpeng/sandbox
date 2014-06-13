#!/usr/bin/perl -w
# 
#
#
#


use strict;
use Getopt::Std;

my %opts;
getopts( "i:o:thv" , \%opts );
my $perlInfoAuth = "Liu Tao";
my $perlInfoVer = "1.0";
my $perlInfoEmail = "liut\@genomics\.org\.cn";
my $perlInfoLastModified = "11/05/1980";
my $perlInfoUsage = <<"Usage";
$0: 
Need paras:
    <-i <filename>> Input file
    <-o <filename>> Ouput file
    <-t>          type
    [-h]          help
    [-v]          version
$perlInfoAuth made this program at $perlInfoLastModified version $perlInfoVer
Report bugs to $perlInfoEmail 
Usage

die "$perlInfoUsage" if ( exists $opts{"h"} );

die "$perlInfoVer\n" if ( exists $opts{"v"} );

die "Error: need paras\n$0 -h for help\n" unless ( $opts{"i"} and $opts{"o"} and exists $opts{"t"} );

########end of template.pl####################
