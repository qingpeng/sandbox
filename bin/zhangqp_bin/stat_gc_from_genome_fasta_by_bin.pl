#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# ����bin����ÿһ��bin�ڵ�GC
# ����Ҫ��
# 1.���bin��n ����һ�룬����
# 2.����������bin����һ�룬����
# 2003-9-19 23:33
# 2003-12-2 10:42 ϸ���޸�

# ���룺������fasta���� ���Ҳ���Ŀ���Ǹ������ֵĻ��������У�
# �����ÿ��bin��GC�����һ�У����Ϊһ��GCֵ�������ں�������GC-genomeͼ

use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","o:s","b:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-i		file in ����fasta��ʽ
		-o		file out
		-b		bin
USAGE

die $usage unless $opts{"i"}and$opts{"o"}and$opts{"b"};

my $filein = $opts{"i"};
my $fileout = $opts{"o"};
my $bin = $opts{"b"};

open IN,"$filein" || die"can't open $filein:$!";
open OUT,">$fileout" || die"can't open $fileout:$!";
my $count = 0;
my $base_num = 0;
my $n_count = 0;
my $gc;
while (my $line= <IN>) {
	chomp $line;
	if ($line =~/^>/) {#����ÿ��������ʼ��һ��
#		print OUT  "$base_num**** $bin\n";
		if (($base_num/$bin) > 0.5) {# ���һ��bin�е�base��Ŀ����bin��һ��
#		unless ($base_num ==0) {
			if (($n_count/$base_num)<0.5) {# N��ĿС��base��һ��
				$gc = $count/($base_num-$n_count);
#				print OUT "$count  $base_num-$n_count $gc\n";
				print OUT "$gc\n";
			}
		}
		$base_num = 0;
		$count = 0;
		$n_count = 0;
		
	}
	
	else {
		my @base = split "",$line;
		for (my $k = 0 ;$k<scalar @base;$k++) {
			$base_num ++;
			if ($base[$k] eq "n"||$base[$k] eq "N") {
				$n_count ++;
			}
			if ($base[$k] eq "g"||$base[$k] eq "G"||$base[$k] eq "c"||$base[$k] eq "C") {
				$count ++;
			}
#			if ($k == (scalar @base)-1) {
#				if (($base_num/$bin)>0.5) {
#					$gc = int($count*100/$base_num)/100;
#					print  OUT "$count..$base_num...$gc\n";
#				}
#			}
			if ($base_num == $bin  ) {
				if ( ($n_count/$bin)<0.5) {
					$gc = $count/($bin-$n_count);
#					print OUT "$count  $bin-$n_count $gc\n";
					print OUT "$gc\n";
					$base_num = 0;
					$count = 0;
					$n_count = 0;
				}
				else {
#					$gc = $count/($bin-$n_count); �п���Ϊ�� 
#					print OUT "xxxxxxxxxxx$count  $bin-$n_count   $gc\n";
					$n_count = 0;
					$count = 0;
					$base_num = 0;
				}
			}
		}

	}	
}

#���������ļ����һ��
#print OUT "$base_num  $bin \n";
	if (($base_num/$bin) > 0.5) {
#		unless ($base_num ==0) {
		if (($n_count/$base_num)<0.5) {
			$gc = $count/($base_num-$n_count);
#			print OUT "$count  $base_num-$n_count $gc\n";
			print OUT "$gc\n";
			$base_num = 0;
			$count = 0;
			$n_count = 0;
		}
	}