#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从gbk中提取mrna 全长，以及cds的位置 与 exon 位置信息结合，得到cds在染色体上的坐标
# 2004-9-20 15:23
# 修改 gene_exon.list start以1开始
# 2004-11-18 14:28
# 

if (@ARGV<3) {
	print  "programm cds_pos gene_exon_pos file_out \n";
	exit;
}
($file_cds,$file_exon,$file_out) =@ARGV;

open CDS,"$file_cds" || die"$!";
open EXON,"$file_exon" || die"$!";
open OUT,">$file_out" || die"$!";

# NM_004793	1	3111	34	2913
# NM_006012	1	1044	20	853
# NM_003119	1	3096	22	2409
# NM_139312	1	4036	183	2504
# NM_006796	1	2963	114	2507
# NM_004083	1	927	181	690

while (<CDS>) {
	chomp;
	if ($_ ne "") {
	
	@s = split /\t/,$_;
	if (scalar @s >3 ) {
	
	$start{$s[0]} = $s[3];
	$end{$s[0]} = $s[4];
	$length{$s[0]} = $s[2];

	}

	}
}


# @HSU11076,17,-1
# >HSU11076_0,40116244,40117012
# >HSU11076_1,40117217,40117460
# >HSU11076_2,40117462,40118101
# >HSU11076_3,40118103,40118158
# >HSU11076_4,40118171,40118377
# >HSU11076_5,40118378,40118519
# @NM_004466,13,1
# >NM_004466_0,89748887,89748912
# >NM_004466_1,89748936,89749464

while (<EXON>) {
	chomp;
	if ($_ =~/^@(\S+),(\S+),(.*)/) {
		$gene = $1;
		$chr = "chr".$2;
		$strand = $3;
		print OUT "\n$gene\t$chr";

		if (exists $start{$gene}) { #如果存在cds信息！
		
		if ($strand eq "-1") {
			$start = $length{$gene} - $end{$gene}+1; # 负链的话重新转换坐标
			$end = $length{$gene} - $start{$gene} +1;
		}
		else {
			$start = $start{$gene};
			$end = $end{$gene};
		}

		}

		else {
			$start = 1;
			$end =1;
		}
		$count = 0;

	}
	else {
# >HSU11076_0,40116244,40117012
# >HSU11076_1,40117217,40117460
# >HSU11076_2,40117462,40118101
# >HSU11076_3,40118103,40118158
# >HSU11076_4,40118171,40118377
# >HSU11076_5,40118378,40118519
		@s = split ",",$_; ## start 已经是 1起始的了！！
		#$exon_length = $s[2]-$s[1]+1;
#		print  "start==$start\tend==$end\n";
		for (my $k = $s[1];$k<$s[2]+1;$k++) {
			$count++;
			if ($count == $start) {
				if ($end == 1) { # 没有cds位置信息
					print OUT "\tN/A\tN/A";
				}
				else {
					print OUT "\t$k\t";
				}
			}
			if ($count == $end) {
				unless ($end == 1) {
					print OUT "$k";
				}
			}
		}
	}
}

