#!/usr/bin/perl 
#this programme is for marking those peps with a contrary position with bac position
if (@ARGV<4) {
	print  "programm bac_position_list pep_list file_annotation file_mark \n";
	exit;
}
($file_list,$file_in,$file_annotation,$file_mark) =@ARGV;

open LIST,"$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open ANNO,"$file_annotation" || die"$!";
open OUT,">$file_mark"|| die "$!";

while (<LIST>) {
	chomp;
	@s=split /\t/,$_;
	$bac{$s[0]}=$s[1];
}
#>ENSP00000263975 pep:known chromosome:NCBI35:1:26540400:26585656:1 gene:ENSG00000117676 transcript:ENST00000263975
#MPLAQLKEPWPLMELVPLDPENGQTSGEEAGLQPSKDEGVLKEISITHHVKAGSEKADPS


while (<IN>) {
	chomp ;
	my @s=split /\s/,$_;
	if ($s[0]=~/>(ENSP\S+)/) {
		$name=$1;
	}
	$status=$s[1];
	if ($s[2]=~/chromosome:(\w+):(\d+)\S+/) {
		$position=$2;

	}
	if ($s[3]=~/gene:(\w+)/) {
		$gene_id=$1;
	}
	if ($s[4]=~/transcript:(\w+)/) {
		$transcript_id=$1;
	}
	push @{$pep{$name}},$position;
	push @{$pep{$name}},$gene_id;
	push @{$pep{$name}},$transcript_id; 


}
#ENSP00000342921	bsaa	407.32	Block:	7	Gene 851 13571 [pseudogene]
#ENSP00000249750	bsac	568.85	Block:	11	Gene 61589 90521 [pseudogene]
#ENSP00000261733	bsac	498.41	Block:	11	Gene 61589 90521 [pseudogene]
#ENSP00000297785	bsac	556.11	Block:	12	Gene 61589 90521 [pseudogene]

while (<ANNO>) {
	chomp;
	@s=split /\t/,$_;
	$pep_name=$s[0];
	$bac_name=$s[1];
	
	if (${$pep{$pep_name}}[0] eq $bac{$bac_name}) {
		print OUT "\t$_\t${$pep{$pep_name}}[1]\t${$pep{$pep_name}}[2]\n";
	}
	else{
		print OUT "\-\>\t$_\t${$pep{$pep_name}}[1]\t${$pep{$pep_name}}[2]\n";
	}

}