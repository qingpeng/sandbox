#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# ÐÞ¸Ä ´¦Àír 
if (@ARGV<3) {
	print  "programm file_in(blastx result) read_file file_out \n";
	exit;
}
($file_in,$read_file,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open R,"$read_file" || die"$!";

while (<R>) {
	chomp;
	if ($_ =~/^>(\S+)\s/) {
		$name = $1;
		@t = split /_/,$name;
		$lib_name=$t[0];
		if ($lib_name=~/^r(\w+)/) {
			$lib_name=$1;
		}

		$num{$lib_name}++;
	}
}


while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	@ss = split /_/,$s[0];
	$lib = $ss[0];
		if ($lib=~/^r(\w+)/) {
			$lib=$1;
		}
	${$reads{$lib}}{$s[0]} = 1;
	${$pep{$lib}}{$s[1]} = 1;


}
print  keys %reads;
foreach my $lib (sort keys %reads) {
#	print keys %{$reads{$;
	$reads_hit = scalar keys %{$reads{$lib}};
	$pep_hit = scalar keys %{$pep{$lib}};
	$all_reads = $num{$lib};
	print OUT "$lib\t$all_reads\t$reads_hit\t$pep_hit\n";
}

