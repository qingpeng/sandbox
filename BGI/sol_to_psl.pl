#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# sol 转换成 psl格式
# 2005-3-26 18:01
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#AJ670268[0]	521	5	514	+[4]	bsbj[5]	71131	7592	48401	2[9]	268	5,171;327,514;[11]	7592,7761;48210,48401;[12]	+134;+134;
#AJ670268	521	2	519	-	bsae	107823	63604	91562	2	337	2,171;239,519;	91562,91390;63882,63604;	-134;-203;
#AJ670894	452	38	372	-	bsag	135460	98326	98644	2	231	38,186;196,372;	98644,98496;98502,98326;	-106;-130;

#9999	0	0	0	0	0	0	0	+	ENSP00000257915_23	10	11	12	bsbm	14	15	16	11	76,41,145,107,155,122,119,78,130,83,149,	query_start	49107,49316,50211,50469,53040,53434,54275,54624,55088,55823,56431,
#9999	0	0	0	0	0	0	0	-	ENSP00000258787_24	10	11	12	bsbo	14	15	16	5	147,114,105,145,233,	query_start	15688,39056,46640,47473,51925,

while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	$query = $s[0];
	$subject = $s[5];
	$direction = $s[4];
	$exon_num = $s[9];
	$subject_pos = $s[12];
	@s_subject_pos = split ";",$subject_pos;
	foreach my $ssp (@s_subject_pos) {
		@ss = split ",",$ssp;
		if ($direction eq "+") {
			push @starts,$ss[0];
			push @ends,$ss[1];
		}
		else {
			push @starts,$ss[1];
			push @ends,$ss[0];
		}
	}
	@sort_start = sort {$a <=> $b} @starts;
	@sort_end = sort {$a <=> $b} @ends;
	$subject_start = $sort_start[0]-1;
	$subject_end = $sort_end[-1];
			for (my $k = 0;$k<scalar @sort_start;$k++) {
			print  "sort_end=$sort_end[$k]\tsort_start=$sort_start[$k]\n";
			$length = $sort_end[$k]-$sort_start[$k]+1;
			$all_length = $all_length+$length;
			# print  "chr_start==$chr_start\n";
			$start = $sort_start[$k]-1;

			$exon_length = $exon_length.$length.",";
			$exon_start = $exon_start.$start.",";
			}
		print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$direction\t$query\t$all_length\t11\t12\t$subject\t14\t$subject_start\t$subject_end\t$exon_num\t$exon_length\tquery_start\t$exon_start\n";
		@starts =();
		@ends = ();
		$exon_length = "";
		$exon_start = "";
		$all_length = 0;
}

