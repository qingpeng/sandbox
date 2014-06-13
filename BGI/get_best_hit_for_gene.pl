#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 统计每个去冗余基因与相应read库中比的最好的 e值以及相应的read_id
# 2004-3-12 14:34
#

# gene_hit.list
#bsaa0	gi|21542117|sp|Q9HBG7|LY9_HUMAN	T-lymphocyte surface antigen Ly-9 precursor (Lymphocyte antigen 9) (Cell-surface molecule Ly-9) (CD229 antigen)
#bsaa0	gi|6678756|ref|NP_032560.1|	lymphocyte antigen 9 [Mus musculus]gi|346884|pir||A46500 Ly-9.2 antigen - mousegi|198932|gb|AAA39468.1| antigen
#bsaa0	gi|9621660|emb|CAC00648.1|	h2B4b act [Homo sapiens]

# blastz.result
#rbsbm0_000412.y1.scf	gi|37543714|ref|XP_292673.3|	94.29	35	2	0	428	324	477	511	1.1e-10	68.17
#rbsbm0_000412.y1.scf	gi|20987640|gb|AAH29794.1|	88.57	35	4	0	428	324	374	408	5.3e-10	65.85
#rbsbm0_000412.y1.scf	gi|22122509|ref|NP_666140.1|	88.57	35	4	0	428	324	374	408	5.3e-10	65.85

if (@ARGV<2) {
	print  "programm (gene_hit.list)  (wm_d.seq.RemoveVector.masked.blastx) out_file\n";
	exit;
}
($gene_list,$blastx_result,$file_out) =@ARGV;

open LIST,"$gene_list" || die"$!";
open IN,"$blastx_result" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	$read_id = $s[0];
	unless (exists $mark{$read_id}) {

	$mark{$read_id}=1;
	@t = split /_/,$read_id;
	$lib_id = $t[0];
	if ($lib_id=~/^r(\S+)/) {
		$lib_id = $1;
	}
	$gene_id =$s[1];
	$e=$s[10];
#	print  "$e\n";
	if (exists ${$min_e{$gene_id}}{$lib_id}) {
	
	if ($e<${$min_e{$gene_id}}{$lib_id}) {
		${$min_e{$gene_id}}{$lib_id}=$e;
		${$min_read_id{$gene_id}}{$lib_id}=$read_id;
	}
	}
	else {
		${$min_e{$gene_id}}{$lib_id}=$e;
		${$min_read_id{$gene_id}}{$lib_id}=$read_id;
	}

	}
}

while (<LIST>) {
	chomp;
	@s = split /\t/,$_;
	$min_e = ${$min_e{$s[1]}}{$s[0]};
	$min_read_id = ${$min_read_id{$s[1]}}{$s[0]};
	print OUT "$s[0]\t$min_e\t$min_read_id\t$s[1]\t$s[2]\n";
}
