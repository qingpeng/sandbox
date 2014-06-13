#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<5) {
	print  "programm link_direct link_other oligo_genome oligo_pep file_out \n";
	exit;
}
($file_ld,$file_lo,$file_og,$file_op,$file_out) =@ARGV;

open LD,"$file_ld" || die"$!";
open LO,"$file_lo" || die"$!";
open OG,"$file_og" || die"$!";
open OP,"$file_op" || die"$!";
open OUT,">$file_out" || die"$!";


# NM_004793	N/A
# NM_006012	 NM_017393 
# NM_003119	 NM_153176 
# NM_139312	N/A
# NM_006796	N/A
# NM_004083	 NM_007837 
# NM_005194	 NM_009883 
# NM_006708	N/A
# NM_005326	 NM_024284 

while (<LD>) {
	chomp;
	@s =split/\t/,$_;
	$gene = $s[1];
	$gene =~s/\s//g;
	unless ($gene eq "N/A") {
		$mouse{$s[0]} = $gene;
	}
}

# AB005216	BAA22432	NP_619598	NM_138657
# AB006589	BAA31966	NP_034287	NM_010157
# AB023191	BAA76818	NP_759011	NM_172379
# AB023420	BAA75062	NP_032326	NM_008300
# AC005393	AAC28914	NP_034222	NM_010092

while (<LO>) {
	chomp;
	@s = split /\t/,$_;
	$mouse{$s[0]} = $s[3];
}

# gene	in_orf?	oligo
# NM_007383	Y	NM_007383_exon_10_1_548_9
# NM_007386	Y	NM_007386_exon_20_12
# NM_007392	N	NM_007392_exon_9_296_522_15
# NM_007415	Y	NM_007415_exon_19_1_83_1
# NM_007423	Y	NM_007423_exon_13_1_132_7
# NM_007440	Y	NM_007440_exon_13_11
# NM_007452	Y	NM_007452_exon_6_1_134_7
# NM_007471	Y	NM_007471_exon_15_8
# NM_007498	Y	NM_007498_exon_4_1_417_13
# NM_007499	Y	NM_007499_exon_62_7
# NM_007516	Y	NM_007516_exon_5_1_90_3
# NM_007525	Y	NM_007525_exon_11_1_360_25
# NM_007527	Y	NM_007527_exon_6_1_145_4
# NM_007569	N/A	N/A
# NM_007570	Y	NM_007570_exon_2_189_433_8
# NM_007591	Y	NM_007591_exon_6_1_74_1
# NM_007597	Y	NM_007597_exon_12_11_94_2
# NM_007630	Y	NM_007630_exon_7_8
# NM_007633	Y	NM_007633_exon_12_256_635_5


while (<OG>) {
	chomp;
	@s = split /\t/,$_;
	unless ($s[0] eq "gene") {
		$orf{$s[0]} = $s[1];
		$oligo{$s[0]} = $s[2];
		$level{$s[0]} = "genome";
	}
}

while (<OP>) {
	chomp;
	@s = split /\t/,$_;
	unless ($s[0] eq "gene") {
		$orf{$s[0]} = $s[1];
		$oligo{$s[0]} = $s[2];
		$level{$s[0]} = "gene";
	}
}


foreach my $key (sort keys %mouse) {
	$mouse_gene = $mouse{$key};
	print OUT "$key\t$mouse_gene\t$orf{$mouse_gene}\t$level{$mouse_gene}\t$oligo{$mouse_gene}\n";
}

