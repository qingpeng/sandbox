#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<3) {
	print  "programm transcript_table exon_table file_out \n";
	exit;
}
($file_transcript,$file_exon,$file_out) =@ARGV;

open TR,"$file_transcript" || die"$!";
open EXON,"$file_exon" || die"$!";
open OUT,">$file_out" || die"$!";

while (<EXON>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[1] eq "core") {
	
	$exon_id = $s[2];
	$exon_start = $s[6];
	$exon_end = $s[7];
	$exon_start{$exon_id} = $exon_start-1;
	$exon_length{$exon_id} = $exon_end-$exon_start+1;

	}
}

while (<TR>) {
	chomp;
#	1	core	ensembl	ensembl	15630	ENST00000322424	1	2	72266542	72267558	1	72266542	72267558	15630	ENSP00000315660	1	11571	ENSG00000178455	1	1017	111605			
	@s = split /\t/,$_;
if ($s[1] eq "core") {

	$tr_name = $s[5];
	$chr = $s[7];
	$chr_name = "chr".$chr;
	$strand = $s[10];
	if ($strand eq "1") {
		$chr_strand = "+";
	}
	else {
		$chr_strand = "-";
	}
	$chr_start = $s[8]-1;
	$chr_end = $s[9];
	$exon_ids = $s[20];
	@exons = split  ":",$exon_ids;
	$exon_lengths = "";
	$exon_starts = "";
	$exon_all_length = 0;
	for (my $k = 0;$k<scalar @exons;$k++) {
		$exon_lengths = $exon_lengths.$exon_length{$exons[$k]}.",";
		$exon_all_length = $exon_all_length+$exon_length{$exons[$k]};
		$exon_starts = $exon_starts.$exon_start{$exons[$k]}.",";
	}
	$exon_num = scalar @exons;
	print OUT "9999\t0\t0\t0\t0\t0\t0\t0\t$chr_strand\t$tr_name\t$exon_all_length\t9999\t9999\t$chr_name\t9999\t$chr_start\t$chr_end\t$exon_num\t$exon_lengths\t9999,9999\t$exon_starts\n";

}

}