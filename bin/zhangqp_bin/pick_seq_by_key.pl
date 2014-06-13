#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# pick certain sequence by name in list
# 2004-3-10 20:51
# 提取title中含有特定字符的序列
# 2004-11-4 9:53
# 
# >rfat0103_f8.y1.abd
# >rpfat_11987.y1.abd
# >rpfat_10921.y1.abd
# >rfat0119_d22.y1.abd
# >rfat0111_a19.y1.abd
# >rfat0109_p10.y1.abd
# >rpfat_13733.y1.abd
# >rfat0127_f23.y1.abd
# >rpfat_11914.y1.abd
# >rfat0108_k16.y1.abd
# >rfat0125_p15.y1.abd
# >rfat0101_j20.y1.abd

if (@ARGV<3) {
	print  "programm fasta_file title_key file_out \n";
	exit;
}
($file_in,$key,$file_out) =@ARGV;


open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";




while (<IN>) {
	chomp ;
	if ($_ =~/^>/) {
		if ($_ =~/$key/) {
			$yes = 1;
			print OUT "$_\n";
		}
		else {
			$yes = 0;
		}
	}
	else {
		if ($yes == 1) {
			print OUT "$_\n";
		}
	}
	
}
