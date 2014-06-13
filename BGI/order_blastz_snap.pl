#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理blastz-snap 便于确定scaffold排列顺序
#

if (@ARGV<1) {
	print  "programm file_in \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
$file_out = $file_in.".tmp";
open OUT,">$file_out" || die"$!";


#	Scaffold000001	19620	8_144845317_145078132	232816	1	143	78711	78864	5313	0
#	Scaffold000001	19620	8_144845317_145078132	232816	193	1471	79291	80699	49055	0

while (my $line = <IN>) {
	chomp $line;
	@s = split /\t/,$line;
	$id = $s[0];
	$length = $s[1];
	$start  = $s[6];
	$end = $s[7];
	$mark = "+";
	
	if ($s[6]>$s[7]) {
		$start = $s[7];
		$end = $s[6];
		$mark = "-";
	}
	print OUT "$id\t$length\t$mark\t$start\t$end\n";
}
$file_sort = $file_in.".sort";
`more $file_out|sort -k4,4n >$file_sort`;
`rm $file_out`;

