#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# modify the output format!

# v1.0 add excluded region and target!
# update: join the primer position is to the right exon 
# update: filter 5 bps!!!

# 注意　输出文件的位置坐标
# 必须都是从1开始的
# 注意 refscan /genscan /blat start 位置是以0计数，end 位置是以1计数
# ！！！
#for 118!!


# input:
# file name in desert directory	none	type(* is ok)useless	start	end	length
# chr7.fa.a2A	NM_015570	68476435	68477065	631
# chr7.fa.a2A	NM_015570	68776388	68776601	214
# chr7.fa.a2A	NM_015570	68995234	68995336	103
# chr7.fa.a2A	NM_015570	69011638	69011674	37
# chr7.fa.a2A	NM_015570	69312854	69312884	31
# chr7.fa.a2A	NM_015570	69575671	69575723	53
# chr7.fa.a2A	NM_015570	69639972	69640444	473
#


use strict;

if(@ARGV<1){
	printf "Usage:program positionfile outputfile\n";
	exit;
}

#.........................default initialization.....................................
my %config;

$config{PRIMER_OPT_SIZE}=20;
$config{PRIMER_MAX_SIZE}=23;
$config{PRIMER_MIN_SIZE}=18;
$config{PRIMER_OPT_TM}=59;
$config{PRIMER_MAX_TM}=60;
$config{PRIMER_MIN_TM}=58;
$config{PRIMER_PRODUCT_SIZE_RANGE}="50-500";
$config{PRIMER_PRODUCT_OPT_SIZE}=300;
$config{PRIMER_PAIR_WT_PRODUCT_SIZE_LT}=".10";
$config{PRIMER_PAIR_WT_PRODUCT_SIZE_GT}=".30";
$config{PRIMER_MIN_GC}=20;
$config{PRIMER_MAX_GC}=50;
$config{PRIMER_SALT_CONC}=50;
$config{PRIMER_SELF_ANY}=8;
$config{PRIMER_SELF_END}=3;
$config{PRIMER_DNA_CONC}=40;
$config{PRIMER_GC_CLAMP}=0;
$config{PRIMER_MAX_END_STABILITY}=8;
$config{PRIMER_EXPLAIN_FLAG}=1;

my $config_file;
my $output;

($config_file,$output) = (@ARGV);
my @start;
my @end;
my @length;
my @type;

#..........................Get Data/Option ...................................
open IN,"$config_file" || die"Can't open $config_file:$!";
my $k = 0;
my $desert_id;
while (my $line = <IN>) {
	$k++;
	chomp $line;
	my @fields = split /\t/,$line;
	$desert_id = $fields[0];
	$start[$k] = $fields[2];
	$end[$k] = $fields[3];
	$length[$k] = $fields[4];
	$type[$k] = $fields[1];


}
close IN;

print  "k=$k\n";

my $seq_num = $k;
########################## get sequence ###########################
my $N = 'N'x100;
my @seq;
my @add_seq;

for (my $n = 1;$n<$seq_num+1;$n++) {
	$seq[$n] = &extract($desert_id,$start[$n],$end[$n]);
	print  "seq_$n=\n$seq[$n]\n";
}

for (my $n = 1;$n<$seq_num;$n++) {
	$add_seq[$n] = $seq[$n].$N.$seq[$n+1];
	my $nn = $n+1;
	my $nnn = "$n"."-"."$nn";
	print  "seq_$nnn\n$add_seq[$n]\n";
}
my @info;
my @add_info;
my $seq_id;
my $dat_file_name;
my $out_file_name;
my $seq;



########################### get primers for single sequence ###########
for (my $n = 1;$n<$seq_num+1;$n++) {
	$seq_id = "$desert_id-$start[$n]_$end[$n]";
	$seq = $seq[$n];
	$dat_file_name = "seq_$n.dat";
	$config{EXCLUDED_REGION}="";
	if ($length[$n]<100) {
		$config{PRIMER_PRODUCT_SIZE_RANGE}="30-500";
	}
#	if ($length[$n]>=100) {# (if length >100 ,exclude 10 只有长度>100)现在一直屏蔽前5 注意这儿的屏蔽！！
		my $start_r = $length[$n]-5;
		$config{EXCLUDED_REGION}="0,5 $start_r,5";
#	}

	open IN,">$dat_file_name" || die"$!";
	&put_primer_head;
	close IN;
	$config{PRIMER_PRODUCT_SIZE_RANGE}="50-500";

	$out_file_name = "seq_$n.out";
	`primer3_core <$dat_file_name >$out_file_name `;

	open IN,"$out_file_name" || die"$!";
	while (my $line = <IN>) {
		chomp $line;
		my @fields = split "=",$line;
		${$info[$n]}{$fields[0]} = $fields[1];
	}
	close IN;
}

my $start1;
my $start2;
my $start4;

my $length1;
my $length2;
my $excluded;


########################### get primers for joint sequence ################
for (my $n = 1;$n<$seq_num;$n++) {
	$seq_id = "$desert_id-$start[$n]_$end[$n]-$start[$n+1]_$end[$n+1]";
	my $nn = $n+1;
	my $nnn = "$n"."_"."$nn";
	$dat_file_name = "add_seq_$nnn.dat";
	$config{TARGET}="$length[$n],100";
#	if ($length[$n]>310||$length[$n+1]>310) {
#		$excluded = "\nEXCLUDED_REGION=";
#		$config{EXCLUDED_REGION}=$config{TARGET}.$excluded;
	$config{EXCLUDED_REGION}="";
	if ($length[$n]>=310) {
		$length1=$length[$n]-300;
		$excluded = "0,$length1";
		$config{EXCLUDED_REGION}=$config{EXCLUDED_REGION}.$excluded;
	}
	if ($length[$n+1]>=310) {
		$start2 = $length[$n]+100+300;
		$length2 = $length[$n+1]-300;
		$excluded = " $start2,$length2";
		$config{EXCLUDED_REGION}=$config{EXCLUDED_REGION}.$excluded;
	}
#	}

	if ($length[$n]<310) {
		$excluded = " 0,5";
		$config{EXCLUDED_REGION}=$config{EXCLUDED_REGION}.$excluded;
	}
	if ($length[$n+1]<310) { # 注意这儿，一直屏蔽
		$start4 = $length[$n]+100+$length[$n+1]-5;
		$excluded = " $start4,5";
		$config{EXCLUDED_REGION}=$config{EXCLUDED_REGION}.$excluded;
	}
	

$config{PRIMER_PRODUCT_SIZE_RANGE}="150-600";
$config{PRIMER_PRODUCT_OPT_SIZE}=400;
	$seq = $add_seq[$n];
	
	open IN,">$dat_file_name" || die"$!";
	&put_primer_head;
	close IN;
	$out_file_name = "add_seq_$nnn.out";
	`primer3_core <$dat_file_name >$out_file_name `;

	open IN,"$out_file_name" || die"$!";
	while (my $line = <IN>) {
		chomp $line;
		my @fields = split "=",$line;
		${$add_info[$n]}{$fields[0]} = $fields[1];
	}
	close IN;
		print  "length_n=$length[$n]\n";# change the position to left to the position to right
		${$add_info[$n]}{PRIMER_RIGHT} = &tran_primer_pos(${$add_info[$n]}{PRIMER_RIGHT},$length[$n]);
		${$add_info[$n]}{PRIMER_RIGHT_1} = &tran_primer_pos(${$add_info[$n]}{PRIMER_RIGHT_1},$length[$n]);
		${$add_info[$n]}{PRIMER_RIGHT_2} = &tran_primer_pos(${$add_info[$n]}{PRIMER_RIGHT_2},$length[$n]);

	
}





######################## Output ###########################################

open OUT,">$output" || die"$!";
open O,">for_blast.fa" || die"$!";

print OUT "SERIAL\tPRIMER NAME\tSEQ\tPOSITION\tTM\tGC\tPENALTY\n";
for (my $k = 1;$k<$seq_num;$k++) {
	print OUT "$desert_id\t$type[$k]\t$start[$k]\t$end[$k]\t$length[$k]\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT}\t${$info[$k]}{PRIMER_LEFT_TM}\t${$info[$k]}{PRIMER_LEFT_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT}\t${$info[$k]}{PRIMER_RIGHT_TM}\t${$info[$k]}{PRIMER_RIGHT_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_PENALTY}\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_1_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT_1}\t${$info[$k]}{PRIMER_LEFT_1_TM}\t${$info[$k]}{PRIMER_LEFT_1_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_1_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT_1}\t${$info[$k]}{PRIMER_RIGHT_1_TM}\t${$info[$k]}{PRIMER_RIGHT_1_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_1_PENALTY}\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_2_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT_2}\t${$info[$k]}{PRIMER_LEFT_2_TM}\t${$info[$k]}{PRIMER_LEFT_2_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_2_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT_2}\t${$info[$k]}{PRIMER_RIGHT_2_TM}\t${$info[$k]}{PRIMER_RIGHT_2_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_2_PENALTY}\t";
	print OUT "$seq[$k]\n";
	print O ">left-1_$k\n${$info[$k]}{PRIMER_LEFT_SEQUENCE}\n";
	print O ">right-1_$k\n${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\n";
	print O ">left-2_$k\n${$info[$k]}{PRIMER_LEFT_1_SEQUENCE}\n";
	print O ">right-2_$k\n${$info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\n";
	print O ">left-3_$k\n${$info[$k]}{PRIMER_LEFT_2_SEQUENCE}\n";
	print O ">right-3_$k\n${$info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\n";
	
	print OUT "\t\t\t\t\t";
	print OUT "${$add_info[$k]}{PRIMER_LEFT_SEQUENCE}\t${$add_info[$k]}{PRIMER_LEFT}\t${$add_info[$k]}{PRIMER_LEFT_TM}\t${$add_info[$k]}{PRIMER_LEFT_GC_PERCENT}\t${$add_info[$k]}{PRIMER_LEFT_PENALTY}\t${$add_info[$k]}{PRIMER_RIGHT_SEQUENCE}\t${$add_info[$k]}{PRIMER_RIGHT}\t${$add_info[$k]}{PRIMER_RIGHT_TM}\t${$add_info[$k]}{PRIMER_RIGHT_GC_PERCENT}\t${$add_info[$k]}{PRIMER_RIGHT_PENALTY}\t";
	print OUT "${$add_info[$k]}{PRIMER_LEFT_1_SEQUENCE}\t${$add_info[$k]}{PRIMER_LEFT_1}\t${$add_info[$k]}{PRIMER_LEFT_1_TM}\t${$add_info[$k]}{PRIMER_LEFT_1_GC_PERCENT}\t${$add_info[$k]}{PRIMER_LEFT_1_PENALTY}\t${$add_info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\t${$add_info[$k]}{PRIMER_RIGHT_1}\t${$add_info[$k]}{PRIMER_RIGHT_1_TM}\t${$add_info[$k]}{PRIMER_RIGHT_1_GC_PERCENT}\t${$add_info[$k]}{PRIMER_RIGHT_1_PENALTY}\t";
	print OUT "${$add_info[$k]}{PRIMER_LEFT_2_SEQUENCE}\t${$add_info[$k]}{PRIMER_LEFT_2}\t${$add_info[$k]}{PRIMER_LEFT_2_TM}\t${$add_info[$k]}{PRIMER_LEFT_2_GC_PERCENT}\t${$add_info[$k]}{PRIMER_LEFT_2_PENALTY}\t${$add_info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\t${$add_info[$k]}{PRIMER_RIGHT_2}\t${$add_info[$k]}{PRIMER_RIGHT_2_TM}\t${$add_info[$k]}{PRIMER_RIGHT_2_GC_PERCENT}\t${$add_info[$k]}{PRIMER_RIGHT_2_PENALTY}\t";
	print OUT "$add_seq[$k]\n";
	print O ">join_left-1_$k\n${$add_info[$k]}{PRIMER_LEFT_SEQUENCE}\n";
	print O ">join_right-1_$k\n${$add_info[$k]}{PRIMER_RIGHT_SEQUENCE}\n";
	print O ">join_left-2_$k\n${$add_info[$k]}{PRIMER_LEFT_1_SEQUENCE}\n";
	print O ">join_right-2_$k\n${$add_info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\n";
	print O ">join_left-3_$k\n${$add_info[$k]}{PRIMER_LEFT_2_SEQUENCE}\n";
	print O ">join_right-3_$k\n${$add_info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\n";

}

my $k = $seq_num;
	print OUT "$desert_id\t$type[$k]\t$start[$k]\t$end[$k]\t$length[$k]\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT}\t${$info[$k]}{PRIMER_LEFT_TM}\t${$info[$k]}{PRIMER_LEFT_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT}\t${$info[$k]}{PRIMER_RIGHT_TM}\t${$info[$k]}{PRIMER_RIGHT_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_PENALTY}\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_1_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT_1}\t${$info[$k]}{PRIMER_LEFT_1_TM}\t${$info[$k]}{PRIMER_LEFT_1_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_1_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT_1}\t${$info[$k]}{PRIMER_RIGHT_1_TM}\t${$info[$k]}{PRIMER_RIGHT_1_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_1_PENALTY}\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_2_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT_2}\t${$info[$k]}{PRIMER_LEFT_2_TM}\t${$info[$k]}{PRIMER_LEFT_2_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_2_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT_2}\t${$info[$k]}{PRIMER_RIGHT_2_TM}\t${$info[$k]}{PRIMER_RIGHT_2_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_2_PENALTY}\t";
	print OUT "$seq[$k]\n";

	print O ">left-1_$k\n${$info[$k]}{PRIMER_LEFT_SEQUENCE}\n";
	print O ">right-1_$k\n${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\n";
	print O ">left-2_$k\n${$info[$k]}{PRIMER_LEFT_1_SEQUENCE}\n";
	print O ">right-2_$k\n${$info[$k]}{PRIMER_RIGHT_1_SEQUENCE}\n";
	print O ">left-3_$k\n${$info[$k]}{PRIMER_LEFT_2_SEQUENCE}\n";
	print O ">right-3_$k\n${$info[$k]}{PRIMER_RIGHT_2_SEQUENCE}\n";


sub tran_primer_pos {
	my $string;
	my $length_1;
	($string,$length_1) = @_;
	print  "$string\t$length_1\n";
	my @fields = split ",",$string;
	my $pos = $fields[0]-$length_1-100;
	my $new = $pos.",$fields[1]";
	return $new;
}





sub extract {#*********************** Gene desert directory need modified when move to other directory!!!
	my ($desert_name,$start,$end) = @_;
	my $length = $end-$start+1;
#	open IN,"/disk10/prj0326/xujzh/est_map_desert/chr3/unmask_chr3_desert/$desert_name" || die"$!"; #### path need	modified!!!!
open IN,"/disk2/prj0327/zhangqp/prj_2003-11_Big_Gene/2004-01-08_Design_Primers/Gene_Desert/$desert_name" || die"can't open $desert_name file:$!";
	print  "file = $desert_name\t$start,$end\t$length\n";
	my $seq = "";
	while (<IN>) {
		chomp;
		unless ($_ =~/^>/) {
			$seq = $seq.$_;
#			print  "$seq";
		}
	}
	close IN;
#	print  "$seq\n";
	my $subseq = substr $seq,$start-1,$length;
	return $subseq;
}



sub put_primer_head{
print IN <<"map";
PRIMER_SEQUENCE_ID=$seq_id
SEQUENCE=$seq
PRIMER_OPT_SIZE=$config{PRIMER_OPT_SIZE}
PRIMER_MAX_SIZE=$config{PRIMER_MAX_SIZE}
PRIMER_MIN_SIZE=$config{PRIMER_MIN_SIZE}
PRIMER_OPT_TM=$config{PRIMER_OPT_TM}
PRIMER_MAX_TM=$config{PRIMER_MAX_TM}
PRIMER_MIN_TM=$config{PRIMER_MIN_TM}
TARGET=$config{TARGET}
EXCLUDED_REGION=$config{EXCLUDED_REGION}
PRIMER_PRODUCT_SIZE_RANGE=$config{PRIMER_PRODUCT_SIZE_RANGE}
PRIMER_PRODUCT_OPT_SIZE=$config{PRIMER_PRODUCT_OPT_SIZE}
PRIMER_PAIR_WT_PRODUCT_SIZE_LT=.10
PRIMER_PAIR_WT_PRODUCT_SIZE_GT=.30
PRIMER_MIN_GC=20
PRIMER_MAX_GC=50
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_GC_CLAMP=1
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  
