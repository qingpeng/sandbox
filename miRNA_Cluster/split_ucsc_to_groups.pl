#!/usr/bin/perl -w
use strict;
# split lt30 .ucsc file into different chromosome
# 2006-8-22 17:15
# 


if (@ARGV < 1) {
	print "perl *.pl *.ucsc \n";
	exit;
}
my ($file_in) = @ARGV;

my $file_out1 = $file_in.".chr1_4";
my $file_out2 = $file_in.".chr5_9";
my $file_out3 = $file_in.".chr10_13";
my $file_out4 = $file_in.".chr14_17";
my $file_out5 = $file_in.".chr18_";

open IN,"$file_in";
open OUT1,">$file_out1";
open OUT2,">$file_out2";
open OUT3,">$file_out3";
open OUT4,">$file_out4";
open OUT5,">$file_out5";


print OUT1 "track name=Hits_lt30_controlA_chr1_4 description=\"Intron2CDS lt30 controlA chr1_4 Hit regions\" color=0,0,255,";
print OUT2 "track name=Hits_lt30_controlA_chr5_9 description=\"Intron2CDS lt30 controlA chr5_9 Hit regions\" color=0,0,255,";
print OUT3 "track name=Hits_lt30_controlA_chr10_13 description=\"Intron2CDS lt30 controlA chr10_17 Hit regions\" color=0,0,255,";
print OUT4 "track name=Hits_lt30_controlA_chr14_17 description=\"Intron2CDS lt30 controlA chr18_ Hit regions\" color=0,0,255,";
print OUT5 "track name=Hits_lt30_controlA_chr18_ description=\"Intron2CDS lt30 controlA chr18_ Hit regions\" color=0,0,255,";


#track name=Hits_lt30_controlA description="Intron2CDS lt30 controlA Hit regions" color=0,0,255,
#chr10	47219922	47219945	aaahg17_refGene_NM_198943	0	+	47219922	47219945	255,0,0
#chr10	47219676	47219699	bbbhg17_refGene_NM_198943	0	+	47219676	47219699	255,0,0
#chr10	47219922	47219945	aaahg17_refGene_NM_182905	0	+	47219922	47219945	255,0,0
#chr10	47219676	47219699	bbbhg17_refGene_NM_182905	0	+	47219676	47219699	255,0,0
#chr5	60354859	60354881	aaahg17_refGene_NM_024796	0	+	60354859	60354881	255,0,0
#chr5	60354615	60354637	bbbhg17_refGene_NM_024796	0	+	60354615	60354637	255,0,0
#chr5	60354859	60354881	aaahg17_refGene_NM_152486	0	+	60354859	60354881	255,0,0


while (<IN>) {
	chomp;
	if ($_ =~/^chr1\t|^chr2\t|^chr3\t|^chr4\t/) {
		print OUT1 "$_\n";
	}
	elsif ($_ =~/^chr5\t|^chr6\t|^chr7\t|^chr8\t|^chr9\t/) {
		print OUT2 "$_\n";
	}
	elsif ($_ =~/^chr10\t|^chr11\t|^chr12\t|^chr13\t/) {
		print OUT3 "$_\n";
	}
	elsif ($_ =~/^chr14\t|^chr15\t|^chr16\t|^chr17\t/) {
		print OUT4 "$_\n";
	}
	else {
	    print OUT5 "$_\n";
	}

}

