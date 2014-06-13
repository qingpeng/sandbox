#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm file_blastz file_out \n";
	exit;
}
($file_blastz,$file_out) =@ARGV;

open REF,"$file_blastz" || die"$!";
open OUT,">$file_out" || die"$!";

while (<REF>) {
	chomp;
	unless ($_=~/^query/) {
	
# rbsbm0_000413_y1_scf	17	+	6966	249	564	37780177	37780412
	@s = split /\t/,$_;
	$read_id = $s[0];
	$chr = $s[1];
	$chr_name="chr".$chr;
	$chr_strand = $s[2];
	$chr_start = $s[6]-1;
	$chr_end = $s[7];
	
	$exon_num = 1;
	$exon_length = $chr_end-$chr_start;
	$exon_lengths = $exon_length.",";
	$exon_starts = $chr_start.",";
	print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$chr_strand\t$read_id\t$exon_length\t9999\t9999\t$chr_name\t9999\t$chr_start\t$chr_end\t$exon_num\t$exon_lengths\t9999,9999\t$exon_starts\n";

	}
}
