#!/usr/bin/perl -w
use strict;
# get the negative control position
# left 100 bp and right 100bp distance
# 2006-08-11
#

if (@ARGV < 5) {
	print "perl *.pl human_refseq_intron.pos  all.negative.ge50  intron.length control_in_same_intron  control_in_other_intron \n";
	exit;
}
my ($file_intron,$file_in,$file_length,$file_out,$file_out1) = @ARGV;

open INTRON,"$file_intron";
open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";
open OUT1,">$file_out1";
open LENGTH,">$file_length";

# all.negative.ge50
# hg17_refGene_NM_194315  hg17_refGene_NM_033493_5        340     372     26297   26265   33
# hg17_refGene_NM_194315  hg17_refGene_NM_033492_5        340     372     26297   26265   33
# hg17_refGene_NM_194315  hg17_refGene_NM_033490_4        340     372     30367   30335   33



# intron.pos
# hg17_refGene_NM_015658_6        chr1    -       929416  929526
# hg17_refGene_NM_015658_7        chr1    -       928812  929304
# hg17_refGene_NM_015658_8        chr1    -       928124  928697

my %length;

while (<INTRON>) {
	chomp;
	my @s = split /\t/,$_;
	$length{$s[0]} = $s[4]-$s[3]+1;
	print LENGTH "$s[0]\t$length{$s[0]}\n";	
}

my $left_side_a;
my $left_side_b;
my $right_side_a;
my $right_side_b;

my $left_number;
my $right_number;
my $left_intron;
my $right_intron;
my $left_start;
my $left_end;
my $right_start;
my $right_end;


while (<IN>) {
	chomp;
	my @s = split /\t/,$_;

	
	#same intron left/right 100bp distance
	$left_side_a = $s[4]+101+$s[4]-$s[5];
	if ($left_side_a<=$length{$s[1]}) {
		$left_side_b = $s[4]+101;
		print OUT "aaa$s[0]\t$s[1]\t$s[2]\t$s[3]\t$left_side_a\t$left_side_b\t$s[6]\n";
	}
	$right_side_b = $s[5]-101-($s[4]-$s[5]);
	if ($right_side_b>=0) {
		$right_side_a = $s[5]-101;
		print OUT "bbb$s[0]\t$s[1]\t$s[2]\t$s[3]\t$right_side_a\t$right_side_b\t$s[6]\n";
	}

	# left intron and right intron
	if ($s[1] =~/(hg17_refGene_NM_\d+)_(\d+)/) {
		$left_number = $2-1;
		$right_number = $2+1;
		$left_intron = $1."_".$left_number;
		$right_intron = $1."_".$right_number;
		if (exists $length{$left_intron}) {
			$left_start = int($length{$left_intron}/2);
			$left_end = $left_start-$s[6]+1;
			if ($left_end>0) {
				print OUT1 "$s[0]\t$left_intron\t$s[2]\t$s[3]\t$left_start\t$left_end\t$s[6]\n";
			}
		}
		if (exists $length{$right_intron}) {
			$right_start = int($length{$right_intron}/2);
			$right_end = $right_start-$s[6]+1;
			if ($right_end>0) {
				print OUT1 "$s[0]\t$right_intron\t$s[2]\t$s[3]\t$right_start\t$right_end\t$s[6]\n";
			}
		}
	}	
		
}

	
	

