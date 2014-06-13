#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#
# snap -j 可以直接转换格式，代替本程序
# 整理snap结果
# 2004-4-30 11:48
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
#			print  "mark==$mark\n";
			@split_query_pos = split ";",$s[8];
#			$num = scalar @split_query_pos;
#			print  "______$s[8]_______$num\n";
			@split_sbjct_pos = split ";",$s[9];
			@split_score_pos = split ";",$s[10];
			for (my $k = 0;$k<scalar @split_query_pos;$k++) {
			@query_pos = split ",",$split_query_pos[$k];
			@sbjct_pos = split ",",$split_sbjct_pos[$k];
			$score = $split_score_pos[$k];
			print OUT "$query\t$query_pos[0]\t$query_pos[1]\t$sub\t$sbjct_pos[0]\t$sbjct_pos[1]\t$score\n";

			}
		}
	}
}
