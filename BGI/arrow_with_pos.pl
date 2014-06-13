#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理svg入口文件中说明带有位置信息的情况
#  input
# 1030:1394:+::Scaffold000001_26707_26973
# 2670:2841:+::Scaffold000001_26983_27152

# output 
# 1030:1394:+::Scaffold000001_26707_26973
# 2670:2841:+1::Scaffold000001_26983_27152
# 

# 思路：把位置信息线分离出来，运行arrow_v2.pl 然后再加上位置信息
#　

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

$file_tmp = $file_in.".tmp";
open TMP,">$file_tmp" || die"$!";

# 1030:1394:+::Scaffold000001_26707_26973
# 2670:2841:+::Scaffold000001_26983_27152
# 5438:5872:+::rbsab0_000780.y1.scf_4_444


while (<IN>) {
	chomp;
	if ($_ =~/(.*)_(\d+_\d+)/) {
		$head = $1;
		$end = $2;
	}
	@s = split /:/,$head;
	$id = $s[0].":".$s[1].":".$s[4];

	$end{$id} = $end;
	print TMP "$head\n";

}

$file_arrow = $file_tmp.".arrow";
`perl ~/bin/arrow_v2.pl $file_tmp $file_arrow`;

open ARR,"$file_arrow" || die"$!";

# 1030:1394:+1::Scaffold000001
# 2670:2841:+1::Scaffold000001

while (<ARR>) {
	chomp;
	if ($_=~/\d/) {
	@s = split /:/,$_;
	$id = $s[0].":".$s[1].":".$s[4];
	$new_line = $_."_$end{$id}";
	print OUT "$new_line\n";
	}
}

`rm $file_tmp`;
`rm $file_arrow`;
