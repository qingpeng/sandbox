#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# MODIFIED  2004-3-10 20:17
# ��ȥ�������pep �ļ��������ʽ��������ÿ��reads����ϵ�pep ���������
#

open IN,"all.nr" || die"$!";
open OUT,">gene_hit.list" || die"$!";
open LOG,">gene_hit_num.list" || die"$!";

while (<IN>) {
	chomp;
	@s =split /\t/,$_;
	@t = split /\./,$s[0];
	$db = $t[0];
		if ($db=~/^r(\w+)/) {
			$db=$1;
		}
	$s2 = $s[1];
	if ($s2=~/^>(\S+)\s+(.*)/) {
		$gene_id = $1;
		$gene_com = $2;
	}
	$num{$db}++;
	print OUT "$db\t$gene_id\t$gene_com\n";
}

foreach my $key (sort keys %num) {
	print LOG "$key\t$num{$key}\n";
}
