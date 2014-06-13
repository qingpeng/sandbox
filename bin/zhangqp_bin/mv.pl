#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#bsab	chr20	9125790	9241205	-                 
#chr3	12173310	12290136	+
#bsab	chr6	115642516	115735188	+
#bsal	582	49767	+

while (<IN>) {
	chomp;
	@s=split /\t+/,$_;
	$ch=$s[0];
	$start=$s[1];
	$end=$s[2];
	$s[3]=~s/\s+//g;
	$direction=$s[3];

	print $direction;
	$bac=$s[0];
	print OUT "mv $ch\_$start\_$end\_$direction.fa $bac\n";
}