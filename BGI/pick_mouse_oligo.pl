#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 挑选Oligo 针对mouse oligo pep level
# 2004-12-24 11:04
# 
if (@ARGV<4) {
	print  "programm file_refGene file_in_exon file_oligo_to_drop gene_to_design file_out \n";
	exit;
}
($file_refgene,$file_in_exon,$file_drop,$gene_to_design,$file_out) =@ARGV;

open IN_EXON,"$file_in_exon" || die"$!";
open OUT,">$file_out" || die"$!";
open REFGENE,"$file_refgene" || die"$!";
open DROP,"$file_drop" || die"$!";
open GENE,"$gene_to_design" || die"$!";



while (<GENE>) {
	chomp;
	$gene_to_design{$_} = 1; # 需要设计的,需要输出
}

# NM_148901	chr1	-	1044946	1048147	1045028	1048009	4	1044946,1045836,1046807,1047822,	1045398,1045924,1046930,1048147,
# NM_148902	chr1	-	1044946	1048147	1045281	1048009	5	1044946,1045492,1045836,1046807,1047822,	1045406,1045674,1045924,1046930,1048147,

while (<REFGENE>) {
	chomp;
	@s = split /\t/,$_;
	$orf_left{$s[0]} = $s[5]+1;
	$orf_right{$s[0]} = $s[6];
	#print  "$s[0]\n";
}


# NM_013636_exon_2_7
# NM_013636_exon_3_1
# NM_013636_exon_3_11
# NM_013636_exon_3_12
# NM_013636_exon_3_13
# NM_013636_exon_3_14
# NM_013636_exon_3_15
# NM_013636_exon_3_16
# NM_013636_exon_3_2
# NM_013636_exon_4_1
# NM_013636_exon_5_1
# NM_013636_exon_5_3
while (<DROP>) {
	chomp;
	$drop{$_} = 1;
}



# NM_002574_exon_1_1_186_1	70	1	70	45656702	45656633	245522847	 139	2e-32	70/70	100	chr1
# NM_002574_exon_1_1_186_2	70	1	70	45656692	45656623	245522847	 139	2e-32	70/70	100	chr1
# NM_002574_exon_1_1_186_3	70	1	70	45656682	45656613	245522847	 139	2e-32	70/70	100	chr1
# NM_002574_exon_1_1_186_8	70	1	70	45656632	45656563	245522847	 139	2e-32	70/70	100	chr1


# while (<OUT_EXON>) {
# 	chomp;
# 	@s =split /\t/,$_;
# 	$out_exon{$s[0]} = 1;
# }

while (<IN_EXON>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[4]<$s[5]) {
		$direction = "+";
		$start = $s[4];
		$end = $s[5];
	}
	else {
		$direction = "-";
		$start = $s[5];
		$end = $s[4];
	}
	unless (exists $drop{$s[0]}) { # 
	
	if ($s[0]=~/(.*)_exon.*/) {
		$gene = $1;
	}
	if ($start>=$orf_left{$gene} && $end<=$orf_right{$gene}) { # 位于orf区域内 
			if ($direction eq "+") {# 方向伪正，坐标越大靠近三'端
				if (exists $oligo{$gene}) {
					if ($end >$oligo_pos{$gene}) {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$end;
					}
				}
				else {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$end;
				}

			}
			else {
				if (exists $oligo{$gene}) {
					if ($start <$oligo_pos{$gene}) {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$start;
					}
				}
				else {
						$oligo{$gene} = $s[0];
						$oligo_pos{$gene} =$start;
				}
			}
	}
	else {# 不再Orf 内部

			if ($direction eq "+") {# 方向伪正，坐标越大靠近三'端
				if (exists $oligo_out{$gene}) {
					if ($end >$oligo_pos_out{$gene}) {
						$oligo_out{$gene} = $s[0];
						$oligo_pos_out{$gene} =$end;
					}
				}
				else {
						$oligo_out{$gene} = $s[0];
						$oligo_pos_out{$gene} =$end;
				}

			}
			else {
				if (exists $oligo_out{$gene}) {
					if ($start <$oligo_pos_out{$gene}) {
						$oligo_out{$gene} = $s[0];
						$oligo_pos_out{$gene} =$start;
					}
				}
				else {
						$oligo_out{$gene} = $s[0];
						$oligo_pos_out{$gene} =$start;
				}
			}
		
	}

	}
}

print OUT "gene\tin_orf?\toligo\n";
foreach my $gene (sort keys %orf_left) {
	if (exists $gene_to_design{$gene}) {
	
	print  "$gene\n";
	if (exists $oligo{$gene}) {
		print OUT "$gene\tY\t$oligo{$gene}\n";
	}
	elsif (exists $oligo_out{$gene}) {
		print OUT "$gene\tN\t$oligo_out{$gene}\n";
	}
	else {
		print OUT "$gene\tN/A\tN/A\n";
	}
	}

}






