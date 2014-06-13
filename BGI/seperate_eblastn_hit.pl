#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从 eblastn 去除比到自己exon内部的的hit
# 并且挑出 比到自己内部的hit
# 2004-12-9 13:34
# for Human Oligo
# 2005-2-23 9:44
# 
# 
if (@ARGV<4) {
	print  "programm exon_pos file_in file_in_exon file_out \n";
	exit;
}
($file_pos,$file_in,$file_in_exon,$file_out) =@ARGV;

open POS,"$file_pos" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open IN_EXON,">$file_in_exon" || die"$!";



#zhangqp@690a /disk17/prj0313/zhangqp/prj_2003-12_Pig_Oligo/800_Gene_Final/Human_Oligo/Identity_Checked$head all.blastn.eblastn.filter49 
#AF081567_8_321_396_1    70      1       70      237974655       237974586       246127941       60.0    1e-08   60/70   85      chr1
#AF081567_8_680_794_1    70      1       66      237974296       237974231       246127941       83.8    8e-16   60/66   90      chr1
#AF081567_8_680_794_2    70      1       70      237974286       237974217       246127941       83.8    8e-16   63/70   90      chr1
#AF081567_8_680_794_3    70      2       68      237974275       237974209       246127941       77.8    5e-14   60/67   89      chr1
#AF081567_8_680_794_4    70      1       58      237974266       237974209       246127941       67.9    5e-11   52/58   89      chr1
#AF081567_8_977_1065_1   70      9       58      237973985       237973936       246127941       52.0    3e-06   44/50   88      chr1
#AF119897_0_24_316_1     70      1       70      205975378       205975309       246127941        139    2e-32   70/70   100     chr1
#AF119897_0_24_316_10    70      1       70      205975288       205975219       246127941        139    2e-32   70/70   100     chr1
#AF119897_0_24_316_11    70      1       70      205975278       205975209       246127941        139    2e-32   70/70   100     chr1
#AF119897_0_24_316_12    70      1       70      205975268       205975199       246127941        139    2e-32   70/70   100     chr1
#zhangqp@690a /disk17/prj0313/zhangqp/prj_2003-12_Pig_Oligo/800_Gene_Final/Human_Oligo/Identity_Checked$head /disk17/prj0313/zhangqp/prj_2003-12_Pig_Oligo/800_Gene_Final/Human_Oligo/all_gene_exon.list.to_extract
#chr17   +       36883467        36883878        AB005216_0
#chr17   +       36892557        36892621        AB005216_1
#chr17   +       36895598        36895702        AB005216_2
#chr17   +       36896154        36896255        AB005216_3
#chr17   +       36897133        36897263        AB005216_4
#chr17   +       36898728        36898896        AB005216_5
#chr17   +       36908503        36908631        AB005216_6
#chr17   +       36926525        36926660        AB005216_7
#chr17   +       36927064        36927214        AB005216_8

# chr1	-	45645801	45646179	NM_002574_exon_6
while (<POS>) {
	chomp;
	@s = split /\t/,$_;
	$first{$s[4]} = $s[2];
	$second{$s[4]} = $s[3];
	$chrr{$s[4]} = $s[0];
	$exon{$s[4]} = "1";
}


# NM_002574_exon_3_45_119_1	70	1	70	45650528	45650459	245522847	 139	2e-32	70/70	100	chr1
#NM_033664_12_2	70	1	70	64862959	64862890	90041932	 139	6e-33	70/70	100	chr16
#NM_033664_12_3	70	1	70	64862949	64862880	90041932	 139	6e-33	70/70	100	chr16
#AF081567_8_977_1065_1	70	1	58	53517735	53517792	135037215	75.8	1e-13	53/58	91	chr10
#AF082557_15_5	70	5	66	93269297	93269358	135037215	44.1	4e-04	52/62	83	chr10


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	if ($s[0] =~/(NM_.*?_\d+).*/) {
		$exon = $1;
		print  "$exon\n";
	}
	else {
		if ($s[0] =~/(.*?_\d+).*/) { # 
			$exon = $1;
			print  "$exon\n";
		}
	}

	if ($s[4] <$s[5]) {
		$start = $s[4];
		$end = $s[5];
	}
	else {
		$start = $s[5];
		$end = $s[4];
	}


print  "aa\n";
	if ($s[-1] eq $chrr{$exon} && $start>=$first{$exon} && $end<=$second{$exon}) {
		$mark{$exon} = "1";
		print IN_EXON "$_\n";
	}
	else {
		print OUT "$_\n";
	}
}

foreach my $key (keys %exon) {
	unless (exists $mark{$key}) {  # 有输出是正常的，exon全部为Non-unique区域
		print  "not_map: $key\n";
	}
}





