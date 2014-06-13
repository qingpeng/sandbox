#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# ����desert�и���exon��λ����Ϣ��ÿһ��exon�������
# 1.exon ����300���� �ڲ�һ�ԣ����˷ֱ���������������
# 2.ʼ����������5bp
# 3.Ĭ��GC���Ϊ50�����������Զ�������70

# v1.0 
#	add excluded region and target!
#	update: join the primer position is to the right exon 
#	update: filter 5 bps!!!
#	ע�⡡����ļ���λ������
#	���붼�Ǵ�1��ʼ��
#	ע�� refscan /genscan /blat start λ������0������end λ������1����

# v1.3 
#	�޸������ʽ�����ں�����������@type����
#	�޸������ʽ������һ��

# v1.4 
# 2004-2-4 14:13
#	���max gc=50 �����������Ļ����ʵ����� 
#	���add_length
#	for_blast ��ʽ�޸�
#	����repeat�����жϱ��
# 
# v1.5 
# 2004-4-18 20:26 
#	ֻ����ڲ����
#
# v1.6
#	�������������
#
# v1.61 
# 2004-5-13 16:53
#	ϸ΢�Ķ� 
#	

# input:
# position file (length is not required)

#	desert_id	start	end	length
#	7_0	1465457	1465778	321
#	7_0	1466700	1466862	162
#	7_0	1469366	1469506	140
#	7_0	1469838	1469957	119
#	7_0	1473594	1473659	65
#


use strict;

if(@ARGV<6){
	printf "Usage:program <dir/> <position_file> <gene_desert.fa��UNMASKED!!)> <primer.xls> <primer.fasta> <exon.fasta> \nExample: perl ../bin/primers_v1.61.pl 7_0/ 7_0/7_0.in ../Gene_Desert/7_0.fa 7_0/7_0.primer.xls 7_0/7_0.primer.fasta 7_0/7_0.exon.fasta \n";
	exit;
}


my $config_file;
my $output;
my $dir;
my $for_blast;
my $exon_file;
my $left_seq;
my $right_seq;
my $desert_fasta;
($dir,$config_file,$desert_fasta,$output,$for_blast,$exon_file) = (@ARGV);



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
$config{PRIMER_MAX_GC}=50;
$config{PRIMER_LEFT_INPUT}="";
$config{PRIMER_RIGHT_INPUT}="";


print "dir==$dir\n";

my @start;
my @end;
my @length;
my @type;

#..........................Get Data/Option ...................................
open IN,"$config_file" || die"Can't open $config_file:$!";
my $k = 0;
my $desert_id;
while (my $line = <IN>) {
	if ($line =~/\d/) {
		$k++;
		chomp $line;
		my @fields = split /\t/,$line;
		$desert_id = $fields[0];
		$start[$k] = $fields[1];
		$end[$k] = $fields[2];
		$length[$k] = $fields[2]-$fields[1]+1;
	}
}
close IN;

print  "Desert == $desert_id\n";


my $seq_num = $k;# exon ����

open EXON,">$exon_file" || die"$!";

########################## get sequence ###########################
my $N = 'N'x100;
my @seq;
#print  "$desert_id\n";
for (my $n = 1;$n<$seq_num+1;$n++) {
#	print  "$desert_id\t$start[$n]\t$end[$n]\n";
	$seq[$n] = &extract($desert_id,$start[$n],$end[$n]);
	print EXON ">seq_$n=\n$seq[$n]\n";
}

my @info;
my @left_info;
my @right_info;
my $seq_id;
my $dat_file_name;
my $out_file_name;
my $seq;
my $seq_length;


########################### get primers for single sequence ###########
for (my $n = 1;$n<$seq_num+1;$n++) {
	$seq_id = "$desert_id-$start[$n]_$end[$n]";
	$seq = $seq[$n];
	$seq_length = length $seq;

	
	####  �ж� �Ƿ� repeat ����
	
	if ($seq =~/[acgt]/) {
		${$info[$n]}{MASKED} = "masked";
	}
	else {
		${$info[$n]}{MASKED} = "      ";
	}
	$dat_file_name = "$dir"."seq_$n.dat";
	$config{EXCLUDED_REGION}="";

	#����һֱ�������˵�5bp ע����������Σ���
	my $start_r = $length[$n]-5;
	$config{EXCLUDED_REGION}="0,5 $start_r,5";



	my $mark = 0;
	for (my $gc=50;$gc<70;$gc++) {  ### ���max gc=50 �����������Ļ����ʵ�����

		if ($mark == 0) {
			$config{PRIMER_MAX_GC}=$gc;
			open IN,">$dat_file_name" || die"$!";
			&put_primer_head;
			close IN;

			$out_file_name = "$dir"."seq_$n.out";
			`primer3_core <$dat_file_name >$out_file_name `;

			####��ȡ��Ϣ##########33333333333
			open IN,"$out_file_name" || die"$!"; 
			while (my $line = <IN>) {
				chomp $line;
				my @fields = split "=",$line;
				${$info[$n]}{$fields[0]} = $fields[1];
			}
			close IN;

			####### ȷ���Ƿ������GCȡֵ 
			if (defined ${$info[$n]}{PRIMER_LEFT_SEQUENCE}) {
				$mark = 1;# �ɹ���Ƴ�����
				if ($gc>50) {
					${$info[$n]}{MARK}="++";
				}
				else {
					${$info[$n]}{MARK}="  ";
				}
			}
		}
	}












#########################################  ���exon ���� 300 bp ����ⲿ�����������

my $cut_seq;
my $temp;
my $pos;
my $new;
my $start;


#print  "$seq_length\n";
if ($seq_length>300) {




##########################���################3


	$config{EXCLUDED_REGION}="";
	$cut_seq = substr $seq,0,200;
	$left_seq = "TTTCACTTGGACCCACAAAG"."ACTGACTGAC".$cut_seq; # �˹����� ������ 
#	$seq_pro_right = $cut_seq."NNNNNNNNNN"."ACATCGAGACTGGGGACTAAAG";
	$config{PRIMER_LEFT_INPUT}="TTTCACTTGGACCCACAAAG";
	
	$dat_file_name = "$dir"."seq_$n.OUT.left.dat";
	my $new_length = length $left_seq;
	$start_r = $new_length-5;
#	print  "start_r==$start_r\n";
	$config{EXCLUDED_REGION}="$start_r,5";# �������Ҷ�5bp
	

	my $mark = 0;
	for (my $gc=50;$gc<70;$gc++) {  ### ���max gc=50 �����������Ļ����ʵ�����
		if ($mark == 0) {
	
			$config{PRIMER_MAX_GC}=$gc;
			open IN,">$dat_file_name" || die"$!";
			#print IN "$config{PRIMER_LEFT_INPUT}\n";
			&put_primer_head_left;
			close IN;

			$out_file_name = "$dir"."seq_$n.OUT.left.out";
			`primer3_core <$dat_file_name >$out_file_name `; 

			open IN,"$out_file_name" || die"$!";
			while (my $line = <IN>) {
				chomp $line;
				my @fields = split "=",$line;
				${$left_info[$n]}{$fields[0]} = $fields[1];
			}
			close IN;

			if (defined ${$left_info[$n]}{PRIMER_LEFT_SEQUENCE}) {
				$mark = 1;
				if ($gc>50) {
					${$info[$n]}{MARK}="++";
				}
				else {
					${$info[$n]}{MARK}="  ";
				}
			}
		}
	}

	####������λ�����껻��
	$temp = ${$left_info[$n]}{PRIMER_RIGHT};
	my @fields = split ",",$temp;
	$pos = $fields[0]-30;
	$new = $pos.",$fields[1]";
	${$left_info[$n]}{PRIMER_RIGHT}=$new;




##########################�Ҷ�################3

	$config{EXCLUDED_REGION}="";
	$start = $seq_length-200;
	$cut_seq = substr $seq,$start,200;
#	$seq = "TTTCACTTGGACCCACAAAG"."NNNNNNNNNN".$cut_seq;
	$right_seq = $cut_seq."ACTGACTGAC"."CTTTAGTCCCCAGTCTCGATGT";
	$config{PRIMER_RIGHT_INPUT}="ACATCGAGACTGGGGACTAAAG";
	$dat_file_name = "$dir"."seq_$n.OUT.right.dat";
	$config{EXCLUDED_REGION}="0,5";


	my $mark = 0;

	for (my $gc=50;$gc<70;$gc++) {  ### ���max gc=50 �����������Ļ����ʵ�����
		if ($mark == 0) {
			$config{PRIMER_MAX_GC}=$gc;

			open IN,">$dat_file_name" || die"$!";
			&put_primer_head_right;
			close IN;

			$out_file_name = "$dir"."seq_$n.OUT.right.out";
			`primer3_core <$dat_file_name >$out_file_name `;

			open IN,"$out_file_name" || die"$!";
			while (my $line = <IN>) {
				chomp $line;
				my @fields = split "=",$line;
				${$right_info[$n]}{$fields[0]} = $fields[1];
			}
			close IN;

			if (defined ${$right_info[$n]}{PRIMER_LEFT_SEQUENCE}) {
				$mark = 1;
				if ($gc>50) {
					${$info[$n]}{MARK}="++";
				}
				else {
					${$info[$n]}{MARK}="  ";
				}
			}

		}
	}

		# ת������	
		$temp = ${$right_info[$n]}{PRIMER_LEFT};
		#print  "${$right_info[$n]}{PRIMER_LEFT}\n";
		@fields = split ",",$temp;
		#print  "fields0=$fields[0]\tseq_length=$seq_length\n";
		$pos = $fields[0]+$seq_length-200;
		$new = $pos.",$fields[1]";
		${$right_info[$n]}{PRIMER_LEFT}=$new;

#print  "left_gc_percent===${$right_info[$n]}{PRIMER_LEFT_GC_PERCENT}\n";

}

}


######################## Output ###########################################

open OUT,">$output" || die"$!";
open O,">$for_blast" || die"$!";

#print OUT "SERIAL\tPRIMER NAME\tSEQ\tPOSITION\tTM\tGC\tPENALTY\n";
print OUT "SERIAL	Start	End	Length	GC>50?	Masked?	Left_Primer_IN	Primer_Pos	TM	GC	PENALTY	Right_Primer_IN	Primer_Pos	TM	GC	PENALTY	Left_Primer_OUT	Primer_Pos	TM	GC	PENALTY	Right_Primer_OUT	Primer_Pos	TM	GC	PENALTY	SEQUENCE
";
for (my $k = 1;$k<$seq_num+1;$k++) {
# modified here v1.3!!!
	my $serial = $desert_id."-$k";
	print OUT "$serial\t$start[$k]\t$end[$k]\t$length[$k]\t${$info[$k]}{MARK}\t${$info[$k]}{MASKED}\t";
	print OUT "${$info[$k]}{PRIMER_LEFT_SEQUENCE}\t${$info[$k]}{PRIMER_LEFT}\t${$info[$k]}{PRIMER_LEFT_TM}\t${$info[$k]}{PRIMER_LEFT_GC_PERCENT}\t${$info[$k]}{PRIMER_LEFT_PENALTY}\t${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\t${$info[$k]}{PRIMER_RIGHT}\t${$info[$k]}{PRIMER_RIGHT_TM}\t${$info[$k]}{PRIMER_RIGHT_GC_PERCENT}\t${$info[$k]}{PRIMER_RIGHT_PENALTY}\t";
	print OUT "${$left_info[$k]}{PRIMER_RIGHT_SEQUENCE}\t${$left_info[$k]}{PRIMER_RIGHT}\t${$left_info[$k]}{PRIMER_RIGHT_TM}\t${$left_info[$k]}{PRIMER_RIGHT_GC_PERCENT}\t${$left_info[$k]}{PRIMER_RIGHT_PENALTY}\t${$right_info[$k]}{PRIMER_LEFT_SEQUENCE}\t${$right_info[$k]}{PRIMER_LEFT}\t${$right_info[$k]}{PRIMER_LEFT_TM}\t${$right_info[$k]}{PRIMER_LEFT_GC_PERCENT}\t${$right_info[$k]}{PRIMER_LEFT_PENALTY}\t";
	print OUT "$seq[$k]\n";

	print O ">left_$k"."_in\n${$info[$k]}{PRIMER_LEFT_SEQUENCE}\n";
	print O ">right_$k"."_in\n${$info[$k]}{PRIMER_RIGHT_SEQUENCE}\n";
	print O ">left_$k"."_out\n${$left_info[$k]}{PRIMER_RIGHT_SEQUENCE}\n";
	print O ">right_$k"."_out\n${$right_info[$k]}{PRIMER_LEFT_SEQUENCE}\n";

}



sub tran_primer_pos {
	my $string;
	my $length_1;
	($string,$length_1) = @_;
#	print  "$string\t$length_1\n";
	my @fields = split ",",$string;
	my $pos = $fields[0]-$length_1-100;
	my $new = $pos.",$fields[1]";
	return $new;
}





sub extract {#*********************** get exon sequence from Gene Desert sequence 
	my ($desert_name,$start,$end) = @_;
	my $length = $end-$start+1;
	open IN,"$desert_fasta" || die"can't open $desert_name file:$!";
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
PRIMER_MAX_GC=$config{PRIMER_MAX_GC}
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  


sub put_primer_head_left{
print IN <<"map";
PRIMER_SEQUENCE_ID=$seq_id
SEQUENCE=$left_seq
PRIMER_LEFT_INPUT=$config{PRIMER_LEFT_INPUT}
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
PRIMER_MAX_GC=$config{PRIMER_MAX_GC}
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  

sub put_primer_head_right{
print IN <<"map";
PRIMER_SEQUENCE_ID=$seq_id
SEQUENCE=$right_seq
PRIMER_RIGHT_INPUT=$config{PRIMER_RIGHT_INPUT}
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
PRIMER_MAX_GC=$config{PRIMER_MAX_GC}
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  
