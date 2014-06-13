#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# transform file format:
# 2005-1-24 10:01
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#Input:
#@AB005216,17,1
#>AB005216_0,36883467,36883878
#>AB005216_1,36892557,36892621
#>AB005216_2,36895598,36895702
#>AB005216_3,36896154,36896255
#>AB005216_4,36897133,36897263
#>AB005216_5,36898728,36898896
#>AB005216_6,36908503,36908631
#>AB005216_7,36926525,36926660
#>AB005216_8,36927064,36927214
#>AB005216_9,36930729,36930836
#>AB005216_10,36930838,36930868
#@AB006589,14,-1
#>AB006589_0,62683748,62684373
#>AB006589_1,62691729,62691909


#Out:
#chr1	-	45649272	45649402	NM_002574_exon_5
#chr1	-	45645801	45646179	NM_002574_exon_6
#chr10	-	27483113	27483327	NM_139312_exon_1
#chr10	-	27477841	27477975	NM_139312_exon_2
#chr10	-	27476433	27476603	NM_139312_exon_3
#chr10	-	27474363	27474525	NM_139312_exon_4

while (<IN>) {
	chomp;
	if ($_ =~/^@(\w+),(\S+),(-?1)/) {
		#$gene = $1;
		$chro = $2;
		$strain = $3;
		if ($strain == 1) {
			$direction = "+";
		}
		else {
			$direction = "-";
		}
	}
	else {
		if ($_ =~/^>(\w+),(\d+),(\d+)/) {
			$exon = $1;
			$start = $2;
			$end = $3;
			$chr_print = "chr".$chro;
			print OUT "$chr_print\t$direction\t$start\t$end\t$exon\n";
		}
	}

}



