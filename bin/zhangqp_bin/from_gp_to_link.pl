#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# generate human NM--Pep relation from GenePep format file:
# 2004-12-16 11:01
# 


if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



# LOCUS       NP_057427               3114 aa            linear   PRI 15-NOV-2004
# DBSOURCE    embl locus HS591N18, accession AL031594.9
# DBSOURCE    REFSEQ: accession NM_016343.3
# DBSOURCE    REFSEQ: accession NM_033108.2
# DBSOURCE    REFSEQ: accession NM_006585.2
# DBSOURCE    REFSEQ: accession NM_002969.3
# DBSOURCE    REFSEQ: accession NM_001072.2


while (<IN>) {
	chomp;
	if ($_=~/LOCUS\s+(\w+)\s*/) {
		$np = $1;
		print  "np==$np\n";
	}
	else {
		if ($_=~/DBSOURCE\s+.*accession\s(\w+)/) {
			$nm = $1;
			if ($nm=~/(\S+)\./) {
				$nm=$1;
			}
				print  "nm==$nm\n";
				print OUT "$nm\t$np\n";
			
		}
	}
}
