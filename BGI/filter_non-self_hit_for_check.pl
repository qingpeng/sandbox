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
# 处理 check结果，看有没有比到non-self区域！
# 2004-12-8 10:56
# 修改，处理一个reads比到多个gene中
#  2004-12-8 11:28
# 测试用！没有正式使用！！
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
			print  "$est\n";
		}
		push @{$gene{$est}},$fields[0];
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

# AB005216        70      1       70      102     171     640      139    1e-31   70/70   100     rdpcxb0_058712.y1.scf
# AB006589        70      1       70      538     469     663      139    1e-31   70/70   100     rcpg0_155476.y1.abd
# AB023191        70      1       70      561     630     1039     139    1e-31   70/70   100     cluster30814_1_Step2
# AB023420        70      1       70      1324    1393    1478     139    1e-31   70/70   100     cluster28879_1_Step1
# AB023420        70      1       70      456     525     962      139    1e-31   70/70   100     cluster28879_2_Step1

	my @fields = split /\t/,$line;
			$gene = $fields[0];
#			print  "$query\t$read\n";
            $subject = $fields[-1];
			$mark = "N";
			foreach my $gene2 (@{$gene{$subject}}) {
				if ($gene eq $gene2) {
					$mark = "Y";
				}
			}

			unless ($mark eq "Y") { #不属于同一个gene 
				print OUT "$line\n";
			}
}



	



