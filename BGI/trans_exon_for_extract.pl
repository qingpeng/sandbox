#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从exon.list 文件转换成 可以截取exon序列的格式
# 2004-11-24 21:24
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# ===============
# LOCUS:NM_139312
# ===============
# 
# 5' 1K	-	chr10	27447327	27448327
# exon_1	-	chr10	27447112	27447327	start-codon:27447145
# intron_1	-	chr10	27441975	27447112	
# exon_2	-	chr10	27441840	27441975	
# intron_2	-	chr10	27440603	27441840	
# exon_3	-	chr10	27440432	27440603	
# intron_3	-	chr10	27438525	27440432	
# exon_4	-	chr10	27438362	27438525	
# intron_4	-	chr10	27435420	27438362	
# exon_5	-	chr10	27435321	27435420	
# intron_5	-	chr10	27429320	27435321	
# exon_6	-	chr10	27429210	27429320	
# intron_6	-	chr10	27427916	27429210	
# exon_7	-	chr10	27427765	27427916	
# intron_7	-	chr10	27427057	27427765	
# exon_8	-	chr10	27426973	27427057	
# intron_8	-	chr10	27424876	27426973	
# exon_9	-	chr10	27424793	27424876


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	if ($_ =~/^LOCUS:(.*)/){
		$gene = $1;
	}
	elsif ($_ =~/^exon/){
		$seq_name = $gene."_$s[0]";
		$start = $s[3]+1;
		print OUT "$s[2]\t$s[1]\t$start\t$s[4]\t$seq_name\n";
	}
}

