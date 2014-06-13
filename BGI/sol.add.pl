#!/usr/bin/perl
#用来提取sol结果中subject 和 query的block length的总和
#query_name query_length query_start query_end query_blocks_length subject_name subject_start subject_end subject_blocks_length match_bases
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#bsbk	55823	2146	48767	-	chr4	90634903	87777417	87791468	2	133	2146,2238;48717,48767;	87791468,87791377;87777467,87777417;	-84;-49;

while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	$bac_name=$s[0];
	$chr_name=$s[5];
	$match_bace=$s[10];
	@bac_blocks=split ";",$s[11];
	@chr_blocks=split ";",$s[12];
#	print $bac_blocks[0];
	for ($n=0;$n<@bac_blocks ;$n++) {
		@tmp=split ",",$bac_blocks[$n];
		@temp=split ",",$chr_blocks[$n];
		$bac_block_size[$n]=abs ($tmp[1]-$tmp[0]);
		$chr_block_size[$n]=abs ($temp[1]-$temp[0]);
		$bac_block+=$bac_block_size[$n];
		$chr_block+=$chr_block_size[$n];

	}
	print OUT "$bac_name\t$s[1]\t$s[2]\t$s[3]\t$bac_block\t$chr_name\t$s[7]\t$s[8]\t$chr_block\t$match_bace\n";
	$bac_block=0;
	$chr_block=0;

}