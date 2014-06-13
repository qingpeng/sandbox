#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理blastz-snap 便于确定scaffold排列顺序
#
# 添加信息，坐标信息，并算长度
# 2004-5-28 14:26
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
	$sub_length = $end-$start+1;
	$query_length = $s[5]-$s[4]+1;
	$mark = "+";
	
	if ($s[6]>$s[7]) {
		$start = $s[7];
		$end = $s[6];
		$mark = "-";
		$sub_length = $end-$start+1;
	}
	print OUT "$id\t$length\t$mark\t$s[4]\t$s[5]\t$query_length\t$start\t$end\t$sub_length\n";
}
$file_sort = $file_in.".sort_full";
`more $file_out|sort -k7,7n >$file_sort`;
`rm $file_out`;

