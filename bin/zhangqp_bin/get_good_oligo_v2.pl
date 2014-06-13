#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 去掉不合格的Oligo，并且对每个基因取最靠近3'端的oligo
# 2005-2-25 16:33
# v2 bug
# 2005-2-25 21:59
# 
if (@ARGV<5) {
	print  "programm all_gene_exon.list.to_extract original_oligo.fasta.list  49_check 21_check file_out \n";
	exit;
}
($file_gene,$file_oligo_list,$file_49,$file_21,$file_out) =@ARGV;

open GENE,"$file_gene" || die"$!";
open OLIGO,"$file_oligo_list" || die"$!";
open FOUR,"$file_49" || die"$!";
open TWO,"$file_21" || die"$!";
open OUT,">$file_out" || die"$!";

#chr17	+	36898728	36898896	AB005216_5
#chr17	+	36908503	36908631	AB005216_6

while (<GENE>) {
	chomp;
	@s =split/\t/,$_;
	print  "$s[4]===========\n";
	if ($s[4] =~/(.*)_\d+/) {
		$gene = $1;
	}
	$direction{$gene} = $s[1];
}


# 21BP
#-	AK057120_3_1	ENST00000331466	18	38	216	236	21
#-	AK057120_3_2	ENST00000255320	1	70	215	284	70
#

while (<TWO>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[0] eq "-") {
		if (exists $enst{$s[1]} && $s[2] ne $enst{$s[1]}) { # 前面有合格的transcript  enst存在并且与上一个不同!不能简单地这么判断！！！
			$bad{$s[1]} = 1;
		}
		elsif (exists $problem_enst{$s[1]} && $s[2] ne $problem_enst{$s[1]}) { # 前面有不合格的transcript 
			$bad{$s[1]} = 1;
		}
		else {
			$problem_enst{$s[1]} = $s[2];
		}
	}
	else {
		$enst{$s[1]} = $s[2]; #合格标记
	}
}

# 49bp
#-	AF130110_2_4	70	1	70	1319	1388	1910	 139	5e-33	70/70	100	ENST00000299300
#-	AF130110_3_1	70	1	70	1393	1462	1910	 139	5e-33	70/70	100	ENST00000299300


while (<FOUR>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[0] eq "-") {
		if (exists $enst{$s[1]} && $s[-1] ne $enst{$s[1]}) { # 前面有合格的transcript  enst存在并且与上一个不同!不能简单地这么判断！！！
			$bad{$s[1]} = 1;
		}
		elsif (exists $problem_enst{$s[1]} && $s[-1] ne $problem_enst{$s[1]}) { # 前面有不合格的transcript 
			$bad{$s[1]} = 1;
		}
		else {
			$problem_enst{$s[1]} = $s[-1];
		}
	}
	else {
		$enst{$s[1]} = $s[-1]; #合格标记
	}
}

# oligo list
#NM_005347_2_16
#NM_005347_2_17
#NM_005347_2_2
#NM_005347_2_3

# 正向区zui大的exon,最大的oligo
# 反向取最小的exon,最大的Oligo
# 
while (<OLIGO>) {
	chomp;
	unless (exists $bad{$_}) {
	
	if ($_ =~/(.*)_(\d+)_(\d+)/) {
		$gene = $1;
		$exon = $2;
		$oligo_num = $3;
	}
	if ($direction{$gene} eq "+") {
		if (exists $max_exon{$gene}) {
		
		if ($exon >=$max_exon{$gene}) {
			$max_exon{$gene} = $exon;
			if (defined ${$max_oligo{$gene}}[$exon]) {
			
			if ($oligo_num >=${$max_oligo{$gene}}[$exon]) {
				${$max_oligo{$gene}}[$exon] = $oligo_num;
			}
			}
			else {
				${$max_oligo{$gene}}[$exon] = $oligo_num;
			}
		}

		}
		else {
			$max_exon{$gene} = $exon;
			${$max_oligo{$gene}}[$exon] = $oligo_num;
		}
	}
	else {
		if (exists $max_exon{$gene}) {
		
		if ($exon <=$max_exon{$gene}) {
			$max_exon{$gene} = $exon;
			if (defined ${$max_oligo{$gene}}[$exon]) {

			if ($oligo_num >=${$max_oligo{$gene}}[$exon]) {
				${$max_oligo{$gene}}[$exon] = $oligo_num;
			}
			}
			else {
				${$max_oligo{$gene}}[$exon] = $oligo_num;
			}
		}

		}
		else {
			$max_exon{$gene} = $exon;
			${$max_oligo{$gene}}[$exon] = $oligo_num;
		}
	}
	}

}

foreach my $gene (sort keys %max_exon) {
	$oligo = $gene."_".$max_exon{$gene}."_".${$max_oligo{$gene}}[$max_exon{$gene}];
	print OUT "$gene\t$direction{$gene}\t$oligo\n";
}


