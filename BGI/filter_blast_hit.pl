#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 过滤比到自己基因上的hit
#  2004-12-23 14:06
# 
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# NM_009942_exon_1	gi|6753499|ref|NM_009942.1|	1	101	1	101	101
# NM_009942_exon_1	gi|6753499|ref|NM_009942.1|	114	152	111	149	39
# NM_009942_exon_2	gi|6753499|ref|NM_009942.1|	1	74	150	223	74
# NM_009942_exon_3	gi|6753499|ref|NM_009942.1|	1	100	224	323	100
# NM_009942_exon_4	gi|6753499|ref|NM_009942.1|	1	165	324	488	165
# NM_009942_exon_4	gi|6753499|ref|NM_009942.1|	167	189	490	512	23
# NM_008303_exon_1	gi|31982267|ref|NM_008303.2|	1	94	3	96	94


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	$exon = $s[0];
	if ($exon =~/(.*)_exon_\d+/) {
		$gene = $1;
	}
	unless ($s[1] =~/$gene/) {
		print OUT "$_\n";
	}
}