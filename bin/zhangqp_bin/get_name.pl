#!/usr/bin/perl
#This script is for cut number behind the ID of pep.
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;
#ENSP00000201943_2
#ENSP00000215659_3
#ENSP00000215832_4
#ENSP00000225430_8
#ENSP00000229794_9
#ENSP00000229795_10
#ENSP00000233557_11


open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
while (<IN>) {
	chomp;
	if (/(\w+)\_(\d+)/) {
		$name=$1;
		print OUT $name,"\n";
	}
}