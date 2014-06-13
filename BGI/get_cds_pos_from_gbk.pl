#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# get the cds pos from gbk file
# 2004-9-17 16:56
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#             mitochondrial protein, mRNA.
# ACCESSION   NM_004793
# VERSION     NM_004793.2  GI:21396488

#      CDS             34..2913
# LOCUS       NM_003119               3096 bp    mRNA    linear   PRI 23-AUG-2004
#      source          1..1953

while (<IN>) {
	chomp;
	if ($_ =~/^ACCESSION   (\S+)\s?/) {
		$gene = $1;
		print  "$gene\n";
		print OUT "\n$gene";
	}
	elsif ($_ =~/^     source          (\d+)..(\d+)/) {
		$mrna_start = $1;
		$mrna_end = $2;
		print OUT "\t$mrna_start\t$mrna_end";
	}
	elsif ($_ =~/^     CDS             <?(\d+)..(\d+)/) {
		$cds_start = $1;
		$cds_end = $2;
		print OUT "\t$cds_start\t$cds_end";
	}
	else {
		
	}
}


