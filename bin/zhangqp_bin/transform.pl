#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#  blat psl 转成 temp格式，便于link
# 2004-8-21 17:24
# 

if (@ARGV<2) {
	print  "programm psl_file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# 2777	2	0	181	1	13	6	10507	-	gi|16552241|dbj|AK056751.1|	2973	0	2973	chr11	134482954	60891639	60905106	7	1615,157,155,209,199,97,528,	0,1615,1772,1927,2136,2335,2445,	60891639,60893822,60895816,60896615,60899361,60900564,60904578,
# 3922	13	0	297	0	0	3	31421	+	gi|12052907|emb|AL136693.1|HSM801661	4254	4	4236	chr2	243615958	172581530	172617183	4	262,209,155,3606,	4,266,475,630,	172581530,172600638,172612399,172613577,
# 5317	1	0	407	1	1	24	81101	+	gi|1518805|gb|U63139.1|HSU63139	5892	0	5726	chr5	181034922	131968845	132055671	26	72,444,84,152,186,205,129,166,194,207,183,158,176,238,190,127,194,111,93,114,128,225,86,143,134,1586,	0,73,517,601,753,939,1144,1273,1439,1633,1840,2023,2181,2357,2595,2785,2912,3106,3217,3310,3424,3552,3777,3863,4006,4140,	131968845,131968917,131971191,131987684,131991224,131991769,131999469,131999831,132000594,132001538,132003131,132003784,132006776,132007480,132015207,132015827,132016713,132020522,132021024,132021190,132027910,132029977,132049022,132049988,132052579,132054085,
# 207	0	0	0	0	0	1	73	+	gi|1518805|gb|U63139.1|HSU63139	5892	3217	3424	chr5	181034922	132021024	132021304	2	93,114,	3217,3310,	132021024,132021190,
# 678	15	0	0	1	1	2	2	+	gi|4589591|dbj|AB023191.1|	5183	3507	4201	chr20	63741868	10588511	10589206	4	316,173,5,199,	3507,3823,3997,4002,	10588511,10588828,10589001,10589007,
# 1471	80	0	0	0	0	1	2	+	gi|4589591|dbj|AB023191.1|	5183	0	1551	chr15	100256656	95030032	95031585	2	1161,390,	0,1161,	95030032,95031195,


while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	print  "$s[9]\n";
	@gg = split /\|/,$s[9];
	print  "$gg[3]\n";
	@ggg = split /\./,$gg[3];
	$gene_name = $ggg[0];
	print  "gene_name ==$gene_name\n";
#	exit;
	$match_length = $s[12]- $s[11];
	$chr = $s[13];
	if ($chr =~/chr(.*)/) {
		$new_chr = $1;
	}
	$direction = $s[8];
	if ($direction eq "+") {
		$new_direction = "1";
	}
	else {
		$new_direction = "-1";
	}

	if (exists $max_length{$gene_name}){
		if ($match_length>$max_length{$gene_name}) {
			$max_length{$gene_name} = $match_length;
			$exon_length{$gene_name} = $s[-3];
			$chr_pos{$gene_name} = $s[-1];
			$chr{$gene_name} = $new_chr;
			$direction{$gene_name} = $new_direction;
		}
	}
	else {
			$max_length{$gene_name} = $match_length;
			$exon_length{$gene_name} = $s[-3];
			$chr_pos{$gene_name} = $s[-1];
			$chr{$gene_name} = $new_chr;
			$direction{$gene_name} = $new_direction;
	}
}
#exit;
# @NM_012328,7,1
# >NM_012328_0,107770886,107771078
# >NM_012328_1,107772691,107772918
# >NM_012328_2,107773873,107775825
# @NM_000582,4,1
# >NM_000582_0,89355274,89355347
# >NM_000582_1,89356428,89356496


foreach my $gene (sort keys %max_length) {
	print OUT "\@$gene,$chr{$gene},$direction{$gene}\n";
	@exon_length = split ",",$exon_length{$gene};
	@chr_pos = split ",",$chr_pos{$gene};
	for (my $k = 0;$k<scalar @exon_length;$k++) {
		$exon = $gene."_".$k;
		$exon_start = $chr_pos[$k]+1;
		$exon_end = $exon_start+$exon_length[$k]-1;
		print OUT ">$exon,$exon_start,$exon_end\n";
	}
}



