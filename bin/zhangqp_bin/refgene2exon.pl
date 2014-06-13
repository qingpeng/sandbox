#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 注意start end 的坐标以什么为起点！！
# 半开框坐标法
#　2004-11-1 15:39　updated
#  refGene.txt 转移成 各个 exon 信息格式
# 直接转换，仍为refGene.txt 半开框坐标法 表示 
# 2004-11-24 11:32
# 
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# INPUT:
# 
# NM_002574	chr1	-	45645800	45656702	45646093	45653808	6	45645800,45649271,45649637,45650418,45653702,45656373,	45646179,45649402,45649760,45650572,45653819,45656702,
# NM_139312	chr10	-	27439390	27483327	27440911	27483145	20	27439390,27443455,27444994,27445153,27446510,27448228,27449369,27450320,27451775,27452481,27455630,27460793,27462973,27463765,27465210,27471321,27474362,27476432,27477840,27483112,	27441055,27443542,27445068,27445280,27446662,27448384,27449482,27450383,27451908,27452634,27455721,27460876,27463057,27463916,27465320,27471420,27474525,27476603,27477975,27483327,
# NM_006793	chr10	-	120917204	120928335	120917981	120928292	7	120917204,120918678,120921883,120923238,120923952,120926522,120928256,	120918035,120918844,120921987,120923374,120924094,120926655,120928335,

# OUT:




# ===============
# LOCUS:NM_002574
# ===============
# 
# 5' 1K	-	chr1	45656702	45657702
# exon_1	-	chr1	45656373	45656702	
# intron_1	-	chr1	45653819	45656373	
# exon_2	-	chr1	45653702	45653819	start-codon:45653808
# intron_2	-	chr1	45650572	45653702	
# exon_3	-	chr1	45650418	45650572	
# intron_3	-	chr1	45649760	45650418	
# exon_4	-	chr1	45649637	45649760	
# intron_4	-	chr1	45649402	45649637	
# exon_5	-	chr1	45649271	45649402	
# intron_5	-	chr1	45646179	45649271	
# exon_6	-	chr1	45645800	45646179	stop-codon:45646093
# 3' 1K	-	chr1	45644800	45645800

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
#	$gene = $s[0];
	$locus = $s[0];
	print OUT "\n\n\n===============\nLOCUS:$locus\n===============\n\n";
	$chr = $s[1];
	$direction = $s[2];
	$start = $s[8];
	$end = $s[9];
	@s_start = split /,/,$start;
	@s_end = split /,/,$end;
	$exon_num = $s[7];
	if ($direction eq "+") {
		$start_codon = $s[5];
		$stop_codon = $s[6];
		$pre_end = $s_start[0];
		$pre_start = $pre_end-1000;
		$title = "5' 1K";
		print OUT "$title\t$direction\t$chr\t$pre_start\t$pre_end\n";
		for ($k = 0;$k<$exon_num-1;$k++) {
			$exon_start = $s_start[$k];
			$exon_end = $s_end[$k];
			$intron_start = $s_end[$k];
			$intron_end = $s_start[$k+1];
			$codon = "";
			if ($exon_start<=$start_codon && $exon_end>$start_codon) {# 一个是0开始,一个是1开始
				$codon = "start-codon:$start_codon";
			}
			if ($exon_start<$stop_codon && $exon_end>=$stop_codon) {
				if ($codon eq "start-codon:$start_codon") {
					$codon = "start-codon:$start_codon   stop-codon:$stop_codon";
				}
				else {
					$codon ="stop-codon:$stop_codon";
				}
			}
			$exon_count = $k+1;
			$title = "exon"."_$exon_count";
			print OUT "$title\t$direction\t$chr\t$exon_start\t$exon_end\t$codon\n";
			$title = "intron"."_$exon_count";
			$codon = "";
			print OUT "$title\t$direction\t$chr\t$intron_start\t$intron_end\t$codon\n";

		}
		$exon_start = $s_start[$exon_num-1];
		$exon_end = $s_end[$exon_num-1];
		if ($exon_start<=$start_codon && $exon_end>$start_codon) {
				$codon = "start-codon:$start_codon";
		}
		if ($exon_start<$stop_codon && $exon_end>=$stop_codon) {
				if ($codon eq "start-codon:$start_codon") {
					$codon = "start-codon:$start_codon   stop-codon:$stop_codon";
				}
				else {
					$codon ="stop-codon:$stop_codon";
				}
		}
		$exon_count = $exon_num;
		$title = "exon"."_$exon_count";
		print OUT "$title\t$direction\t$chr\t$exon_start\t$exon_end\t$codon\n";
		$after_start = $exon_end;
		$after_end = $after_start+1000;
		$title = "3' 1K";
		print OUT "$title\t$direction\t$chr\t$after_start\t$after_end\n";
	}
	else {
		$start_codon = $s[6];
		$stop_codon = $s[5];
		$pre_start = $s_end[$exon_num-1];
		$pre_end = $pre_start+1000;
		$title = "5' 1K";
		print OUT "$title\t$direction\t$chr\t$pre_start\t$pre_end\n";
		$exon_count=0;
		for ($k = $exon_num-1;$k>0;$k--) {
			$exon_start = $s_start[$k];
			$exon_end = $s_end[$k];
			$intron_start = $s_end[$k-1];
			$intron_end = $s_start[$k];
			$codon = "";
			if ($exon_start<$start_codon && $exon_end>=$start_codon) {# start_codon 为 1起点算得
				$codon = "start-codon:$start_codon";
			}
			if ($exon_start<=$stop_codon && $exon_end>$stop_codon) {
				if ($codon eq "start-codon:$start_codon") {
					$codon = "start-codon:$start_codon   stop-codon:$stop_codon";
				}
				else {
					$codon ="stop-codon:$stop_codon";
				}
			}
			$exon_count ++;
			$title = "exon"."_$exon_count";
			print OUT "$title\t$direction\t$chr\t$exon_start\t$exon_end\t$codon\n";
			$title = "intron"."_$exon_count";
			$codon = "";
			print OUT "$title\t$direction\t$chr\t$intron_start\t$intron_end\t$codon\n";

		}
		$exon_start = $s_start[0];
		$exon_end = $s_end[0];
		if ($exon_start<$start_codon && $exon_end>=$start_codon) {
				$codon = "start-codon:$start_codon";
		}
		if ($exon_start<=$stop_codon && $exon_end>$stop_codon) {
				if ($codon eq "start-codon:$start_codon") {
					$codon = "start-codon:$start_codon   stop-codon:$stop_codon";
				}
				else {
					$codon ="stop-codon:$stop_codon";
				}
		}
		$exon_count++;
		$title = "exon"."_$exon_count";
		print OUT "$title\t$direction\t$chr\t$exon_start\t$exon_end\t$codon\n";
		$after_end = $exon_start;
		$after_start = $after_end-1000;
		$title = "3' 1K";
		print OUT "$title\t$direction\t$chr\t$after_start\t$after_end\n";
		
	}
	

}


