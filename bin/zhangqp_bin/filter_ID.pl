#!/usr/bin/perl
#������genewise ID list���޳���est��fgenesh֧�ֵ�ID

if (@ARGV<2) {
	print  "programm file_in file_list file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die "$!";
open OUT,">$file_out" || die"$!";
while (<IN>) {
	chomp;
	if ($_ ne "") {
		$hash{$_}=1;
	}
	
	

}

while (<LIST>) {
	chomp;
	if ($_ ne "") {
		if (!exists $hash{$_}) {
		print OUT $_,"\n";
		}
	}
}
	