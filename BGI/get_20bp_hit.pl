#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 提取连续比上20bp以上的hit
# 2004-8-27 19:14
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

$m = 0;
while (<IN>) {
	chomp;
# Query= NM_003166
	if ($_ =~/^Query= (\S+)/) {
		$query = $1;
	}
# >chr16_90041932_29850000
	if ($_ =~/^>(\S+)/) {
		$subject = $1;
	}
	if ($_ =~/\|{21}/) {
		$m = 1;
		#print OUT "$_\n";
	}
# Sbjct: 9613820 caggaggttgtggatacagtgagttatgacatgcccattcactacagcctggatgacaag 9613879
	if ($_ =~/^Sbjct: (\d+) \w+ (\d+)/ && $m == 1) {
		$start = $1;
		$end = $2;
		$m = 0;
		#print OUT "$_\n";
# NM_000015	69	1	69	18268610[4]	18268678[5]	chr_length	 137	7e-31	69/69	100	chr8
# NM_000015	69	7	68	18239223	18239284	chr_length	52.0	3e-05	53/62	85	chr8

		
		print OUT "$query\t2\t3\t4\t$start\t$end\t7\t8\t9\t10\t11\t$subject\n";
	}
}

