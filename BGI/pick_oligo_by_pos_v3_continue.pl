#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# pick best
# 2004-8-23 19:58
# 1.最为靠近3'端
# 2.位于orf中，根据 753gene.cds_in_genome.merged 信息
# 2004-8-27 14:24 modified
# 修改 输入 CDS 位置信息文件（有些没有信息）
# 2004-11-18 15:09
# v3
# 增加输出 在orf内的oligo列表
# 2004-11-19 17:44
# 不管在不在orf区域内都输出，但是标记上
# 2004-12-27 15:10
# 进一步处理没有在oligo 在orf内部的基因,orf内部能找到的不再处理
# 2004-12-27 15:45
# 

if (@ARGV<4) {
	print  "programm cds_pos tableOligo.index.pos oligo_in_ORF  best_oligo file_out \n";
	exit;
}
($file_cds,$file_in,$orf_oligo,$file_best,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open CDS,"$file_cds" || die"$!";
open ORF_OLIGO,">$orf_oligo" || die"$!";
open BEST,"$file_best" || die"$!";

# U97105	chr8	26523466	26536259
# X57025	chr12	101376606	
# X60188	chr16	30165314	
# X77166	chr20	44826749	44826943
# Z70723	chr7	94540434	
# NM_000776	chr7	98967162	98993115
# NM_004353	chr11	75003744	75009478
# NM_006220	chr14	92820092	
# NM_015858	chr1	21888397	21888571
# HSU11076	chr17	N/A	N/A
# NM_004958	chr1	10877088	11029012
# NM_005957	chr1	11560283	11572719
# NM_014424	chr1	15704772	15707155

while (<CDS>) {
	chomp;
	@s = split /\t/,$_;
	if (defined $s[2] && defined $s[3] && $s[2] ne "N/A") {
		$orf_left{$s[0]} = $s[2];
		$orf_right{$s[0]} = $s[3];
		$have_orf{$s[0]} = "Y";
	}
	else {
		$have_orf{$s[0]} = "N";
		$orf_left{$s[0]} = 0;
		$orf_right{$s[0]} = 1000000000;
	}
}

# NM_024796	chr1	-	801449	802749	801942	802434	1	801449,	802749,
# NM_017891	chr1	-	923262	957529	924330	932981	10	923262,925790,925918,927315,928576,928939,931790,932909,933428,957497,	924425,925821,925944,927450,928642,929035,931866,933003,933541,957529,
# NM_153254	chr1	+	1021134	1027299	1021491	1026580	9	1021134,1021471,1021920,1022168,1023178,1023798,1024313,1025357,1026406,	1021291,1021778,1022039,1022298,1023253,1023884,1024485,1025529,1027299,
# NM_004195	chr1	-	1044946	1048147	1045281	1048009	5	1044946,1045471,1045836,1046807,1047822,	1045406,1045674,1045924,1046930,1048147,
# NM_148901	chr1	-	1044946	1048147	1045028	1048009	4	1044946,1045836,1046807,1047822,	1045398,1045924,1046930,1048147,
# NM_148902	chr1	-	1044946	1048147	1045281	1048009	5	1044946,1045492,1045836,1046807,1047822,	1045406,1045674,1045924,1046930,1048147,

# while (<REFGENE>) {
# 	chomp;
# 	@s = split /\t/,$_;
# 	$orf_left{$s[0]} = $s[5];
# 	$orf_right{$s[0]} = $s[6];
# }

# @AB005216,17,1
# rdpcxb0_058712.y1.scf_42_171_28	rdpcxb0_058712.y1.scf_42_171	17	36908594	AB005216	1	36908503	36908631
# bda_1355.z1.abd_291_375_6	bda_1355.z1.abd_291_375	17	36895684	AB005216	1	36895637	36895702
# rdpcxb0_058712.y1.scf_42_171_16	rdpcxb0_058712.y1.scf_42_171	17	36908570	AB005216	1	36908503	36908631
# dpcxb0_025650.z1.scf_1_131_2	dpcxb0_025650.z1.scf_1_131	17	36897172	AB005216	1	36897133	36897245

while (<IN>) {
	chomp;
	if ($_ =~/^@(\w+),\w+,(\-?\d+)/) {
		$gene = $1;
		$direction = $2;
		$hash{$gene} =1;
	}
	else {

		
		@s = split /\t/,$_;
		$pos = $s[3];
		if ($pos >= $orf_left{$gene}+34+2 && $pos <= $orf_right{$gene} - 35 -2) { #  保证 在orf中 （+/-2 绝对保证了这一点）
			$in_orf{$s[0]} = "yes";
		print ORF_OLIGO "$s[0]\n";
		}
		else {
			$in_orf{$s[0]} = "no";
		}


		if ($s[4] eq $gene) {
			if ($direction eq "1") {# 方向伪正，坐标越大靠近三'端
				if (exists $oligo{$gene}) {
					if ($pos >$oligo_pos{$gene}) {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$pos;
					}
				}
				else {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$pos;
				}

			}
			else {
					if (exists $oligo{$gene}) {
					if ($pos <$oligo_pos{$gene}) {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$pos;
					}
				}
				else {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$pos;
				}

			
			}
		}
		else {
			#print  "$gene\n$_\n";
		}

		
	}
}


# title:Gene	Have ORF position information	Oligo
# AF055270	N	rbdd_86431.y1.abd_304_399_3
# AK055533	N	cluster1942_1_Step2_845_931_2
# BC008791	N	dpaxb0_133140.z1.scf_12_616_301_605_22
# BC010284	Y	N/A
# NM_000089	Y	rnep16c_i6.y1.abd_29_183_4
# NM_000162	Y	N/A
# NM_000240	Y	N/A
# NM_000314	Y	N/A
# NM_000605	Y	byd_48243.z1.abd_1_477_1_131_7
# NM_000714	Y	cluster11655_1_Step1_255_393_1
# NM_000758	Y	N/A
# NM_000786	Y	N/A
# NM_000849	Y	N/A

while (<BEST>) {
	chomp;
	@s = split /\t/,$_;
	unless ($_=~/^title/ || $s[2] eq "N/A") {
		$best_oligo{$s[0]} = $s[2];
	}
}

#print  "$best_oligo{NM_000605}\n";

print OUT "title:Gene\tHave ORF position information\tin_ORF?\tOligo\n";
foreach my $key (sort keys %hash) {
#	print  "$key\t$best_oligo{$key}\n";
	if (exists $best_oligo{$key}) { # 在ORF内部已经挑出满足条件最好的oligo,不再处理，直接拿过来
#	print  "$key\n";
		print OUT "$key\t$have_orf{$key}\tyes\t$best_oligo{$key}\n";
	}
	else { # orf内部没有合适的oligo,外部最靠3'端
		print OUT "$key\t$have_orf{$key}\tno\t$oligo{$key}\n";
	}
}

