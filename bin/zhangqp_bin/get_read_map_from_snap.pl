#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#
# 对每一read取得分最高的片断
# 确实有些query 没有比出来
#
#Q	bsbf0_000436_z1_scf	530
#R	0
#S	bsbf0_000436_z1_scf_6_151980225_152980225	1000001
#A	18	530	+	499657	500189	1	22646	18,530;	499657,500189;	+22646;
#Q	bsbf0_000449_z1_scf	587
#R	0
#S	bsbf0_000449_z1_scf_6_152037611_153037611	1000001
#A	1	584	+	499762	500124	2	16164	1,153;366,584;	499762,499910;499914,500124;	+6606;+9558;
#Q	bsbf0_000452_z1_scf	576
#R	0
#S	bsbf0_000452_z1_scf_6_151977885_152977885	1000001
#A	51	565	+	499934	500571	1	18894	51,565;	499934,500571;	+18894;



if (@ARGV<2) {
	print  "programm snap_file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
my %max_score;
while (my $line = <IN>) {
	chomp $line;
	if ($line =~/^Q\t(\S+)\t/) {
		$query = $1;
#		print  "QUERY==$query\n";
	}
	elsif ($line =~/^S\t(\S+)\t/) {
		$sub = $1;
#		print  "sub==$sub\n";
	}
	else {
		if ($line =~/^A/) {
			@s = split /\t/,$line;
			$mark = $s[3];
#			print  "mark==$mark\n";
			@split_query_pos = split ";",$s[8];
#			$num = scalar @split_query_pos;
#			print  "______$s[8]_______$num\n";
			@split_sbjct_pos = split ";",$s[9];
			@split_score_pos = split ";",$s[10];
			for (my $k = 0;$k<scalar @split_query_pos;$k++) {
				if ($mark eq "+") {
					if ($split_score_pos[$k] =~/\+(\d+)/) {
						$score = $1;
					}
				}
				else {
					if ($split_score_pos[$k] =~/\-(\d+)/) {
						$score = $1;
					}
				}
				if (exists $max_score{$query}) {
#					print  "00000000000==========$query\n";
				
				if ($score>$max_score{$query}) {
#					print  "111111111111====$query\n";
					$max_score{$query} = $score;
					$max_mark{$query} = $mark;
					$max_sub{$query} = $sub;
					$max_query_pos{$query} = $split_query_pos[$k];
					$max_sbjct_pos{$query} = $split_sbjct_pos[$k];
				}
				}
				else {
#					print  "22222222222=======$query\n";
					$max_score{$query} = $score;
					$max_mark{$query} = $mark;
					$max_sub{$query} = $sub;
					$max_query_pos{$query} = $split_query_pos[$k];
					$max_sbjct_pos{$query} = $split_sbjct_pos[$k];
					
				}
			}
		}
	}
}
print OUT "query\tchr\tdirection\tscore\tquery_start\tquery_end\tsub_start\tsub_end\n";
#print  %max_score;
foreach my $key (keys %max_score) {
	@query_pos = split ",",$max_query_pos{$key};
	@sbjct_pos = split ",",$max_sbjct_pos{$key};
	@sbjct_name = split "_",$max_sub{$key};
	$mark = $max_mark{$key};
	$start_sbjct = $sbjct_name[-2];
	$end_sbjct = $sbjct_name[-1];
	$chr = $sbjct_name[-3];
	if ($mark eq "-") {
		$real_start_sbjct = $end_sbjct-$sbjct_pos[1]+1;
		$real_end_sbjct = $end_sbjct-$sbjct_pos[0]+1;
	}
	else {
		$real_start_sbjct = $start_sbjct+$sbjct_pos[0]-1;
		$real_end_sbjct = $start_sbjct+$sbjct_pos[1]-1;
	}
	print OUT "$key\t$chr\t$mark\t$max_score{$key}\t$query_pos[0]\t$query_pos[1]\t$real_start_sbjct\t$real_end_sbjct\n";

}
