#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去掉比到其余位置的oligo ，去最靠近3'端的oligo,尽可能在orf区域内
# for all human gene oligo design
# 2005-2-24 10:17
# 
if (@ARGV<4) {
	print  "programm file_orf file_in_exon file_out_exon file_out \n";
	exit;
}
($file_orf,$file_in_exon,$file_out_exon,$file_out) =@ARGV;

open IN_EXON,"$file_in_exon" || die"$!";
open OUT,">$file_out" || die"$!";
open ORF,"$file_orf" || die"$!";
open OUT_EXON,"$file_out_exon" || die"$!";




#AB005216	chr17	36883467	36930787
#AB006589	chr14	62706328	62755204
#AB023191	chr10	74279052	74345380
#AB023420	chr5	132464165	132516351
#AC005393	chr19	N/A	N/A
#AF022375	chr6	43785839	43799154
#AF042162	chr14	53697381	
#AF042163	chr8	100856316	
#AF042838	chr5	56127344	56205416
#AF045451	chr2	191726446	191757602
#AF049656	chr12	116115101	
#AF055270	chr2	38950258	
#AF081567	chr3	85982612	85985193

while (<ORF>) {
	chomp;
	@s = split /\t/,$_;
	$orf_left{$s[0]} = $s[2];
	$orf_right{$s[0]} = $s[3];
	unless (exists $orf_left{$s[0]} && exists $orf_right{$s[0]} ) { # 有可能没有信息,或者为空 
		$orf_left{$s[0]} = "N/A";
		$orf_right{$s[0]} = "N/A";
	}
	unless (defined $orf_left{$s[0]} && defined $orf_right{$s[0]} ) { # 有可能没有信息,或者为空 
		$orf_left{$s[0]} = "N/A";
		$orf_right{$s[0]} = "N/A";
	}
}

# NM_148901	chr1	-	1044946	1048147	1045028	1048009	4	1044946,1045836,1046807,1047822,	1045398,1045924,1046930,1048147,
# NM_148902	chr1	-	1044946	1048147	1045281	1048009	5	1044946,1045492,1045836,1046807,1047822,	1045406,1045674,1045924,1046930,1048147,
#
#while (<REFGENE>) {
#	chomp;
#	@s = split /\t/,$_;
#	$orf_left{$s[0]} = $s[5]+1;
#	$orf_right{$s[0]} = $s[6];
#	#print  "$s[0]\n";
#}

#AF119897_0_783_901_3	70	1	70	205974599	205974530	246127941	 139	2e-32	70/70	100	chr1
#AF119897_0_783_901_4	70	1	70	205974589	205974520	246127941	 139	2e-32	70/70	100	chr1
#AF119897_0_783_901_5	70	1	70	205974579	205974510	246127941	 139	2e-32	70/70	100	chr1
#AF119897_1_1	70	1	70	205975515	205975446	246127941	 139	2e-32	70/70	100	chr1
#AF119897_1_2	70	1	70	205975505	205975436	246127941	 139	2e-32	70/70	100	chr1
#AF119897_1_3	70	1	70	205975495	205975426	246127941	 139	2e-32	70/70	100	chr1
#NM_007253_4_1_93_1	70	1	70	15862243	15862174	63811651	52.0	7e-07	59/70	84	chr19
#NM_007253_4_1_93_1	70	3	70	15896690	15896623	63811651	48.1	1e-05	57/68	83	chr19
#NM_007253_4_1_93_1	70	3	70	15743965	15743898	63811651	48.1	1e-05	57/68	83	chr19
#NM_007253_4_1_93_1	70	1	70	15620970	15621039	63811651	44.1	2e-04	58/70	82	chr19
#NM_007253_4_1_93_2	70	1	70	15547535	15547604	63811651	67.9	1e-11	61/70	87	chr19


while (<OUT_EXON>) {
	chomp;
	@s =split /\t/,$_;
	$out_exon{$s[0]} = 1;
}

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
	unless (exists $out_exon{$s[0]}) { # 没有比到exon以外的其它区域（非unique)
	
	if ($s[0] =~/(NM_\d+)_.*/) {
		$gene = $1;
	}
	else {
		if ($s[0]=~/(.*?)_.*/) {
			$gene = $1;
		}
	}
#print  "$gene\n";

if ( ! exists $orf_left{$gene} ||! exists $orf_right{$gene}) {
	$orf_left{$gene} = "N/A";
	$orf_right{$gene} = "N/A";
}
	if ( $orf_left{$gene} ne "N/A"  && $start>=$orf_left{$gene} && $end<=$orf_right{$gene}) { # 位于orf区域内 
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
	else {# 不再Orf 内部 或者没有orf信息 

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
	#print  "$gene\n";
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






