#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从refGene.txt中挑选需要的records
#  2004-12-2 11:01
# 
# LOCUS       NM_001071               1536 bp    mRNA    linear   PRI 09-JAN-2004

if (@ARGV<3) {
	print  "programm to_pick_gene.list refGene.txt file_out \n";
	exit;
}

# TXT
# NM_004793
# NM_006012
# NM_003119
# NM_006796


($file_list,$file_refGene,$file_out) =@ARGV;

open TXT,"$file_list" || die"$!";
open REFGENE,"$file_refGene" || die"$!";
open OUT,">$file_out" || die"$!";


$all_id ="";
while (<TXT>) {
	chomp;
		$id = $_;
		$all_id = $all_id."  ".$id;
	
}

while (<REFGENE>) {
	chomp;
	@s = split /\t/,$_;
	$ref_id = $s[0];
	if ($all_id =~/\s\s$ref_id/) {
		print OUT "$_\n";
	}
}


