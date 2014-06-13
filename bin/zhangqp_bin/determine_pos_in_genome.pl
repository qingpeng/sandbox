#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 根据scaffold/contig 与基因组的比对结果，确定在基因组上的位置
# 一半或以上contig比对到了同一个基因组很近的区域  gap <150K以内即算做确定位置
# 以第一个为准，如果没有确定，需要人工检查如果长度较短需提高警惕
# 问题可能出在，第一个比到chr上不是最好的，下面没有连起来，最后没有超过半数的chr，另一个位置也大于半数可能性很小！ 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;


# rbsah0/rbsah0.fa.Contig8	614	278	412	144978416	144978282	146308819	 117	8e-24	116/135	85	8
# rbsah0/rbsah0.fa.Contig8	614	475	584	144978221	144978112	146308819	83.8	1e-13	93/110	84	8

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

my $null = <IN>;
my %contig_mark;
my %contig;
while (my $line = <IN>) {
	chomp $line;
	my @s = split /\t/,$line;
	my $contig = $s[0];
	$contig{$contig} = 5;
	my $chr = $s[-1];
	
	if ($s[4]<$s[5]) {
		$end = $s[5];
		$start = $s[4];
	}
	else {
		$end = $s[4];
		$start = $s[5];
	}
#	print  "$start\t$end\n";
	if (exists $start{$chr}) {
#	print  "$start\t$end\tA\n";
	if ($end>$start{$chr}-150000 && $start<$end{$chr}+150000) {
	${$contig_mark{$chr}}{$contig} = 5; ### 只有可以连起来才计数
		if ($end>$end{$chr}) {
			$end{$chr}=$end;
		}
		if ($start<$start{$chr}) {
			$start{$chr} = $start;
		}
#		print  "$chr\t$start{$chr}\t$end{$chr}B\n";
	}
	}
	else {
	${$contig_mark{$chr}}{$contig} = 5;
		$start{$chr} = $start;
		$end{$chr} = $end;
#		print  "$chr\t$start{$chr}\t$end{$chr}C\n";
	}
}
#print  "X\t$start{X}\tE\n";

my $all_contig_num = scalar keys %contig;
my $hit_chr = "";
my $max_contig_num = 0;
foreach my $key (keys %contig_mark) {
#	print  "$key\n";
	my $contig_num = scalar keys %{$contig_mark{$key}};# 连起来扎堆的contig数目
	if ($contig_num>$max_contig_num) {
		$max_contig_num = $contig_num;
		$hit_chr = $key;
	}
}

 foreach my $chr (keys %start) {
 	my $contig_num = scalar keys %{$contig_mark{$chr}};
 	print  "D\t$chr\t$start{$chr}\t$end{$chr}\t$contig_num\n";
 }


print  "G\t$hit_chr\t$max_contig_num\t$all_contig_num\n";
if ($max_contig_num >$all_contig_num/2) {
	print OUT "$hit_chr\t$start{$hit_chr}\t$end{$hit_chr}\n";
}
else {
	print OUT "Map Pos not certain\n";
}

