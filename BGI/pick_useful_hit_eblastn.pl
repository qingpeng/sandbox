#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从eblastn 结果文件中提取 比到 基因区域的reads/est的hit
# 2004-9-15 16:14
# 注意与另一个pick_useful_hit.pl不一样，那一个是处理21bp的结果文件

if (@ARGV<3) {
	print  "programm gene_est_reads.list  eblastn_out file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open LIST,"$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

# gene_est_reads.list
# AF045451	cluster272006_1_Step1 dpbxa0_189688.z1.scf dpbxa0_118925.z1.scf cluster3952_-2_Step1 rdpaxb0_053150.y1.scf cluster299742_1_Step1 cluster3952_1_Step1 bd_68080.z1.abd rblb_3644.y1.abd rbdf_36936.y1.abd blb_3644.z1.abd cluster45957_1_Step1
# AF055270	cluster353_-8_Step5 cluster353_-5_Step5 rlnt12c_p20.y1.abd rbdd_86431.y1.abd cluster353_-4_Step5 rtra25_e17r1.y1.abd rdbla0127_n8.y1.abd rlin09_k6.y1.abd cluster353_3_Step5 cluster353_-7_Step5 cluster353_6_Step5 cluster353_2_Step5 blb_25679.z1.abd reje17b_n16.y1.abd rcsk07_d12.y1.abd rpigca0_000238.y1.abd cluster353_1_Step5 rret12_j20.y1.abd rpliv0110_f15.y1.abd

while (<LIST>) {
#	print  "$_\n";
	chomp;
	@s = split /\t/,$_;
#	print  "$s[1]\n";
	@ss = split /\s+/,$s[1];
	foreach my $ss (@ss) {
		$list{$ss} = 5;
	}
}


# bd_34584.z1.abd_17_368_14       70      23      39      191     207     555     34.2    4.4     17/17   100     rbdg_37941.y1.abd
# bd_34584.z1.abd_17_368_14       70      23      39      13      29      302     34.2    4.4     17/17   100     bdf_69441.z1.abd
# bd_34584.z1.abd_17_368_14       70      23      39      22      38      312     34.2    4.4     17/17   100     bdf_86378.z1.abd


while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (exists $list{$s[-1]}) {
		print OUT "$_\n";
	}
}


