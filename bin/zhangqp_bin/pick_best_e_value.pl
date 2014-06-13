#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理 blastx _nr  eblastn格式 提取出每一个比上的nr pep 并且列出比上的最小的e值
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# Query-name	Letter	QueryX	QueryY	SbjctX	SbjctY	Length	Score	E-value	Overlap/total	Identity	Sbject-Name	Sbjct_description
# bsaa/bsaa.fa.Contig4	2790	1761	1363	77	210	211	 144	1e-32	76/134	56	dbj|BAC87505.1|	unnamed protein product [Homo sapiens]
# bsaa/bsaa.fa.Contig4	2790	2493	2245	1	83	211	 111	7e-23	54/83	65	dbj|BAC87505.1|	unnamed protein product [Homo sapiens]


while (<IN>) {
	chomp;
	unless ($_ =~/^Query/) {
		@s = split /\t/,$_;
		$q_name = $s[0];
		if ($q_name =~/\//) {
		
		@ss = split /\//,$q_name;
		$bac = $ss[0];
		}
		$e_value = $s[8];
		$s_name = $s[11];
		$s_description{$s_name} = $s[12];
		
		if (exists $e{$s_name}) {
			if ($e_value < $e{$s_name}) {
				$e{$s_name} = $e_value;
			}
		}
		else {
			$e{$s_name} = $e_value;
		}
	}
}

foreach my $key (sort keys %e) {
	print OUT "$bac\t$key\t$e{$key}\t$s_description{$key}\n";
}

