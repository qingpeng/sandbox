#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# filter hit_gene in the bac region
#
if (@ARGV<4) {
	print  "programm bac_region_file file_in hit_gene_list other_hit_gene_list \n";
	exit;
}
($region_file,$file_in,$hit_list,$other_list) =@ARGV;
print  "file_in===$file_in\n";
open REGION,"$region_file" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$hit_list" || die"$!";
open OTHER,">$other_list" || die"$!";
while (<REGION>) {
	chomp;
	@s = split /\t/,$_;
	$chr = $s[0];
	$start = $s[1]-50000;
	$end = $s[2]+50000;
}
close REGION;
#print  "$chr\t$start\t$end\n";

# Scaffold000001	19620	12362	12472	734	770	1856	39.3[7]	0.005	18/37	48	gi|10947036|ref|NP_065208.1|[11]	chr8[12]	41528111[13]	41672508[14]	NM_020475
#print  "chr==$chr\tstart==$start\tend===$end\n";
while (<IN>) {
	chomp ;
#	print  "$_\n";
	@s = split /\t/,$_;
#	print  "$s[12]\t$s[13]\t$s[14]\n";
#	exit;
	if ($s[12] eq $chr && $s[13]<$end && $s[14]>$start) {
#		print  "$s[11]!!!!!!!!!!!!!!\n";
		$hit_gene{$s[11]} = 5;
	}
	else {
		$other_hit_gene{$s[11]} = 5;
	}
}
close IN;
foreach my $key (sort keys %hit_gene) {
	print OUT "$key\n";
}
foreach my $key (sort keys %other_hit_gene) {
	print OTHER "$key\n";
}



