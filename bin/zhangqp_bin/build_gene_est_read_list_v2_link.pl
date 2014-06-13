#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 建立 reads/est 与gene 关系列表！
# 考虑 est 中 singleton!
# 不仅仅处理est,包括genome
# 兼容处理由多个table合并到一起的table 
# 2004-8-28 15:28
# 处理link文件，直接从link文件中生成gene -reads/est list file
# 2004-9-1 10:18
# 



# 
# Link file
# cluster1245_2_Step1 to L24498_0,67518543,67523920 of L24498,1,1 @chr 67521017 -> 67521138 @read 166 -> 286 &direction +
# cluster1245_-8_Step1 to L24498_0,67518543,67523920 of L24498,1,1 @chr 67523290 -> 67523535 @read 9 -> 256 &direction +
# cluster1094_7_Step1 to AK055088_1,59736554,59736692 of AK055088,1,-1 @chr 59736554 -> 59736653 @read 459 -> 558 &direction -


if (@ARGV<1) {
	print  "perl ... link.file \n";
	exit;
}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";
my %hash;

while (my $line = <IN>) {
	chomp $line;
    if ($line =~/(\S+) to \w+\,\d+\,\d+ of (\w+)\,\w+\,\-?1 \@chr \d+ \-\> \d+ \@read \d+ \-\> \d+ \&direction \S/) {
			my ($readName,$geneName)=($1,$2);
			my $est_read = $readName;
			if ($est_read =~/singleton_(.*)/) {
				$est_read = $1;
			}
			 ${$hash{$geneName}}{$est_read} = 1;
	}
	
}

foreach my $gene (sort keys %hash) {
	@est_read = keys %{$hash{$gene}};
	print  "$gene\t@est_read\n";
}



