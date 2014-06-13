#!/usr/bin/perl
# 
# Copyright (c) BGI 2003
# Author:         Liudy <liudy@genomics.org.cn>
# Program Date:   2003.12.22
# Modifier:       Liudy <liudy@genomics.org.cn>
# Last Modified:  2003.12.22
# Version:        1.0


#use strict;
use Getopt::Long;
#use Data::Dumper;

###############
my %opts;

GetOptions(\%opts,"i=s","od=s","f1","f2","f3","f4","N=s","L=s","h" );

#&help()if(defined $opts{h});
if(!defined($opts{i}) || !defined($opts{od}) || !defined($opts{N}) || defined($opts{h}) || (!defined($opts{f1}) && !defined($opts{f2}) && !defined($opts{f3}) && !defined($opts{f4})) || ((defined($opts{f3}) || defined($opts{f4})) && !defined($opts{L}))){
	my $ver="1.0";
	print <<"	Usage End.";
	Description:

		Divide fasta files.You must at least define ONE function .
		Version: $ver

	Usage:

		-i    *.seq        Must be given

		-od   outdir       Must be given

		-f1   Function 1   Divide M seqs into many files , each contains N seqs . [-N needed]

		-f2   Function 2   Divide M seqs into N files , each contains [M/N] seqs . [-N needed]

		-f3   Function 3   Divide 1(or more) seqs into many seqs , each contains N bytes with L overlap . [-N,-L needed]

		-f4   Function 4   Divide 1(or more) seqs into N seqs , each contains [M/N] bytes and L overlap . [-N,-L needed]

		-h    Help document

	Usage End.

	exit;
}

my $in=$opts{i};
my $out_dir=$opts{od};
$out_dir=~s/\/$//;

################
################
$/=">";
if (defined $opts{f1}) {
	open (IN,"$in")||die"Can't open $in\n";
	$seq_num=$opts{N};
	$count=0;
	$file=1;
	open (OUT,">$out_dir/$in.f1.$file.seq");
	while (<IN>) {
		chomp;
		if ($_ ne "") {
			print OUT ">$_";
			$count++;
			if ($count == $seq_num) {
				$count=0;
				$file ++;
				close OUT;
				open (OUT,">$out_dir/$in.f1.$file.seq");
			}
		}
	}
	close OUT ;
	if ($count==0) {
		system ("rm -rf $out_dir/$in.f1.$file.seq")
	}
	close IN;
}

if (defined $opts{f2}) {
	open (IN,"$in")||die"Can't open $in\n";
	$file_num=$opts{N};
	$get_scr=`grep ">" $in |wc`;
	$in_seq_num=(split(/\s+/,$get_scr))[1];
	if ($in_seq_num < $file_num) {
		die "There are only $in_seq_num sequences in $in .\n";
	}
	if ($file_num <1 || $file_num != int($file_num)) {
		die "You must input an INTEGER .\n";
	}
	$seq_num=$in_seq_num/$file_num;
	$seq_num=int($seq_num);
	$add=$in_seq_num % $file_num;
	$count=0;
	$file=1;
	open (OUT,">$out_dir/$in.f2.$file.seq");
	while (<IN>) {
		chomp;
		if ($_ ne "") {
			print OUT ">$_";
			$count++;
			if ($file<=$add) {
				$limit=$seq_num+1;
			}
			else {
				$limit=$seq_num;
			}
			if ($count == $limit) {
				$count=0;
				$file ++;
				close OUT;
				open (OUT,">$out_dir/$in.f2.$file.seq");
			}
		}
	}
	close OUT ;
	if ($count==0) {
		system ("rm -rf $out_dir/$in.f2.$file.seq")
	}
	close IN;
}

if (defined $opts{f3}) {
	open (IN,"$in")||die"Can't open $in\n";
	$size=$opts{N};
	$overlap=$opts{L};
	$cut=$size-$overlap;
	open (OUT,">$out_dir/$in.f3.seq");
	while (<IN>) {
		chomp;
		if ($_ ne "") {
			$name=(split(/\s+/,$_))[0];
			$seq=(split(/\n/,$_,2))[1];
			$seq=~s/\s+//g;
			$count=0;
			while (length($seq) > $size) {
				$start=$count*$cut+1;
				$end=$start+$size-1;
				print OUT ">$name\_$start-$end   Length:$size\n";
				$head=substr($seq,0,$size);
				$seq=substr($seq,$cut,length($seq)-$cut);
				$head=~s/(.{50})/$1\n/g;
				$head=~s/\n$//;
				print OUT "$head\n";
				$count++;
			}
			$end_size=length($seq);
			$start=$count*$cut+1;
			$end=$start+$size-1;
			print OUT ">$name\_$start-$end   Length:$end_size\n";
			$seq=~s/(.{50})/$1\n/g;
			$seq=~s/\n$//;
			print OUT "$seq\n";
		}
	}
	close OUT ;
	close IN;
}

if (defined $opts{f4}) {
	open (IN,"$in")||die"Can't open $in\n";
	$div_num=$opts{N};
	$overlap=$opts{L};
	open (OUT,">$out_dir/$in.f4.seq");
	while (<IN>) {
		chomp;
		if ($_ ne "") {
			$name=(split(/\s+/,$_))[0];
			$seq=(split(/\n/,$_,2))[1];
			$seq=~s/\s+//g;
			$size=length($seq)/$div_num;
			if ($size != int($size)) {
				$size=int($size)+1;
			}
			$add=length($seq) % $div_num;
			$count=0;
			while (length($seq) > $size) {
				$start=$count*$size+1;
				$end=$start+$size+$overlap-1;
				$seq_lth=$size+$overlap;
				print OUT ">$name\_$start-$end   Length:$seq_lth\n";
				$head=substr($seq,0,$size+$overlap);
				$seq=substr($seq,$size,length($seq)-$size);
				$head=~s/(.{50})/$1\n/g;
				$head=~s/\n$//;
				print OUT "$head\n";
				$count++;
			}
			$end_size=length($seq);
			$start=$count*$size+1;
			$end=$start+$size+$overlap-1;
			print OUT ">$name\_$start-$end   Length:$end_size\n";
			$seq=~s/(.{50})/$1\n/g;
			$seq=~s/\n$//;
			print OUT "$seq\n";
		}
	}
	close OUT ;
	close IN;
}
