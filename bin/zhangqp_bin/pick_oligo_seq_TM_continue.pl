#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 取oligo序列！以及TM值
# 2004-8-22 20:02
# 2004-12-29 10:30
# 针对 pig oligo Pep level
# 2004-12-29 10:51
# 
if (@ARGV<4) {
	print  "programm oligo_sequence oligo_TM file_in file_out \n";
	exit;
}
($file_oligo,$file_tm,$file_in,$file_out) =@ARGV;

open L,"$file_oligo" || die"$!";
open TM,"$file_tm" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# 
# cluster100151_1_Step1_25_170_1	36	0.5143	78.84
# cluster100151_1_Step1_25_170_2	34	0.4857	77.67
# cluster100151_1_Step1_25_170_3	33	0.4714	77.09
#
while (<TM>) {
	chomp;
	@s = split /\t/,$_;
	$tm{$s[0]} = $s[3];
}


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


# continue Pig Oligo Pep level
# title:Gene	Have ORF position information	in_ORF?	Oligo
# AF055270	N	yes	rbdd_86431.y1.abd_304_399_3
# AK055533	N	yes	cluster1942_1_Step2_845_931_2
# BC008791	N	yes	dpaxb0_133140.z1.scf_12_616_301_605_22
# BC010284	Y	no	dpcxa0_004249.z1.scf_29_458_37
# NM_000089	Y	yes	rnep16c_i6.y1.abd_29_183_4
# 

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	unless ($_ =~/^title/) {
		if ($s[2] ne "N/A") {
			print OUT "$_\t$tm{$s[3]}\t$seq{$s[3]}\n";
		}
		else {
			print OUT "$_\tN/A\tN/A\n";
		}
	}
}



