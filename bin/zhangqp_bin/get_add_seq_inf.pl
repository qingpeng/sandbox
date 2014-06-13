#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#
# 将手动调整参数后生成的引物文件转换成方便插入excel表的格式
# if not joint sequence ,just left_seq_length=-100;

#

use warnings;
use strict;
if(@ARGV<1){
	printf "Usage:program primer_out_file  left_seq_length\n";
	exit;
}

my %info;
my $out_file_name;
my $length;
($out_file_name,$length) = @ARGV;

	open IN,"$out_file_name" || die"$!";
	while (my $line = <IN>) {
		chomp $line;
		my @fields = split "=",$line;
		$info{$fields[0]} = $fields[1];
	}
	close IN;
		print  "length_n=$length\n";# change the position to left to the position to right
		$info{PRIMER_RIGHT} = &tran_primer_pos($info{PRIMER_RIGHT},$length);
		$info{PRIMER_RIGHT_1} = &tran_primer_pos($info{PRIMER_RIGHT_1},$length);
		$info{PRIMER_RIGHT_2} = &tran_primer_pos($info{PRIMER_RIGHT_2},$length);


	print  "$info{PRIMER_LEFT_SEQUENCE}\t$info{PRIMER_LEFT}\t$info{PRIMER_LEFT_TM}\t$info{PRIMER_LEFT_GC_PERCENT}\t$info{PRIMER_LEFT_PENALTY}\t$info{PRIMER_RIGHT_SEQUENCE}\t$info{PRIMER_RIGHT}\t$info{PRIMER_RIGHT_TM}\t$info{PRIMER_RIGHT_GC_PERCENT}\t$info{PRIMER_RIGHT_PENALTY}\t";
	print  "$info{PRIMER_LEFT_1_SEQUENCE}\t$info{PRIMER_LEFT_1}\t$info{PRIMER_LEFT_1_TM}\t$info{PRIMER_LEFT_1_GC_PERCENT}\t$info{PRIMER_LEFT_1_PENALTY}\t$info{PRIMER_RIGHT_1_SEQUENCE}\t$info{PRIMER_RIGHT_1}\t$info{PRIMER_RIGHT_1_TM}\t$info{PRIMER_RIGHT_1_GC_PERCENT}\t$info{PRIMER_RIGHT_1_PENALTY}\t";
	print  "$info{PRIMER_LEFT_2_SEQUENCE}\t$info{PRIMER_LEFT_2}\t$info{PRIMER_LEFT_2_TM}\t$info{PRIMER_LEFT_2_GC_PERCENT}\t$info{PRIMER_LEFT_2_PENALTY}\t$info{PRIMER_RIGHT_2_SEQUENCE}\t$info{PRIMER_RIGHT_2}\t$info{PRIMER_RIGHT_2_TM}\t$info{PRIMER_RIGHT_2_GC_PERCENT}\t$info{PRIMER_RIGHT_2_PENALTY}\t";
	print  "$info{SEQUENCE}\n";





sub tran_primer_pos {
	my $string;
	my $length;
	($string,$length) = @_;
	print  "$string\t$length\n";
	my @fields = split ",",$string;
	my $pos = $fields[0]-$length-100;
	my $new = $pos.",$fields[1]";
	return $new;
}

