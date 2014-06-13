#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


# 和所有est/reads进行比对，
# 2004-5-25 13:29 增加注释

# 针对 Global!
#2004-6-25 10:45 检查！
# 过滤留下 不是比到同一个基因上去的 hit （没有考虑方向，包括反向比上！）
# 2004-8-29 9:57
# 处理eblastn 结果
# 2004-8-31 9:55
# 针对Eblastn结果( 过滤Identity时用到）
#  v3
#


# Eblastn filter
# bd_64114.z1.abd_104_261_26      70      1       70      364     433     592      139    1e-31   70/70   100     dpcxb0_064458.z1.scf
# bd_64114.z1.abd_104_261_26      70      1       70      154     223     361      139    1e-31   70/70   100     bd_64114.z1.abd
# bd_64114.z1.abd_104_261_26      70      1       70      58      127     369      139    1e-31   70/70   100     bd_64363.z1.abd
# bd_64114.z1.abd_104_261_26      70      1       66      130     195     574      131    3e-29   66/66   100     cluster27897_1_Step1

# gene_est_reads.list
#ENSG00000000003	rbyb_65626.y1.abd rbde_95219.y1.abd byd_6547.z1.abd cluster379_2_Step2 cluster379_-5_Step2 cluster379_-8_Step2 cluster379_-6_Step2
#ENSG00000000005	rbla_76619.y1.abd cluster72948_1_Step1 rcpg0_046994.y1.abd

if (@ARGV<2) {
	print  "programm file_in gene2est/read.list out_file\n";
	exit;
}
($file_in,$list_in,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

open IN,"$file_in" || die"$!";
open LIST,"$list_in" || die"$!";
while (my $line = <LIST>) { # 建立列表，那些reads属于比对上了同一个基因
	chomp $line;
	my @fields = split /\t/,$line;
	if ($fields[1] ne "") {
	
	my @fields2 = split /\s+/,$fields[1];
	foreach my $est (@fields2) {
		if (exists $gene{$est}) {
			#print  "$est\n";
		}
		$gene{$est} = $fields[0];
	}
	}
}

while (my $line = <IN>) {
	chomp $line;


# Eblastn filter
# bd_64114.z1.abd_104_261_26      70      1       70      364     433     592      139    1e-31   70/70   100     dpcxb0_064458.z1.scf
# bd_64114.z1.abd_104_261_26      70      1       70      154     223     361      139    1e-31   70/70   100     bd_64114.z1.abd
# bd_64114.z1.abd_104_261_26      70      1       70      58      127     369      139    1e-31   70/70   100     bd_64363.z1.abd
# bd_64114.z1.abd_104_261_26      70      1       66      130     195     574      131    3e-29   66/66   100     cluster27897_1_Step1


	my @fields = split /\t/,$line;
			$query = $fields[0];
			if ($query =~/^(\S+)\_\d+\_\d+\_\d+\_\d+\_\d+/) {
				$read = $1;
				
			}
			elsif ($query =~/^(\S+)\_\d+\_\d+\_\d+/ ) {
				$read = $1;
			}
#			print  "$query\t$read\n";
            $subject = $fields[-1];
			unless ($gene{$read} eq $gene{$subject}) { #不属于同一个gene 
				print OUT "$line\n";
			}
}

	



