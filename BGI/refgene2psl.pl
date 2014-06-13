#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm file_refgene file_out \n";
	exit;
}
($file_refgene,$file_out) =@ARGV;

open REF,"$file_refgene" || die"$!";
open OUT,">$file_out" || die"$!";

while (<REF>) {
	chomp;
#	NM_024796	chr1	-	801449	802749	801942	802434	1	801449,	802749,
	@s = split /\t/,$_;
	$refgene_id = $s[0];
	$chr_name = $s[1];
	$chr_strand = $s[2];
	$chr_start = $s[3];
	$chr_end = $s[4];
	$exon_num = $s[7];
	$exon_starts = $s[8];
	@exon_start = split ",",$exon_starts;
	$exon_ends= $s[9];
	@exon_end = split ",",$exon_ends;
	$exon_lengths = "";
	$exon_all_length = 0;
	for ($k = 0;$k<scalar @exon_start;$k++) {
		$exon_length = $exon_end[$k]-$exon_start[$k];
		$exon_lengths = $exon_lengths.$exon_length.",";
		$exon_all_length = $exon_all_length+$exon_length;
	}
	print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$chr_strand\t$refgene_id\t$exon_all_length\t9999\t9999\t$chr_name\t9999\t$chr_start\t$chr_end\t$exon_num\t$exon_lengths\t9999,9999\t$exon_starts\n";

}
