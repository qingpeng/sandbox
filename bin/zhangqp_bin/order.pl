#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
#
#ENSP00000215832_bsah
#ENSP00000225430_bsbm
#ENSP00000233557_bsah
#ENSP00000237305_bsbq1
#ENSP00000249750_bsac
#ENSP00000253546_bsba

while (<IN>) {
	chomp;
	@s= split "_",$_;
	$name=$s[0];
	$bac=$s[1];
	print OUT "perl ../bin/project_genewise.pl genewise $_ ../bac/$bac.bac\n"
}