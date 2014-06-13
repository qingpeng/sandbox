#!/usr/bin/perl
#用来处理一堆sequence的out文件 提出起始中止位置 提出方向 名字 类型
if (@ARGV<3) {
	print  "programm file_list file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;
open LIST, "$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#bsaa	69070	3497	13590	253	chr1	171660282	171671015	253	214
while (<LIST>) {
	chomp;
	@info=split /\t/,$_;
	$hash{$info[0]}=$info[5];
}

#   24   7.7  0.0  0.0  bsaa_21092112_21138113       1940   1991  (44011) +  AT_rich        Low_complexity      1   52    (0)    1      
while (<IN>) {
	chomp;
	@s=split /\s+/,$_;
	if (!/SW|score/ && $_ ne "") {
		if ($s[0] eq "") {
			$query_name=$s[5];
			@ss = split "_",$query_name;
			$bac_name=$ss[0];
			$start=$ss[1];
			$end=$ss[2];
			$chr_start=$start+$s[6];
			$chr_end=$start+$s[7];
			$direction=$s[9];
			$repeat_name=$s[10];
			$repeat_class=$s[11];
			if ($repeat_class!~/Low_complexity|Simple_repeat|Unknown|rRNA|snRNA|tRNA|SINE\/Alu|Satellite|RNA/) {
				if ($hash{"bsab"} eq "chr3") {
					print OUT "$bac_name\_human\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
				if ($hash{"bsab"} eq "chr20") {
					print OUT "$bac_name\_dog\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
				if ($hash{"bsab"} eq "chr6") {
					print OUT "$bac_name\_mouse\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
			}
		}
		elsif ($_ ne "") {
			$query_name=$s[4];
			@ss = split "_",$query_name;
			$bac_name=$ss[0];
			$start=$ss[1];
			$end=$ss[2];
			$chr_start=$start+$s[5];
			$chr_end=$start+$s[6];
			$direction=$s[8];
			$repeat_name=$s[9];
			$repeat_class=$s[10];
			if ($repeat_class!~/Low_complexity|Simple_repeat|Unknown|rRNA|snRNA|tRNA|SINE\/Alu|Satellite|RNA/) {
				if ($hash{"bsab"} eq "chr3") {
					print OUT "$bac_name\_human\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
				if ($hash{"bsab"} eq "chr20") {
					print OUT "$bac_name\_dog\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
				if ($hash{"bsab"} eq "chr6") {
					print OUT "$bac_name\_mouse\_$hash{$bac_name}\t$chr_start\t$chr_end\t$direction\t$repeat_name\t$repeat_class\n";
				}
			}

		}

	}
	
}