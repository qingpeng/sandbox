#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理eblastn结果！
# 2004-8-27 16:32
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# chr10_135037215_102000000[0]	dpcxb0_182802.z1.scf[1]	94.52[2]	310[3]	14[4]	1[5]	140083[6]	140392[7]	237[8]	543[9]	3e-122[10]	450.5[11]
# chr10_135037215_102000000	dpaxb0_175213.z1.scf	91.54	319	24	3	515606	515923	582	266	4.5e-93	353.4


# NM_002023       69      8       24      7195065 7195081 10000000        34.2    7.9     17/17   100     chr4_191731959_129350000
# NM_002023       69      25      45      1683428 1683408 10000000        34.2    7.9     20/21   95      chr3_199344050_179100000
# NM_002023       69      35      51      215364  215380  10000000        34.2    7.9     17/17   100     chr3_199344050_169150000


# Attention!!
#  chrM
#  chrM
#  chrM
#  chrM
#  chrM
#  chrM
#  chrM
#  chr7_random
#  chr7_random
#  chr7_random
#  chr7_random
#  chr7_random
#  chr3_random


while (my $line = <IN>) {
	chomp $line;
	@s = split /\t/,$line;
	$human_id = $s[11];
	$human_start = $s[4];
	$human_end = $s[5];
	if ($human_id =~/(chr\S+)_\d+_(\d+)/) {
		$pos = $2;
		$chr = $1;
		#print  "$pos\t$chr\n";
		$new_human_start  = $human_start+$pos;
		$new_human_end = $human_end + $pos;
	#	print OUT "$chr\t$s[1]\t$s[2]\t$s[3]\t$s[4]\t$s[5]\t$new_human_start\t$new_human_end\t$s[8]\t$s[9]\t$s[10]\t$s[11]\n";
		print OUT "$s[0]\t$s[1]\t$s[2]\t$s[3]\t$new_human_start\t$new_human_end\tchr_length\t$s[7]\t$s[8]\t$s[9]\t$s[10]\t$chr\n";
	}
	else {
		print  "WWW\t$human_id\n";
		print OUT "$line\n";
	}
}