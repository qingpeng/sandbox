#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
$file_tmp = $file_in.".for_fig";
open OUT,">$file_tmp" || die"$!";
#Scaffold000001	19620	8_144845317_145078132	232816	1	143	78711-6	78864-7	5313	0
#Scaffold000001	19620	8_144845317_145078132	232816	193	1471	79291	80699	49055	0

# 144907144:144907307:+::NM_139021

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	$start = $s[6];
	$end = $s[7];
	$mark = "+";
	if ($s[6]>$s[7]) {
		$start = $s[7];
		$end = $s[6];
		$mark = "-";
	}
	$title = $s[0]."_".$s[1];
	$line = "$start:$end:".$mark."::".$title."\n";
	print OUT $line;
}

close OUT;

`perl /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/prj_2004-02_Deer/Flow/Final/bin/arrow_v2.pl $file_tmp $file_out`;
`rm $file_tmp`;
