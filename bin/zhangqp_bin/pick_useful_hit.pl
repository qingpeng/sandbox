#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从21结果文件中提取 86个基因涉及到的segments 以及比到 基因区域的reads/est
# 2004-9-14 9:57
# 

if (@ARGV<4) {
	print  "programm gene_est_reads.list segments_about_90genes_gt70.list   ge21.out file_out \n";
	exit;
}
($file_list,$file_segments,$file_in,$file_out) =@ARGV;

open LIST,"$file_list" || die"$!";
open SEG,"$file_segments" || die"$!";
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


# segments_about_90genes_gt70.list
# cluster1942_1_Step2_732_841
# rnca14b_h12.y1.abd_8_227
# rnje06c_d23.y1.abd_132_275
# cluster4036_1_Step1_225_367
# rnje06c_d23.y1.abd_324_438
# 


while (<SEG>) {
	chomp;
	$segments{$_} = 5;
}

# ge21.out
# cluster10013_1_Step1_444_644    cluster20805_1_Step1    155     201     238     192     47
# cluster10013_1_Step1_444_644    rlin17_o21r1.y1.abd     24      49      436     461     26
# cluster100151_1_Step1_25_170    dpcxa0_125287.z1.scf    1       146     168     313     146
# cluster100151_1_Step1_25_170    cluster100151_1_Step1   1       146     25      170     146
# cluster100151_1_Step1_25_170    rdpaxb0_055496.y1.scf   1       35      282     248     35

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (exists $segments{$s[0]} && exists $list{$s[1]}) {
		print OUT "$_\n";
	}
}


