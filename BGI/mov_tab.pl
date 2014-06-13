#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use warnings;
use strict;

open I,"chr7_unknown_big_gene_region.fa" || die"$!";
open OUT,">chr7_unknown_big_gene_region.fa.no_tab" || die"$!";
close ;
while (my $line = <I>) {
	if ($line =~/^>/) {
		$line =~s/\t/ /g;
		print OUT "$line";
	}
	else {
		print OUT "$line";
	}
}

