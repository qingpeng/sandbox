#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# update: 包括TM以及序列
# 2004-12-29 14:18
# 合并pig oligo 列表
# 
if (@ARGV<3) {
	print  "programm oligo_genome oligo_pep file_out \n";
	exit;
}
($file_og,$file_op,$file_out) =@ARGV;

open OG,"$file_og" || die"$!";
open OP,"$file_op" || die"$!";
open OUT,">$file_out" || die"$!";


#			是否明确ORF
# BC004215	N	rdpbxa0_156383.y1.scf_8_368_269_361_3	81.19	CTGCCCTAAACTCTCCCACTATTTCAGTGTTACAGACTCCCTGCCCTTTCTTGGGGAGGGGGGAGTCCCC
# BC010111	N	rhea19_h12.y1.abd_135_292_9	75.33	ATACTTCAGAGACCAAGAGGGTCAAGATGTACTGCTGTTTATTGATAACATCTTTCGCTTCACCCAGGCT
# BC010284	Y	N/A	N/A	N/A
# BC012142	Y	rdpcxa0_140746.y1.scf_259_423_10	77.09	TAAGGAAAATTTACAAGCGCTGGAGAGGATGCACACGGTCACCTCCAAGTCCAACCTGTCTTATAACACC
# BC014469	Y	cpg0_068270.z1.abd_4_259_6_256_18	82.36	TCAACTTCTGGAAGCCGGTGCGGATCCCAATGGACTCAACCACTTCGGGAGGCGCCCGATCCAGGTAGCT


while (<OG>) {
	chomp;
	@s = split /\t/,$_;
		$have_orf{$s[0]} = $s[1];
		$oligo{$s[0]} = $s[2];
		$tm{$s[0]} = $s[3];
		$seq{$s[0]} = $s[4];
		$level{$s[0]} = "genome";
		$in_orf{$s[0]} = "yes";
}
#			是否明确ORF	是否在ORF区域内
# AF055270	N	yes	rbdd_86431.y1.abd_304_399_3	73.57	GTAACCTAGGGAAGGGTATTTCAACCGTCTAATCAAAATGGATCTGGACTATTACTCTGTAAATTCACAG
# AK055533	N	yes	cluster1942_1_Step2_845_931_2	79.43	AAGGAGCTGTGGCAAAGCATCTACAACCTGGAGGCGGAGAAGTTTGACCTGCAGGAGAAGTTCAAGCAGC
# BC008791	N	yes	dpaxb0_133140.z1.scf_12_616_301_605_22	81.77	TGAGAAGTAGCCTGGGGGAAAGGAGATGCAGGACCTCCCCTGTCCCTGCAAGGAAAGGTGGGGCTTTGGA
# BC010284	Y	no	dpcxa0_004249.z1.scf_29_458_37	74.16	AAATTAGAAGTCTGTGCTAGAACCGTCCCTTCCTACAGGTTATCTGTTCACACTGAAACTGGAGAAATTA
# NM_000089	Y	yes	rnep16c_i6.y1.abd_29_183_4	78.84	GCCTATCCTTGATATTGCACCTTTGGACATCGGTGATGCTGACCAAGAAGTCAGTGTGGACGTTGGCCCA
# NM_000162	Y	no	rbda_31442.y1.abd_1_376_31	79.43	GGAGAACAATGAAAAGGAGGAAACTCTGTGATTGAACCTCAAGCCAGAGTCCAGCCAGAGGGTGGGCCCT
# NM_000240	Y	no	dpcxb0_074341.z1.scf_3_540_47	80.60	AGGATCGTGCAAAGGAGGCAGTGGACTTTCCATCTCTAGAGGTTGGGTAGGTTCAGGGCCGGCCCATGAT
# 


while (<OP>) {
	chomp;
	@s = split /\t/,$_;
	unless ($s[0] eq "gene") {
		$have_orf{$s[0]} = $s[1];
		$in_orf{$s[0]} = $s[2];
		$oligo{$s[0]} = $s[3];
		$tm{$s[0]} = $s[4];
		$seq{$s[0]} = $s[5];
		$level{$s[0]} = "gene";
	}
}


foreach my $key (sort keys %level) {
	if ($have_orf{$key} eq "Y") {
		$have_orf = "Have_ORF";
	}
	else {
		$have_orf = "No_ORF";
	}
	if ($in_orf{$key} eq "yes") {
		$in_orf =  "Y";
	}
	else {
		$in_orf = "N";
	}
	print OUT "$key\t$have_orf\t$in_orf\t$level{$key}\t$oligo{$key}\t$tm{$key}\t$seq{$key}\n";
}

