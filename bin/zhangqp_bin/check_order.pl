#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# ��� ������scaffold�Ƿ����ظ�������ͳ�ƹ���ȥ��scaffold���

# 2004-5-31 11:18

if (@ARGV<2) {
	print  "programm bac_list file_out \n";
	exit;
}
($file_list,$file_out) =@ARGV;

open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";

print OUT "BAC\tAll_scaffold\tScaffold_picked\tPercent_of_num\tAll_scaffold_length\tScaffold_length_picked\tPercent_of_length\n";
while (my $bac = <LIST>) {
	my %mark =();
	chomp $bac;
	$file_order = "./$bac/Scaffold/$bac.blastz_human_genome.snap.sort.order";

	open ORDER,"$file_order" || die"$!";
	$length_all = 0;
	while (<ORDER>) {
		chomp;
		@s = split /\t/,$_;
		$scaffold = $s[1];
		if (exists $mark{$scaffold}) {
			print  "$bac\t$scaffold!!!!!\n";
		}
		$length = $s[2];
		$length_all = $length_all+$length;#���ϵ�scaffold����
		$mark{$scaffold} =5;
	}
	$pick_scaffold_num = scalar keys %mark;#���ϵ�scaffold����
	$scaffold_file = "./$bac/Scaffold/$bac.phrap.scaffold";
	open SCA,"$scaffold_file" || die"$!";
	$sca_count = 0;
	$scaffold_length = 0;
	while (<SCA>) {
		chomp;
		if ($_=~/^>/) {
			$sca_count ++;#�ܹ�����
		}
		else {
			$line_length = length $_;
			$scaffold_length = $scaffold_length+$line_length;#�ܹ�scaffold����
		}
	}
	$sca_percent = int($pick_scaffold_num*10000/$sca_count)/100;# ����ȡ��scaffold �ٷֱ�
	$length_percent = int($length_all*10000/$scaffold_length)/100; # ���ϵ�scaffold ���Ȱٷֱ�
	print OUT "$bac\t$sca_count\t$pick_scaffold_num\t$sca_percent\t$scaffold_length\t$length_all\t$length_percent\n";

}

