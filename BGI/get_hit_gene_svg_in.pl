#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# filter gene hit from all human gene here just from figure in file
# 因为不画比上基因的图了，所以本程序暂时没用2004-5-1 16:50
if (@ARGV<2) {
	print  "programm human_gene_svg_in hit_gene_list hit_gene_svg_in \n";
	exit;
}
($human_gene_in,$hit_gene_list,$hit_gene_in) =@ARGV;

open IN,"$human_gene_in" || die"$!";
# 64587:64715:+::NM_139021
# 64910:65291:+1::NM_139021
# 159213:159653:-1::NM_078480
# 159744:159979:-::NM_078480
# 160165:160300:-::NM_078480
# 160426:160616:-::NM_078480
# 160696:160909:-::NM_078480
# 161027:161119:-::NM_078480
# 161207:161368:-::NM_078480
# 163500:163550:-::NM_078480



open LIST,"$hit_gene_list" || die"$!";
# Translation:ENSP00000313540	chr8	144914072	144915031	ENST00000320563	
# gi|17978512|ref|NP_510965.1|	chr8	145004529	145017518	NM_078480	
# gi|18141297|ref|NP_056171.1|	chr8	144979076	145003530	NM_015356	
# gi|20502986|ref|NP_620590.1|	chr8	144904490	144910607	NM_139021	
# gi|30794272|ref|NP_848659.1|	chr8	145021897	145030181	NM_178564	

open OUT,">$hit_gene_in" || die"$!";


while (<LIST>) {
	chomp;
	my @s = split /\t/,$_;
	$mark{$s[4]} = 5;
}

while (<IN>) {
	chomp;
	my @s = split /:/,$_;
	if (exists $mark{$s[4]}) {
		print OUT "$_\n";
	}
}


