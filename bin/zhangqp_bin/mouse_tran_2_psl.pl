#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm trans_original_file blat_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


my %exon_starts;
my %exon_lengths;
my %exon_all_length;
my %exon_num;
while (<IN>) {
	chomp;
	unless ($_=~/^Chromosome/) {
		@s = split /\t/,$_;
# Chromosome Name	Start Position (bp)	End Position (bp)	Band	Strand	Ensembl Gene ID	Ensembl Transcript ID	Ensembl Exon ID	Exon Start (Chr bp)	Exon End (Chr bp)
# 11_random_NT_081886	12588	38776	(Band)	1	ENSMUSG00000054617.1	ENSMUST00000059489.2	ENSMUSE00000409634.1	13673	13728
		@tran_s =split /\./,$s[6];
		$tran_id = $tran_s[0];
#		print  "$tran_id\n";
		$mark = $s[4];
		$exon_start = $s[8];
		$exon_end = $s[9];

		$chr_name{$tran_id} = "chr".$s[0];
		$chr_start{$tran_id} = $s[1]-1;
		$chr_end{$tran_id} = $s[2];
#		print  "$exon_start\t$exon_end\n";
		$exon_length = $exon_end-$exon_start+1;
		$exon_all_length{$tran_id} = $exon_all_length{$tran_id}+$exon_length;
		$exon_num{$tran_id}++;
		$p_exon_start = $exon_start-1;
		if ($mark eq "1") {
			$chr_strand{$tran_id} = "+";
			$exon_starts{$tran_id} = $exon_starts{$tran_id}.$p_exon_start.",";
			$exon_lengths{$tran_id} = $exon_lengths{$tran_id}.$exon_length.",";
		}
		else {
			$chr_strand{$tran_id} = "-";
			$exon_starts{$tran_id} = $p_exon_start.",".$exon_starts{$tran_id};
			$exon_lengths{$tran_id} = $exon_length.",".$exon_lengths{$tran_id};
		}
	}
}

#@keys = keys %chr_strand;
#print  "@keys\n";

foreach my $tran_id (sort keys %chr_strand) {
	print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$chr_strand{$tran_id}\t$tran_id\t$exon_all_length{$tran_id}\t9999\t9999\t$chr_name{$tran_id}\t9999\t$chr_start{$tran_id}\t$chr_end{$tran_id}\t$exon_num{$tran_id}\t$exon_lengths{$tran_id}\t9999,9999\t$exon_starts{$tran_id}\n";
}

