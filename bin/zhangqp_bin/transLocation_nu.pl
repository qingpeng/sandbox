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
    Description: translate plain table into location table  
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
# Query  Subject Q_len   S_len   Score   Direction       Q_X     Q_Y     S_X     S_Y     Length  Overlap Gap     Identit
#BD_97035.z1.abd chr16_20715008_20715163_20714008_to_20716163    290     2156    16407   -       1       290     885     1162       290     230     15      79.3
###ouput file
###location in chromosome
##Read AlignmentLen Read_start ------ Read_end Chromosome AlignmentLen Chr_start ------ Chr_end |Direction
##plate name:BDB_797
#BD_97035.z1.abd  290 1 ------ 290 chr16 278  20715002 ------ 20715279 |-
########################

#my @line;
my ($read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrS,$chrE,$chrStart,$chrEnd);
my $intervalS;
my $intervalE;
my $direction; # reverse must be recalculate

print OUT "#Read AlignmentLen Read_start ------ Read_end Chromosome AlignmentLen Chr_start ------ Chr_end |Direction\n";
while (<IN>) {
    #(print OUT),
    next if (/^\#/);
    @_=split(/\s+/);
    ($read,$readStart,$readEnd,$chr,$chrS,$chrE,$direction)=@_[0,6,7,1,8,9,5];
    $readAlignmentLength=$readEnd-$readStart+1;
    $chrAlignmentLength=$chrE-$chrS+1;
    die "Cannot be negitive!\n$_\n" if $readAlignmentLength<0 or $chrAlignmentLength<0;
    @_=split(/\_/,$chr);  #chr16_20715008_20715163_20714008_to_20716163 '20714008' is the real start point.
    die "wrong:\n$chr\n:$!" if (@_!=6);
    $chr=$_[0];
    $intervalS=$_[3];
    $intervalE=$_[5];
    # calculate positions in chr.
    # note the direction!
    if ( $direction eq "+" ) { # forward
	$chrStart=$chrS+$intervalS-1;
	$chrEnd=$chrE+$intervalS-1;
    } elsif ( $direction eq "-" ) { # rc
	$chrStart=$intervalE-$chrE+1;
	$chrEnd=$intervalE-$chrS+1;
    } else {die "wrong direction field!\n$_:$!\n";}
    
    printf OUT ("%-25s%4d\t%4d ------ %4d\t%-10s%4d\t%10d ------ %10d\t\|%s\n",$read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrStart,$chrEnd,$direction);
}

close IN;
close OUT;
