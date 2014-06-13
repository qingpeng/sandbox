#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 和水稻一样,所有 scaffold 内部洞应该至少有一个 clone (一
# 对正反向 reads )跨过,在后面标出所有跨过的 clone.

# 注意考虑 contig在scaffold方向 与 正反向reads在contig中的位置之间的关系 另外length<3000bp
# 2004-5-19 17:16
# 
if (@ARGV<3) {
	print  "programm direction primer.list out\n";
	exit;
}
($file_in,$file_primer,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open P,"$file_primer" || die"$!";
open OUT,">$file_out" || die"$!";


# Contig11 R Contig9 L 1: 1168=bsbq0000346
# Contig12 R Contig27 R 3: 1970=bsbq0001733 1877=bsbq0000735 2063=bsbq0001844

while (<IN>) {
	chomp;
	@s_1 = split /:/,$_;
	@s_2 = split /\s/,$s_1[0]; 
	$id = $s_2[0]."_".$s_2[2]."_".$s_2[1]."_".$s_2[3];
	@s_3 = split /\s/,$s_1[1];
	for (my $k = 1;$k<scalar @s_3;$k++) {
		@s_4 = split "=",$s_3[$k];
		if ($s_4[0]<3000) {# length <3000
		
		if ($k == 1) {
			$read = $s_4[1];
		}
		else {
			$read = $read.":".$s_4[1];
		}

		}
	}
	$read{$id} = $read;
	$read = "";
}

foreach my $key (sort keys %read) {
	print  "$key\t$read{$key}\n";
}

# Scaffold000004.	11739										
# 1	Contig48. U	3617									
# 			BSBQ_000004_1_0519	GGCCTTCTTCTCCCTCTCTT	20	59.021	55	TATCTGTGAAGGCGAACTGC	20	59.028	50
# 3630	Contig37. C	1916									
# 			BSBQ_000004_2_0519	GCAGTTCGCCTTCACAGATA	20	59.028	50	CAATTACACGCCCACAAAAG	20	59.083	45
# 5631	Contig34. C	2175									
# 			BSBQ_000004_3_0519	CCCCAAGTCACTTTCCTGTT	20	59.037	50	CCTAAGACGGAGTCCAGCTC	20	59.04	60
# 7806	Contig31. U	1813									
# 			BSBQ_000004_4_0519	GAGCTGGACTCCGTCTTAGG	20	59.04	60	CACTTCCAAGGACCCAGATT	20	58.989	50
# 9637	Contig39. C	2218									
# 			BSBQ_SUPER000001_1_0519	CAGCTACCCACCCCAGTATT	20	58.934	55	TTTGCCTGAACTCAAAGTGG	20	58.897	45
# Scaffold000009.	5240										
# 1	Contig44. U	5240									
# 			BSBQ_SUPER000001_2_0519	ATCGCGCTGGAGTAGAAAAT	20	58.955	45	GGCTCCTTTCCTTGTCTCTG	20	59.014	55

while (my $line = <P>) {
	chomp $line;
	if ($line =~/^Scaffold/) {
		print OUT "$line\n";
		$first = "y";
	}
	elsif ($first eq "y" && $line =~/^\d+\t(Contig\d+)\.\s(\w)\t/) {
		$last_contig = $1;
		$last_UC = $2;
		print OUT "$line\n";
		$first = "n";
	}
	elsif ($line =~/^\t\t\tBS.*/) {
			print OUT "$line\n";
	}
	elsif ($first eq "n" && $line =~/^\d+\t(Contig\d+)\.\s(\w)\t/) {
		$contig = $1;
		$UC = $2;
		if ($last_UC eq "U") { # consider the direction 
			$d_1 = "R";
		}
		else {
			$d_1 = "L";
		}
		if ($UC eq "U") {
			$d_2 = "L";
		}
		else {
			$d_2 = "R";
		}


		$join = $last_contig."_".$contig."_".$d_1."_".$d_2;
		print  "$join===$read{$join}\n";
		print OUT "\t\t$read{$join}\n$line\n";
		$last_contig = $contig;
		$last_UC = $UC;
	}
}
