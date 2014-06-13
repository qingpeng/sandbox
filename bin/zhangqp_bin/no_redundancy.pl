#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 考虑 复杂情况，直接标记肯定是不行！
# refgene，ensembl分别按长度排序，refgene在前，ensembl在后
# 从第一个起向后依次检查是否有overlap
# 同时进行标记



if (@ARGV<3) {
	print  "programm file_all_psl file_overlap file_out \n";
	exit;
}
($file_psl,$file_overlap,$file_out) =@ARGV;

open PSL,"$file_psl" || die"$!";
open OV,"$file_overlap" || die"$!";

open OUT,">$file_out" || die"$!";


while (<PSL>) {
	chomp;
	@s = split /\t/,$_;
	$id = $s[9];
	if ($id =~/^NM_/) {
		$genomics_size_refgene{$id} = $s[16]-$s[15];
	}
	else {
		$genomics_size_ensembl{$id} = $s[16]-$s[15];
	}

#	$chr_start = $s[15];
#	$chr_end = $s[16];
#	$genomics_size{$id} = $chr_end-$chr_start;
}

close PSL;

@gene_refgene = keys %genomics_size_refgene;
@sort_gene_refgene = sort {$genomics_size_refgene{$b} <=> $genomics_size_refgene{$a}} @gene_refgene;

@gene_ensembl = keys %genomics_size_ensembl;
@sort_gene_ensembl = sort {$genomics_size_ensembl{$b} <=> $genomics_size_ensembl{$a}} @gene_ensembl;

push @sort_gene_refgene,@sort_gene_ensembl;


#print  "@sort_gene_refgene\n";


while (<OV>) {
	chomp;
	@s = split /\t/,$_;
	$id_a = $s[0];
	$id_b = $s[1];
	unless ($id_a eq $id_b) {
		$new_id_a = $id_a."-".$id_b;
		$new_id_b = $id_b."-".$id_a;
#		print  "$new_id_a\n$new_id_b\n";
		$over{$new_id_a} = 5;
		$over{$new_id_b} = 5;
	}
}

#print  "KK\n";
for (my $k = 0;$k<scalar @sort_gene_refgene;$k++) {
	$id_first = $sort_gene_refgene[$k];
	unless ($mark_remove{$id_first}) {
	
	for (my $kk = $k+1;$kk<scalar @sort_gene_refgene;$kk++) {
		$id_second = $sort_gene_refgene[$kk];
		$join_id = $id_first."-".$id_second;
#		print  "$join_id\n";
		if (exists $over{$join_id}) {
#			print  "$id_second\n";
			$mark_remove{$id_second} = 5;
		}
	}

	}
}








open PSL,"$file_psl" || die"$!";
while (<PSL>) {
	chomp;
	@s = split /\t/,$_;
	$id = $s[9];
	unless (exists $mark_remove{$id}) {
		print OUT "$_\n";
	}
}
