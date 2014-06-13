#!/usr/local/bin/perl
# programmer: ligq
# e-mail:ligq@genomics.org.cn

#use warnings;
#use strict;
# ������֤�����Ƿ�ȵ��������λ�� 
# �Ƿ�С��5000
# û���жϷ���
#
# ע���˳���ȥ����
#
# �����һ����ͬ
#
# �޸��˱�־�� left_ 
# 2004-2-4 21:02
# ֻ�������һ�����ϵģ���repeat)



($file_in)=@ARGV;

open I,"$file_in" || die"$!";

$null = <I>;
while (my $line = <I>) {
	chomp $line;
	my @fields = split /\t/,$line;
	if ($fields[3]-$fields[2]+1>$fields[1]-2) {
		push @{$start{$fields[0]}},$fields[4];
		push @{$end{$fields[0]}},$fields[5];
		push @{$chr{$fields[0]}},$fields[11];
	}
}

@keys = keys %start;
#print  "@keys \n";


foreach my $key  (keys %start) {


	if ($key =~/(.*)left_(.*)/) {
#		print  "$key\n";
$mark=1;
		$num = $2;
		$head = $1;
		$right_key = $1."right_".$2;### ע�� �ָ��� 

		for (my $k = 0;$k<scalar @{$start{$key}};$k++) {
			
			for (my $kk=0;$kk<scalar @{$start{$right_key}};$kk++) {
				
				if (${$chr{$right_key}}[$kk] eq ${$chr{$key}}[$k]  && ${$start{$right_key}}[$kk] - ${$start{$key}}[$k]<5000 && ${$start{$right_key}}[$kk] - ${$start{$key}}[$k]>-5000) {
					if ($mark != 1) {
					
					print  "$key\t${$chr{$key}}[$k]\t${$start{$key}}[$k]\t${$end{$key}}[$k]\t$mark\n";
					print  "$right_key\t${$chr{$right_key}}[$kk]\t${$start{$right_key}}[$kk]\t${$end{$right_key}}[$kk]\t$mark\n";
					}
				$mark++;
				}
			}
			for (my $kk=0;$kk<scalar @{$start{$key}};$kk++) {# �ж��Լ��Ƿ��ظ������Ҿ���̫����
				
				if (${$chr{$key}}[$kk] eq ${$chr{$key}}[$k]  && ${$start{$key}}[$kk] - ${$start{$key}}[$k]<5000 && ${$start{$key}}[$kk] - ${$start{$key}}[$k]>-5000 && ${$start{$key}}[$kk] - ${$start{$key}}[$k]!=0) {
					if ($mark !=1) {
					

					print  "$key\t${$chr{$key}}[$k]\t${$start{$key}}[$k]\t${$end{$key}}[$k]\t$mark\n";
					print  "$key\t${$chr{$key}}[$kk]\t${$start{$key}}[$kk]\t${$end{$key}}[$kk]\t$mark\n";
					}
				$mark++;
				}
			}

				
			
		}

	}
}