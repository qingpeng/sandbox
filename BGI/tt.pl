#!/usr/bin/perl 
#programmer:zhouqi
#����Ѱ����N������bac�ϵ�����ͬԴ������
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