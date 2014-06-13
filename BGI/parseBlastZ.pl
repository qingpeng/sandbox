#!/usr/bin/perl -w

use strict;
use Getopt::Std;

my %opts;
getopts("i:o:thv",\%opts);
my $perlInfoAuth="LIu TAo";
my $perlInfoVer="3.141";
my $perlInfoEmail="liut\@genomics\.org\.cn";
my $perlInfoLastModified="Today";
my $perlInfoUsage=<<"Usage";
$0: parse blastz result to a format like blastn -m8 result
[*]Plz remember the differences between blastn and blastz. While an alignment is refered to 'reverse complement', blastz gives the alignment positions in _REVERSE COMPLEMENT_ subject! So this program do. 
[*]Any broken blastz result would bring you unexpected output, beware!
Need paras:
    <-i <filename>> Input file
    <-o <filename>> Ouput file
    [-h]          help
    [-v]          version
$perlInfoAuth made this program at $perlInfoLastModified version $perlInfoVer
Report bugs to $perlInfoEmail 

Usage

die "$perlInfoUsage" if (exists $opts{"h"});

die "$perlInfoVer\n" if (exists $opts{"v"});

die "Error: need paras\n$0 -h for help\n" unless ($opts{"i"} and $opts{"o"});

########end of template.pl####################


my $inFile=$opts{"i"};
my $outFile=$opts{"o"};

$/="\#\:lav";
my %content;
my ($query,$subject,$queryLength,$subjectLength,$score,$queryBegin,$queryEnd,$subjectBegin,$subjectEnd);
my ($alignmentLength,$overlap,$gapFree,$identity,$direction);

open (IN,"$inFile") ||die "$!";
open (OUT,">$outFile") ||die "$!";
open (LOG,">parse.log") || die "$!";

print OUT "\#Query\tSubject\tQ_len\tS_len\tScore\tDirection\tQ_X\tQ_Y\tS_X\tS_Y\tLength\tOverlap\tGap\tIdentity\n";

print "Process engaged!\nPlease wait...";

my $multiple;
my $totalMultiple=0;
my $totalNonresult=0;
my $id;

<IN>;
while (<IN>) {
    chomp;
    %content=();
    $multiple=0;
    if (/d\s+\{/) {
	if (/\"(.*)\n/) {
	    $id=$1;
	}else {
	    die "impossible!";
	}
	#(split(/\n/,$_))[0];
	if (/m\s+\{/) { #no alignment result...
	    print LOG "\"$id\" didnot produce any result!\n";
	    $totalNonresult+=1;
    	}
	next; 
    }
    
    while (/(\w+)\s+\{([^\}]+)\}/g) {
	if (exists $content{$1}) {
	    $content{$1}.="<=>$2";
	    die "Error: format error in $_"if ($1 ne "a");
	    $multiple+=1;
	} else {
	    $content{$1}=$2;
	}
    }
#     if (not exists $content{'a'}) { #no alignment result...
#     	print LOG "$id didnot produce any result!\n";
# 	$totalNonresult+=1;
#     }
    
    #parsing...
    ($query,$subject,$queryLength,$subjectLength,$score,$queryBegin,$queryEnd,$subjectBegin,$subjectEnd)=();
    ($alignmentLength,$overlap,$gapFree,$identity,$direction)=();
    
    #parsing "s {" stanza
    unless ($content{'s'}=~/\".*\"\s+(\d+)\s+(\d+)\s+\d+\s+\d+\s+\".*\"\s+(\d+)\s+(\d+)\s+\d+\s\d+/){
	die "Error: \'s {\'format error in $content{s}";
    }
    #print "$content{h}";
    $queryLength=$2-$1+1;
    $subjectLength=$4-$3+1;
    
    #parsing "h {" stanza
    unless ($content{'h'}=~/\"\>(.*)\"\s+\"\>(.*)\"/){
	die "Error: \'h {\'format error in $content{h}";
    }
    $query=$1;
    $subject=$2;
    if ($subject=~s/\s*\(reverse complement\)\s*//) {
	$direction="-";
    } else {
	$direction="+";
    }
    $query=~s/\s+/\_/g;
    $subject=~s/\s+/\_/g;
    
    #parsing "a {" stanza
    my @a=split (/\<\=\>/,$content{'a'});
    foreach $a (@a){
	
	unless ($a=~/s\s+(\d+)\s+b\s+(\d+)\s+(\d+)\s+e\s+(\d+)\s+(\d+)/){
	    die "Error: \'a {\'format error in  $a";
	}
	($score,$queryBegin,$subjectBegin,$queryEnd,$subjectEnd)=($1,$2,$3,$4,$5);
	#print "$score,$queryBegin,$subjectBegin,$queryEnd,$subjectEnd\n";
	$alignmentLength= ($queryEnd-$queryBegin)>($subjectEnd-$subjectBegin)?($queryEnd-$queryBegin+1):($subjectEnd-$subjectBegin+1);
	$overlap=$gapFree=0;
	while ($a=~/l\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/g) {
	    if (($3-$1)!=($4-$2)) {
		die "Error: unexpected link info in $a" ;
	    }
	    $gapFree+=($3-$1+1);
	    $overlap+=sprintf("%.0f",($3-$1+1)*$5/100);
	}
	$identity=($overlap/$alignmentLength)*100;
	#format and output
	printf  OUT "%s\t%s\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%2.1f\n",
	$query,$subject,$queryLength,$subjectLength,
	$score,$direction,$queryBegin,$queryEnd,
	$subjectBegin,$subjectEnd,$alignmentLength,$overlap,
	$alignmentLength-$gapFree,$identity
	    ;    
    }
    if ($multiple) {
    	$multiple++;
    	print LOG "check \'$query\' result for multiple alignments for $multiple times\n";
	$totalMultiple+=$multiple;
    }
}
print LOG "total multiple aligments: $totalMultiple\ntotal no result pairwise: $totalNonresult\n";

close IN;
close OUT;

print "\nProcess finished!\ncheck \'$outFile\'\n\[\*\]Plz remember the differences between blastn and blastz. While an alignment is refered to 'reverse complement', blastz gives the alignment positions in _REVERSE COMPLEMENT_ subject! So this program do.\n";










