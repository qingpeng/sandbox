#!/usr/bin/perl

#if (@ARGV<2) {
#	print  "programm file_in file_out \n";
#	exit;
#}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";
#open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
    if (/^s/) {
		@s=split /\s+/,$_;
		print "$s[2]\n";
		print "{{{{{{{{{";
	}
}