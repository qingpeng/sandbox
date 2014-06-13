#!/usr/local/bin/perl -w
# 
# Copyright (c) BGI 2003
# Author:         Liudy <liudy@genomics.org.cn>
# Program Date:   2004.01.
# Modifier:       Liudy <liudy@genomics.org.cn>
# Last Modified:  2004.01.
# Version:        1.0


#use strict;
#use Getopt::Long;
#use Data::Dumper;
#########################################################################################
if (@ARGV<3){
	print "Usage: program contig endlove od\n";
	exit;
}
open (S,"$ARGV[0]")||die"Can't open $ARGV[0]\n";
open (G,"$ARGV[1]")||die"Can't open $ARGV[1]\n";
$out_name=(split(/\//,$ARGV[0]))[0];
$out_name=(split(/[\_\.]/,$out_name))[0];
$od=$ARGV[2];
$od=~s/\/$//;
#########################################################################################
$/=">";
while (<S>) {
	chomp;
	if ($_ ne "") {
		$name=(split(/\s+/,$_))[0];
		$name=(split(/\./,$name))[-1] if($name=~/\./);
		$seq=(split(/\n/,$_,2))[1];
		$seq=~s/\n//g;
		$hash_ctg{$name}=$seq;
	}
}
close S;

$/="Scaffold";
#Scaffold000001. 60161
#        1       Contig8. U      4511
while (<G>) {
	chomp;
	if ($_ ne "") {
		@sca=();
		@start=();
		@end=();
		@line=split(/\n/,$_);
		$sca_name=(split(/\./,$line[0]))[0];
		shift @line;
		foreach $x (@line) {
			@info=split(/\s+/,$x);
			$ctg=$info[2];
			$ctg=~s/\.//;
			$ori=$info[3];
			$startt=$info[1];
			$length=$info[4];
			$endd=$startt+$length-1;
			if ($ori eq "C") {
				$hash_ctg{$ctg}=reverse $hash_ctg{$ctg};
				$hash_ctg{$ctg}=~tr/ATGCatgc/TACGtacg/;
			}
			push (@sca,$ctg);
			push (@start,$startt);
			push (@end,$endd);
		}
		for ($i=0;$i<@sca-1 ;$i++) {
			$prm_name="BSBP_"."$sca_name"."_$end[$i]";
			$len1=&min(length($hash_ctg{$sca[$i]}),500);
			$len2=&min(length($hash_ctg{$sca[$i+1]}),500);
			$seq1=substr($hash_ctg{$sca[$i]},length($hash_ctg{$sca[$i]})-$len1,length($hash_ctg{$sca[$i]})-1);
#			$seq2=substr($hash_ctg{$sca[$i+1]},length($hash_ctg{$sca[$i+1]})-$len2,length($hash_ctg{$sca[$i+1]})-1);
			$seq2=substr($hash_ctg{$sca[$i+1]},0,$len2);
			$prm_seq=$seq1."N".$seq2;
			$left_size=$len1;
			$gap_size=$start[$i+1]-$end[$i]-1;
			$gap_size=500 if($gap_size<500);
			$gap_max=$gap_size+500;
			open (OUT,">$od/$prm_name.prm");
			&output;
			close OUT;
			system ("primer3_core < $od/$prm_name.prm > $od/$prm_name.primer");
		}
	}
}
close G;
system ("rm $od/*.prm");

sub output{
print OUT <<"map";
PRIMER_SEQUENCE_ID=$prm_name
SEQUENCE=$prm_seq
PRIMER_OPT_SIZE=20
PRIMER_MAX_SIZE=23
PRIMER_MIN_SIZE=18
PRIMER_OPT_TM=59
PRIMER_MAX_TM=60
PRIMER_MIN_TM=58
PRIMER_NUM_RETURN=1
TARGET=$left_size,50
PRIMER_PRODUCT_SIZE_RANGE=50-$gap_max
PRIMER_PRODUCT_OPT_SIZE=$gap_size
PRIMER_MIN_GC=30
PRIMER_MAX_GC=60
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  

sub min {
	my ($x1,$x2)=@_;
	my $min;
	if ($x1 < $x2) {
		$min=$x1;
	}
	else {
		$min=$x2;
	}
	return $min;
}

