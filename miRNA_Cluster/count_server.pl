#!/usr/bin/perl -w
use strict;
# 只看负链比上
# 2006-3-16 13:30
# 
open CLUSTER,"HSbrain.txt";
#open GENE,"Human_cluster.id.test";
open GENE,"Human_cluster.id";
#open IN,"human_YinYang_exon_split.fa.blastn8";
open IN,"human_YinYang_exon.fa.all.blastn8";
#open IN,"human_YinYang_exon.fa.join.split.blastn8";
open OUT,">count.out.all";
open OUT2,">count.out.summary.all";
open OUT3,">segment_number.list.all";


my %cluster;
#971	1
#983	1
#988	1
#990	1
while (<CLUSTER>) {
	chomp;
	my @s = split /\t/,$_;
	$cluster{$s[0]} = $s[1];
}




#997	NM_004359
#9972	NM_005124
#9984	NM_005131

my %cluster2;
while (<GENE>) {
	chomp;
	my @s = split /\t/,$_;
	if ($cluster{$s[0]} == 1) {
		$cluster2{$s[1]} = "Yang";
	}
	else {
		$cluster2{$s[1]} = "Yin";
	}
}

my $exon_gene;
my $intron_gene;
my %mark;


while (<IN>) {
	chomp;
	my @s = split /\t/,$_;
# hg17_refGene_NM_015017_24_468	hg17_refGene_NM_001293_4	100.00	22	0	0	1	22	932	953	2e-05	44.1

# joint exon result
# NM_004162_4__5_14	hg17_refGene_NM_006422_2	100.00	22	0	0	1	22	2636	2657	2e-05	44.1
if ($s[8]>$s[9]) { # negetive chain 

	if ($s[0] =~/hg17_refGene_(NM_\d+)_\d+_\d+/) {
		$exon_gene = $1;
	}
	if ($s[0] =~/(NM_\d+)_\d+__\d+_\d+/) {
		$exon_gene = $1;
	}
	if ($s[1] =~/hg17_refGene_(NM_\d+)_\d+/) {
		$intron_gene = $1;
	}
	$mark{$intron_gene}->{$exon_gene}++;
}

}

print OUT "Intron\tCluster\t";

print OUT2 "Intron\tCluster\t";
foreach my $gene (sort keys %cluster2) {
	print OUT "$gene\t";
}
print OUT "Yang\tYang_%\tYin\tYin_%\n";


print OUT2 "Yang\tYang_%\tYin\tYin_%\n";

foreach my $intron (sort keys %cluster2) {
	print OUT "$intron\t$cluster2{$intron}";
	print OUT2 "$intron\t$cluster2{$intron}";
	my %number;
	foreach my $exon (sort keys %cluster2) {
		if (exists $mark{$intron}->{$exon}) {
			print OUT "\t$mark{$intron}->{$exon}";
			print OUT3 "$mark{$intron}->{$exon}\n"; # 打印出所有不为0的segment个数
			if ($cluster2{$exon} eq "Yang") {
				$number{yang}++;				
			}
			else {
				$number{yin}++;
			}
		}
		else {
			print OUT "\t0";
		}
	}
	unless (exists $number{yang}) {
		$number{yang} = 0;
	}
	unless (exists $number{yin}) {
		$number{yin} = 0;
	}

	my $all = $number{yang}+$number{yin};
	my $yang_percent;
	my $yin_percent;
	if ($all>0) {
		$yang_percent = int($number{yang}*1000/$all)/10;
		$yin_percent = int($number{yin}*1000/$all)/10;
	}
	else {
		$yang_percent = 0;
		$yin_percent = 0;
	}

	print OUT "\t$number{yang}\t$yang_percent\t$number{yin}\t$yin_percent\n";
	print OUT2 "\t$number{yang}\t$yang_percent\t$number{yin}\t$yin_percent\n";
}


