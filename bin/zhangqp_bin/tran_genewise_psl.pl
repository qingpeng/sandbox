#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# tran genewise to psl format
# 注意不同的参数跑出来的genewise格式有所不同
# 2005-3-26 16:57
# 2005-3-26 19:05
# 
if (@ARGV<3) {
	print  "programm file_in file_log file_out \n";
	exit;
}
($file_in,$file_log,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open LOG,">$file_log" || die"$!";
open OUT,">$file_out" || die"$!";



while (<IN>) {
	chomp;
#	Query protein:       AK064944
	if ($_ =~/Query protein:\s+(\w+)/) {
		$query = $1;
		$exon_mark = "N";
	}
#	Target Sequence      Chr05_21196603_21202080
	elsif ($_ =~/Target Sequence\s+(\w+)/) {
		$subject = $1;
#		@s_subject = split /_/,$subject;
#		$chr = $s_subject[0];
#		$chr_start = $s_subject[1];
	}
	elsif ($_ =~/Gene \d+ \d+/) {
		if ($_ =~/pseudogene/) {
			$pse_mark = "pseudogene";
		}
		else {
			$pse_mark = "not_pseudogene";
		}
	}
# Gene 101 1547 [pseudogene]
#   Exon 101 1547 phase 0
# //
# Gene 1
# Gene 5378 101
#   Exon 5378 5256 phase 0
#      Supporting 5378 5256 1 41
#   Exon 5162 4857 phase 0
#      Supporting 5162 4857 42 143
#   Exon 4742 4592 phase 0
#      Supporting 4742 4593 144 193
#   Exon 4500 4229 phase 1
#      Supporting 4498 4229 195 284
#   Exon 1846 1573 phase 0
#      Supporting 1846 1574 285 375
#   Exon 1450 1143 phase 1
#      Supporting 1448 1143 377 478
#   Exon 1050 769 phase 0
#      Supporting 1050 769 479 572
#   Exon 667 383 phase 0
#      Supporting 667 383 573 667
#   Exon 259 101 phase 0
#      Supporting 259 101 668 720
# //

	elsif ($_ =~/Exon (\d+) (\d+) phase/) {
		$a = $1;
		$b = $2;
		if ($a>$b) {
			push @exon_start,$b;
			push @exon_end,$a;
			$strand = "-";
		}
		else {
			push @exon_start,$a;
			push @exon_end,$b;
			$strand = "+";
		}
		$exon_mark = "Y";
		$exon_length = "";
		$exon_start = "";
	}
# 9999	0	0	0	0	0	0	0	-[8]	NM_032348[9]	2272[10]	9999	9999	chr1[13]	9999	1194129[15]	1199973[16]	10[17]	938,81,77,40,156,471,102,303,24,80,[18]	9999,9999	1194129,1195285,1195467,1195630,1195791,1196119,1196681,1196887,1198118,1199893,[20]

	elsif ($_ =~/\/\// && $exon_mark eq "Y") {
		@sort_start = sort {$a <=> $b} @exon_start;
		@sort_end = sort {$a <=> $b} @exon_end;
		$subject_start = $sort_start[0]-1;
		$subject_end = $sort_end[-1];
		for (my $k = 0;$k<scalar @sort_start;$k++) {
			print  "sort_end=$sort_end[$k]\tsort_start=$sort_start[$k]\n";
			$length = $sort_end[$k]-$sort_start[$k]+1;
			$all_length = $all_length+$length;
			# print  "chr_start==$chr_start\n";
			$start = $sort_start[$k]-1;

			$exon_length = $exon_length.$length.",";
			$exon_start = $exon_start.$start.",";
		}
		$num = scalar @sort_start;
		$count++;
		$query_name = $query."_".$count;
		print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$strand\t$query_name\t$all_length\t11\t12\t$subject\t14\t$subject_start\t$subject_end\t$num\t$exon_length\tquery_start\t$exon_start\n";
		print LOG "$query_name\t$strand\t$subject\t$exon_length\t$exon_start\t$pse_mark\n";
		$exon_mark = "N";
		@exon_start =();
		@exon_end = ();
		$exon_length = "";
		$exon_start = "";
		$exon_mark = "N";
		$all_length = 0;
	}


}