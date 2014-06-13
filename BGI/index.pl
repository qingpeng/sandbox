#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i1:s","i2:s","o:s");
my $ver="1.0-compact";
my $usage=<<"Usage";
    Name: $0
    Description: 
    Version: $ver
    Contact: "liut AT genomics DOT org DOT cn"
    Usage: $0 [options]
    -i1 filein1 table
    -i2 filein2 title.list
    -o  fileout 
Usage

die $usage unless $opts{"i1"} and $opts{"i2"} and $opts{"o"};

my $filein1=$opts{"i1"};
my $filein2=$opts{"i2"};
my $fileout=$opts{"o"};

open(IN1,"$filein1") || die;
open(IN2,"$filein2") || die;
open(OUT,">$fileout") || die;

my %seqGene;

$/="\@";

<IN1>;
while(<IN1>){
    chomp;
    my @slist=split(/\n/);
    my $gene=$slist[0];
    for (my $j=1;$j<@slist;$j++) {
	my @tmp=split(/\s+/,$slist[$j]);
	next if(@tmp<2);
#cpg0_159572.z1.abd,genome       357     502     +
	my $name=(split(/\,/,$tmp[0]))[0];
#	if ($name eq "bbdc_74451.z1.abd") {
#		print  "$name\t$tmp[1]\t$tmp[2]\n";
#	}
	$name="$name\_$tmp[1]\_$tmp[2]";

#if ($name eq "bbdc_74451.z1.abd_263_395"){
#print "$name\n";}
#print "B:::$name\n";
	$name=$1 if ($name=~/^singleton\_(.*)/);
	warn "check: $name\n" if (exists $seqGene{$name});
	$seqGene{$name}="$gene";
    }   
}

print "sequence-Gene list ready...\n";

#foreach (sort keys %seqGene) {
#    print "$_\n";
#}

$/="\n";

my %oligoGene;
while (<IN2>) {
    chomp;
    if (/(.*\_\d+\_\d+)\_\d+\_\d+\_\d+/) {
	#print "1::$1 and $seqGene{$1}";
	die "A::$1\n" if (not exists $seqGene{$1});
	warn "B::$oligoGene{$_}" if (exists $oligoGene{$_});
	$oligoGene{$_}=$seqGene{$1};
    } elsif (/(.*\_\d+\_\d+)\_\d+/) {
	#print "2::$1 and $seqGene{$1}";
	die "C::$1\n" if (not exists $seqGene{$1});
	warn "D::$oligoGene{$_}" if (exists $oligoGene{$_});
	$oligoGene{$_}=$seqGene{$1};
    }
}

print "oligo-Gene list ready...\n";

foreach (keys %oligoGene) {
    #print "$_\t$oligoGene{$_}";
    print OUT "$_\t$oligoGene{$_}\n";
}




close IN1;
close IN2;
close OUT;
