#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 转换成oligo在基因组上的坐标
# 2004-8-23 19:20
# 
# step = 10
# 2004-11-17 20:06
# 
if (@ARGV<3) {
	print  "programm  linked.all tableOligo.index  position_file\n";
	exit;
}
($file_linked,$file_index,$file_out) =@ARGV;

open LINKED,"$file_linked" || die"$!";
open INDEX,"$file_index" || die"$!";
open OUT,">$file_out" || die"$!";
# file_index
# 
# @AB005216,17,1
# rdpcxb0_058712.y1.scf_42_171_28
# bda_1355.z1.abd_291_375_6
# rdpcxb0_058712.y1.scf_42_171_16
# dpcxb0_025650.z1.scf_1_131_2
# rdpcxb0_058712.y1.scf_42_171_29
# rdpcxb0_058712.y1.scf_42_171_12
# rdpcxb0_058712.y1.scf_42_171_14
# rdpcxb0_058712.y1.scf_42_171_7
# rdpcxb0_058712.y1.scf_42_171_13
# cluster30814_1_Step2_378_520_10
# bdc_14330.z1.abd_91_638_25_185_26
# cluster30814_1_Step2_147_247_11
# cluster30814_1_Step2_378_520_34


# file_linked
# rill312b_f2.y1.abd to NM_006845_18,44641510,44641624 of NM_006845,1,1 @chr 44641510 -> 44641592 @read 363 -> 445 &direction +
# cluster2791_1_Step1 to NM_004759_9,203989081,203991325 of NM_004759,1,1 @chr 203989610 -> 203990036 @read 374 -> 804 &direction +
# cluster52925_1_Step1 to NM_000779_3,46648084,46648212 of NM_000779,1,1 @chr 46648084 -> 46648181 @read 297 -> 394 &direction +

# 直接根据 基因在基因组上的位置确定 Oligo 在基因组上的位置


while (<LINKED>) {
	chomp;
    if (/(\S+) to \w+\,\d+\,\d+ of (\w+)\,(\w+)\,(\-?1) \@chr (\d+) \-\> (\d+) \@read (\d+) \-\> (\d+) \&direction \S/) {
		my ($readName,$gene,$chr,$gene_direction,$start_in_chr,$end_in_chr,$start_in_read,$end_in_read)=($1,$2,$3,$4,$5,$6,$7,$8);
		$read = $readName."_".$start_in_read."_".$end_in_read;
		if (exists $chr{$read}) {
			print  "twice $read\n";
		}
		$chr{$read} = $chr;
		$gene{$read} = $gene; 
		$gene_direction{$read} = $gene_direction;
		$start_in_chr{$read} = $start_in_chr; # reads在基因组上的坐标
		$end_in_chr{$read} = $end_in_chr;
	}
}

while (<INDEX>) {
	chomp;
	$oligo_name = $_;
	if ($_ =~/^@/) {
		print OUT "$_\n";
	}
	else {
    if (/(.*\_\d+\_\d+)\_(\d+)\_(\d+)\_(\d+)/) {
		$name=$1;
		
		$start_in_segment = $2;
		$oligo_num = $4;
    } elsif (/(.*\_\d+\_\d+)\_(\d+)/) {
		$name=$1;
		$start_in_segment = 1;
		$oligo_num = $2;
    } else {die "check input files\n";}		
	
	$oligo_pos_in_segment = $oligo_num*10+35+$start_in_segment; # step =10 
	if ($gene_direction{$name} eq "1") {
		$oligo = $oligo_pos_in_segment+$start_in_chr{$name}-1;
	}
	else {
		$oligo = $end_in_chr{$name}-$oligo_pos_in_segment+1;# Oligo:中点在基因组上的位置 。。。reads segments 在基因组上的位置
	}
	print OUT "$oligo_name\t$name\t$chr{$name}\t$oligo\t$gene{$name}\t$gene_direction{$name}\t$start_in_chr{$name}\t$end_in_chr{$name}\n";
	}
}
		


