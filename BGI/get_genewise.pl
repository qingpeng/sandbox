#!/usr/bin/perl
#genewise $Name: wise2-2-0 $ (unreleased release)
#This program is freely distributed under a GPL. See source directory
#Copyright (c) GRL limited: portions of the code are from separate copyright
#
#Query protein:       ENSP00000352956
#Comp Matrix:         blosum62.bla
#Gap open:            12
#Gap extension:       2
#Start/End            default
#Target Sequence      bsah
#Strand:              reverse
#Start/End (protein)  default
#Gene Paras:          human.gf
#Codon Table:         codon.table
#Subs error:          1e-05
#Indel error:         1e-05
#Model splice?        flat
#Model codon bias?    flat
#Model intron bias?   tied
#Null model           syn
#Algorithm            623
#
#genewise output
#Score 63.85 bits over entire alignment
#Scores as bits over a synchronous coding model
#bsah    GeneWise        match   74425   74113   63.85   -       .       bsah-genewise-prediction-1
#bsah    GeneWise        cds     74425   74287   0.00    -       0       bsah-genewise-prediction-1
#bsah    GeneWise        intron  74286   74196   0.00    -       .       bsah-genewise-prediction-1
#bsah    GeneWise        cds     74195   74113   0.00    -       2       bsah-genewise-prediction-1
#ENSP00000352956  264 RLYVGSLHFNITEDMLRGIFEPFGKIDNIVLMKDSDTGRSKGYGFI
#                     R+YV S+H ++++D ++ +FE FGKI +  L +D  TG+ KGYGFI
#                     RIYVASVHQDLSDDDIKSVFEAFGKIKSCTLARDPTTGKHKGYGFI
#bsah          -74425 catggtgccgctgggaaagtggtgaaattacgcgcaagacagtgta
#                     gtatcctaaatcaaatagttactgatacgctcgacccgaaagagtt
#                     cccgtcgcgccgttccgcgtgctcgcaccggtgccgtcgcgctcct


#Gene 1
#Gene 74425 74113
#  Exon 74425 74287 phase 0
#     Supporting 74425 74288 264 309
#  Exon 74195 74113 phase 1
#     Supporting 74193 74113 311 337
#//


if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
		@s=split /\s+/,$_;
		
		if (/^Score.*alignment$/) {
			$score=$s[1];
		}

		elsif (/^Query/) {
			$Query_pep=$s[2];

		}
		elsif (/Gene\s\d+\s\d+/ ) {
			$line=$_;
			$end=$s[2];
		}
		elsif (/Target/){
			$bac_name=$s[2];
		}
		
		elsif (/\s+Exon/) {
		$n++;

		}
		elsif (/\s+Supporting\s\d+\s$end/ ) {
		print OUT "$Query_pep\t$bac_name\t$n\t$score\t$line\n";
		$n=0;
		}
		
	
}

# ∏Ò Ω£∫pep_name	bac_name	blocksize	genewiseScore	gene_start_end