#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 整合信息
# 2005-2-25 21:27
# 对operon human oligo不合格的重新设计
# 
if (@ARGV<2) {
	print  "programm genome_oligo gene_oligo redesign_list original_xls final_result \n";
	exit;
}
($file_genome,$file_gene,$file_list,$file_in,$file_out) =@ARGV;

open GENOME,"$file_genome" || die"$!";
open GENE,"$file_gene" || die"$!";
open LIST,"$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#AC005393	N	AC005393_80_13	77.67	AGTATCGCATATGGAGAGATAGGCAATGTTGCTGCCACTCTCGACCCTAGTAAGGAAGGTTCATAGGGGT
#AF022375	Y	AF022375_11_7	77.09	TAAATGTTCCTGCAAAAACACAGACTCGCGTTGCAAGGCGAGGCAGCTTGAGTTAAACGAACGTACTTGC
#AF042162	N/A	N/A	N/A	N/A


while (<GENOME>) {
	chomp;
	@s = split /\t/,$_;
	unless ($s[2] eq "N/A") {
		$tm_genome{$s[0]} = $s[3];
		$seq_genome{$s[0]} = $s[4];
	}
}


#AF130110	+	AF130110_5_12	73.57	GGAATCTGTTTATCGGTGCCCATTATATCCTTAAGTTTGGATATTTAGCTGACCTTCGCTTTAACATAGG
#AF308602	-	AF308602_0_95	76.50	CCACCCAGCCTCACCTGGTGCAGACCCAGCAGGTGCAGCCACAAAACTTACAGANNNNNNNNNNNNNNNN
#AF395440	+	AF395440_1_118	72.99	GCATGGCCAACAAACCTCTCTCCACTTTGGCAACAAATAGTTTTAAATTTGGTTTCCAGAGTAAGTTAAT

while (<GENE>) {
	chomp;
	@s = split /\t/,$_;
		$tm_gene{$s[0]} = $s[3];
		$seq_gene{$s[0]} = $s[4];
}

#NM_004793
#NM_006012
#NM_003119

while (<LIST>) {
	chomp;
	$list{$_} = 1;
}


#NM_006793	N/A	N/A	N/A	N/A
#NM_139312	genome	Y	75.91	TTCCGGAGCAGAGTTGGAGAATCTTGTGAACCAGGCTGCATTAAAAGCAGCTGTTGATGGAAAAGAAATG
#NM_000015	identity	N	74.3	TGGGGAGAAATCTCGTGCCCAAACCTGGTGATGGATCCCTTACTATTTAGAATAAGGAACAAAATAAAC


while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (exists $list{$s[0]}) {
		if (exists $tm_genome{$s[0]}) {#先考虑genome_level
			print OUT "$s[0]\tgenome_level\t$tm_genome{$s[0]}\t$seq_genome{$s[0]}\n";
		}
		elsif (exists $tm_gene{$s[0]}) {#先考虑gene_level
			print OUT "$s[0]\tgene_level\t$tm_gene{$s[0]}\t$seq_gene{$s[0]}\n";
		}
		else {#没有设计出来
			print OUT "$s[0]\tN/A\tN/A\tN/A\n";
		}
	}
	else {# Operon 信息
		print OUT "$s[0]\t-\t$s[3]\t$s[4]\n";
	}
}
