#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 在“>”行上注明和哪条人的基因同源？
# 2005-4-5 17:13
# 
if (@ARGV<4) {
	print  "programm link_direct link_other file_in file_out \n";
	exit;
}
($file_direct,$file_other,$file_in,$file_out) =@ARGV;

open DIRECT,"$file_direct" || die"$!";
open OTHER,"$file_other" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#
#NM_004793	N/A
#NM_006012	 NM_017393 
#NM_003119	 NM_153176 
#NM_139312	N/A
#NM_006796	N/A
#NM_004083	 NM_007837 
#NM_005194	 NM_009883 
#NM_006708	N/A

while (<DIRECT>) {
	chomp;
	@s = split /\t/,$_;
	$mouse = $s[1];
	$mouse =~s/\s//g;
	$human{$mouse} =$s[0];
}


#AB005216	BAA22432	NP_619598	NM_138657
#AB006589	BAA31966	NP_034287	NM_010157
#AB023191	BAA76818	NP_759011	NM_172379
#AB023420	BAA75062	NP_032326	NM_008300
#AC005393	AAC28914	NP_034222	NM_010092
#AF022375	AAC63143	NP_033531	NM_009505
#AF042838	AAC97073	NP_036075	NM_011945
#
while (<OTHER>) {
	chomp;
	@s =split/\t/,$_;
	$human{$s[3]} = $s[0];
}


#>gi|31982521|ref|NM_007383.2| Mus musculus acyl-Coenzyme A dehydrogenase, short chain (Acads), mRNA
#GGAACTCCAGAGCTGCTGCAGGAGGTCCTGGAGGTCTGTGCCCATGGCTGCCGCCTTGCTCGCCCGGGCC
#CGTGGCCCTCTCCGTAGAGCTCTCGGTGTTCGGGACTGGCGACGGTTACACACTGTTTACCAGTCTGTGG
#AGCTGCCTGAGACACACCAGATGTTGCGTCAGACATGCCGTGACTTTGCCGAGAAGGAGTTGGTCCCCAT


while (<IN>) {
	chomp;
	if ($_ =~/^>gi\|\d+\|\w+\|(\S+)\./) {
		$human_gene = $human{$1};
		if ($_ =~/(\S+)\s(.*)/) {
			print OUT "$1 human_gene:$human_gene $2\n";
		}
	}
	else {
		print OUT "$_\n";
	}
}

