#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理blastz-snap 便于确定scaffold排列顺序
#
# 添加信息，坐标信息，并算长度
# 2004-5-28 14:26

# 便于手动 坐标记 ！ 1.只比上一次 比上部分>scaffold length/2"+" 2.连续比到了多处"++"  3.非连续比到了多处"+++" 4.单独的且identity 未达到标准"0"
# V3
# 2004-5-31 10:05
if (@ARGV<1) {
	print  "programm file_in \n";
	exit;
}
($file_in) =@ARGV;

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
$file_sort = $file_in.".tmp2";
`more $file_out|sort -k7,7n >$file_sort`;
`rm $file_out`;

open SORT,"$file_sort" || die"$!";


# 
# Scaffold000009	1465	+	1	530	530	44703	45013	311
# Scaffold000009	1465	+	1174	1465	292	45072	45407	336
# Scaffold000052	535	-	284	534	251	48087	48335	249
# Scaffold000052	535	-	1	245	245	48744	49007	264
# Scaffold000027	993	-	1	993	993	49033	50168	1136
# Scaffold000006	1615	-	136	1615	1480	50912	52359	1448
# Scaffold000019	1272	-	1033	1270	238	54228	54477	250
# Scaffold000043	679	+	399	678	280	55383	55672	290

@lines = <SORT>;
chomp @lines;
for (my $k = 0;$k<scalar @lines;$k++) {
	$line = $lines[$k];
	@s = split /\t/,$line;
	$scaffold[$k] = $s[0];
	$identity[$k] = $s[5]/$s[1];
}

for (my $k = 0;$k<scalar @lines;$k++) {
	if (exists $count{$scaffold[$k]}) {
		if ($scaffold[$k] ne $scaffold[$k-1]){# 不连续
			$mark{$scaffold[$k]} = "+++";
		}
		else {# 连续
			unless (exists $mark{$scaffold[$k]} && $mark{$scaffold[$k]} eq "+++") {# 并且优先考虑不连续
				$mark{$scaffold[$k]} = "++";
			}
		}
	}
	else {
		$count{$scaffold[$k]} = 5; # 标记 出现了
	}
}

$file_last = $file_in.".sort";
open LAST,">$file_last" || die"$!";
 ;

for (my $k = 0;$k<scalar @lines;$k++) {
	print  "$scaffold[$k]\n";
	if (exists $mark{$scaffold[$k]}) {
		print LAST "$mark{$scaffold[$k]}\t$lines[$k]\n";
	}
	else {
		if ($identity[$k]>0.5) {
			print LAST "+\t$lines[$k]\n";
		}
		else {
			print LAST "0\t$lines[$k]\n";
		}
	}
}

`rm $file_sort`;
