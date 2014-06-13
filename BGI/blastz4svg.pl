#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理blastz snap结果 转换成for svg 格式 两个方向，选比得长的方向
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;
print  "$file_in\n";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000001	34872	4612	5654	385	1411	35079	0
#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000001	34872	6568	6844	1399	1678	10600	0
#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000001	34872	7152	7454	1665	1978	9418	0
#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000001	34872	7503	7815	32076	31712	6432	0
#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000002	33998	4848	5613	3	717	18443	0
#  bsaa__gi__21542117__sp__Q9HBG7__LY9__HUMAN	25367	Scaffold000002	33998	9678	12241	33995	31754	79075	0

my %length_p;
my %length_r;

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	$scaffold = $s[2];
	$hash{$scaffold} = 1;
	$start = $s[4];
	$end = $s[5];
	if ($s[6]<$s[7]) {
		$sca_start = $s[6];
		$sca_end = $s[7];
		$mark = "+";
		$line = "$start:$end".":$mark"."::$scaffold"."_$sca_start"."_$sca_end";
		push @{$p_lines{$scaffold}},$line;
		$length_p{$scaffold} = $length_p{$scaffold}+$end-$start+1;
#		print  "length_p\t$scaffold==$length_p{$scaffold}\n";
	}
	else {
		$sca_start = $s[7];
		$sca_end = $s[6];
		$mark = "-";
		$line = "$start:$end".":$mark"."::$scaffold"."_$sca_start"."_$sca_end";
		push @{$r_lines{$scaffold}},$line;
		$length_r{$scaffold} = $length_r{$scaffold}+$end-$start+1;
#		print  "length_r\t$scaffold==$length_r{$scaffold}\n";
	}
}

# 比较正反向比上的长度
foreach my $scaffold (sort keys %hash) {
#	print  "$scaffold\t\n";
	if ($length_p{$scaffold} >$length_r{$scaffold}|| !exists $length_r{$scaffold}) {
#		print  "P!\n";
		for (my $k = 0;$k<scalar @{$p_lines{$scaffold}};$k++) {
			print OUT "${$p_lines{$scaffold}}[$k]\n";
		}
	}
	else {
#		print  "R!\n";

		for (my $k = 0;$k<scalar @{$r_lines{$scaffold}};$k++) {
			print OUT "${$r_lines{$scaffold}}[$k]\n";
		}
	}
}






