#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# »°oligo–Ú¡–£°
# 2004-8-22 20:02
# 
if (@ARGV<3) {
	print  "programm oligo file_in file_out \n";
	exit;
}
($file_oligo,$file_in,$file_out) =@ARGV;

open L,"$file_oligo" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# >bbdc_74451.z1.abd_263_395_7
# TAAAGAACTGGCTGAGAATATAAAGTGTCGTACGTTGTTTTCTACCCACTACCATTCATTAGTTGAAGAC
# >bbdc_74451.z1.abd_263_395_8
# AAGAACTGGCTGAGAATATAAAGTGTCGTACGTTGTTTTCTACCCACTACCATTCATTAGTTGAAGACTA


while (<L>) {
	chomp;
	if ($_ =~/^>(\S+)/) {
		$oligo = $1;
	}
	else {
		$seq{$oligo} = $_;
	}
}

# BC002513	Y	cluster7192_2_Step1_958_1500_1_248_11
# BC004215	N	rdpbxa0_156383.y1.scf_8_368_269_361_3
# BC010111	N	rhea19_h12.y1.abd_135_292_9
# BC010284	Y	N/A
# BC012142	Y	rdpcxa0_140746.y1.scf_259_423_10
# BC014469	Y	cpg0_068270.z1.abd_4_259_6_256_18


while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	print OUT ">$s[0]\n$seq{$s[2]}\n";
}

