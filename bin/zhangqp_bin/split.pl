#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#
# split list by reads database
#  2004-4-28 20:49 ¿¼ÂÇ·´Ïò È¥x 
print  "perl .... fasta_in qual_in\n";
($fasta_in,$qual_in)=@ARGV;
open IN,"$fasta_in" || die"$!";


while (<IN>) {
	chomp ;
	if ($_=~/^>(\S+)\s+/) {
		$id = $1;
# bsaax0_000101.z1.scf
# rbsbh0_000183.y1.scf
		@s = split /0_/,$id;
		$bac = $s[0];
		if ($bac =~/r(.+)/) {
			$bac = $1;
		}
			if ($bac =~/(\w\w\w\w)x/) {
				$bac = $1;
			}

		unless ($mark{$bac}==5) {
		print  "$id\n";
			print  "mkdir $bac\n";
			`mkdir $bac`;
			$mark{$bac}=5;
		}
		$file_out = $bac."/".$bac.".fa";
		open OUT,">>$file_out" || die"$!";
		print OUT "$_\n";
	}
	else {
		print OUT "$_\n";
	}
}
close IN;

open IN,"$qual_in" || die"$!";


while (<IN>) {
	chomp ;
	if ($_=~/^>(\S+)\s+/) {
		$id = $1;
		@s = split /0_/,$id;
		$bac = $s[0];
		if ($bac =~/r(.+)/) {
			$bac = $1;
		}
			if ($bac =~/(.*)x/) {
				$bac = $1;
			}
		$file_out = $bac."/".$bac.".fa.qual";
		open OUT,">>$file_out" || die"$!";
		print OUT "$_\n";
	}
	else {
		print OUT "$_\n";
	}
}
close IN;


