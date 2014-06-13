#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# Éú³É»­Í¼shell
# 
if (@ARGV<2) {
	print  "programm length_file file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


while (<IN>) {
	chomp ;
	@s = split /\t/,$_;
	$gene = $s[0];
	$file_cdna = "Blat_CDNA_2_Gene_List_Out/For_SVG/".$gene.".for_svg.arrow";
	$file_scaffold = "Blastz_Gene_List_2_Scaffold_Singlets_Out/".$gene.".fa.blastz.snap.for_svg.arrow";
	$file_svg = "SVG/".$gene.".svg";
	print OUT "perl draw_svg.pl \"$gene\" $file_cdna $file_scaffold $file_svg $file_in \n";
}

