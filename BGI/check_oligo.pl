#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 综合 信息
# 1。完全比对到基因组上，并且是相应基因区域 判断是否在orf区域内
# 2。有〉49bp比到了基因组其他区域上(非本身)
# 3. 有>21bp连续比到其他区域
# 


if (@ARGV<5) {
	print  "programm orf_file identity49_file continue21_file file_in file_out \n";
	exit;
}
($file_orf,$file_identity,$file_continue,$file_in,$file_out) =@ARGV;

open ORF,"$file_orf" || die"$!";
open IDENTITY,"$file_identity" || die"$!";
open CON,"$file_continue" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# NM_000015	69	1	69	18268610	18268678	chr_length	 137	7e-31	69/69	100	chr8	Out_Of_ORF
# NM_002895	69	1	69	36317616	36317548	chr_length	 137	7e-31	69/69	100	chr20	In_ORF

while (<ORF>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[-1] eq "Out_Of_ORF") {
		$orf{$s[0]} = "N";
	}
	else {
		$orf{$s[0]} = "Y";
	}
#	$orf{$s[0]} = $s[-1];
}

#NM_000015	69	5	58	18090657	18090710	chr_length	52.0	3e-05	47/54	87	chr8
#NM_001539	69	1	69	105366768	105366699	chr_length	91.7	4e-17	65/70	92	chrX
#NM_001539	69	3	69	57123210	57123142	chr_length	83.8	9e-15	63/69	91	chr13

while (<IDENTITY>) {
	chomp;
	@s = split /\t/,$_;
	$identity{$s[0]} = 1;
}

#NM_001539	chr22	44	64	16371566	16371546	21
#NM_001082	chr19	1	25	15631567	15631591	25
#NM_001082	chr19	27	59	15631593	15631625	33

while (<CON>) {
	chomp;
	@s = split /\t/,$_;
	$con{$s[0]} = 1;
}


#NM_002574	genome	N	76.5	AATGGCCTGAGTTGGCGTTGTGGGCAGGCTACTGGTTTGTATGATGTATTAGTAGAGCAACCCATTAATC	N/A	N/A	N/A	N/A	N/A	N/A	N/A	N/A
#NM_005809	N/A	N/A	N/A	N/A	N/A	N/A	N/A	N/A	genome	N	80.01	CCTGGTGTGGTTTGGGCCACGCATAAAAGGTTCTCCGGCCTAGGGCTCTCTCGGTTTTGAGATCTCTTTC
#NM_006793	N/A	N/A	N/A	N/A	N/A	N/A	N/A	N/A	genome	Y	80.01	GGTGGGCCGCAGTGTGGAAGAAACACTCCGTTTGGTAAAGGCGTTCCAGTTTGTGGAGACCCATGGAGAA
#NM_139312	genome	Y	75.91	TTCCGGAGCAGAGTTGGAGAATCTTGTGAACCAGGCTGCATTAAAAGCAGCTGTTGATGGAAAAGAAATG	genome	Y	74.74	GAATTTAGCGGAAGCTTTATTGACCTATGAGACTTTGGATGCCAAAGAGATTCAGATTGTTCTTGAGGGG	gene	Y	72.99	TGACCTACAGTGATACAGGAAAACTAAGTCCTGAAACTCAATCAGCCATTGAACAAGAAATAAGAATCCT
#NM_000015	-	-	74.3	TGGGGAGAAATCTCGTGCCCAAACCTGGTGATGGATCCCTTACTATTTAGAATAAGGAACAAAATAAAC	N/A	N/A	N/A	N/A	genome	Y	72.99	CACCTTTACAAGTAGGAGATTCAGCTATAAGGACGATGTAGATCTGGTTGAGTTTAAATATGTGAATGAG
#NM_000595	-	-	75.5	CATGGAGGAGCTTGGGGGATGACTAGAGGCAGGGAGGGGACTATTTATGAAGGCAAAAAAATTAAATTA	genome	Y	82.94	GCTCTGTGTACCAGGGGGCTGTGTTCCTGCTCACCCAGGGAGATCAGCTGTCCACACACACAGACGGCAC	genome	Y	80.6	CACCCACACCGACGGCATCTCCCATCTACACTTCAGCCCCAGCAGTGTATTCTTTGGAGCCTTTGCACTG
# 13 column


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	# if have orf/no orf , no map {};
	# have identity/ continue21 to other region
	# genome unique
	if ($s[1] eq "-") {
	
	if (exists $orf{$s[0]}) {
		$orf = $orf{$s[0]};
	}
	else {
		$orf = "no_map";
	}
		
	if (exists $identity{$s[0]}) {
		if (exists $con{$s[0]}) {
			$unique = "identity/contiguous_match";
		}
		else {
			$unique = "identity";
		}
	}
	else {
		if (exists $con{$s[0]}) {
			$unique = "contiguous_match";
		}
		else {
			$unique = "genome";
		}
	}

	print OUT "$s[0]\t$unique\t$orf\t$s[3]\t$s[4]\t$s[5]\t$s[6]\t$s[7]\t$s[8]\t$s[9]\t$s[10]\t$s[11]\t$s[12]\n";
	}
	else {
		print OUT "$_\n";
	}

}


