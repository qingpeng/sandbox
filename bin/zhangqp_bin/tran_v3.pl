#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# for Data13 !
# 2004-7-16 9:38
# 仅仅输出到不同的文件中去，直接输出
# 2004-7-18 14:51
# 

if (@ARGV<3) {
	print  "programm table est_pos_out reads_pos_out \n";
	exit;
}
($file_in,$est_out,$read_out) =@ARGV;

open IN,"$file_in" || die"$!";
open EST,">$est_out" || die"$!";
open READ,">$read_out" || die"$!";
# 输入
# @ENSG00000000003,X,-1
# >ENSE00000401072,98659339,98659422
# cluster379_-5_Step2,est 262     344     -
# cluster379_-8_Step2,est 482     544     -
# cluster379_-6_Step2,est 607     689     -
# cluster379_2_Step2,est  1603    1685    -
# >ENSE00000673407,98660259,98660393

# 输出
# dpcxa0_123684.z1.scf    258     411     -       1
# bda_96642.z1.abd        246     418     -       1
# rdpbxa0_198590.y1.scf   1       237     -       -1
# byd_87476.z1.abd        1       113     -       -1
# dpbxa0_098952.z1.scf    81      275     +       -1
# rcpg0_141475.y1.abd     461     633     +       -1
# rdpcxa0_043560.y1.scf   373     463     -       -1

while (<IN>) {
	chomp;
	unless ( $_=~/^>/) {
		if ($_=~/^@/) {
			@s = split /,/,$_;
			$gene_direction = $s[2];
		}
		else {
			
		@s = split /\t/,$_;
		$mark = $s[3];

		@t = split ",",$s[0];
		if ($t[1] eq "est") { # 只是输出到不同的文件中 内容没有区别
			print EST "$t[0]\t$s[1]\t$s[2]\t$mark\t$gene_direction\n";
		}
		else { # if genome/reads, depend on the mapping direction and the gene direction
			print READ "$t[0]\t$s[1]\t$s[2]\t$mark\t$gene_direction\n";
		}
		}
	}
}




