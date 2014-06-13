#!/usr/bin/perl 
#programmer:zhouqi
#用于寻找以N隔开的bac上的与人同源的区域
if (@ARGV<3) {
	print  "programm file_in file_solar file_out \n";
	exit;
}
($file_in,$file_solar,$file_out) =@ARGV;
print ")))";

open IN,"$file_in" || die"$!";
open SOLAR,"$file_solar" || die "$!";
open OUT,">$file_out" || die"$!";
$/=">";
print ")))";