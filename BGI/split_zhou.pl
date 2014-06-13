#!/usr/bin/perl

open IN,"$file_in" || die"$!";
open OUT,">$in[0].fa" || die"$!";
$seq="";
$name="";
$/=">";
while (<IN>) {
		chomp;
		if ($_ ne '') {
			my @in=split(/\n/,$_,2);
			$in[0]=~s/\s+\S+//g;
			$in[0]=~s/\s+|\n//g;
			$in[1]=~s/\s+|\n//g;
			$in[1]=~s/ //g;
			$in[1]=uc($in[1]);
			$hash_seq{$in[0]}=$in[1];#get chromosome sequence;
			print OUT ">$_";
			print OUT 
	}

}