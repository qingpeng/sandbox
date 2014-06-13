#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 一般截取序列，不考虑方向

if (@ARGV<2) {
	print  "programm pos_file chr7_file out_put_file\n";
	exit;
}
my ($pos_file,$fasta_file,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

open FASTA,"$fasta_file" || die"$!";


$/=">";
my $null = <FASTA>;
while (my $block = <FASTA>) {
	chomp $block;
	my @lines = split /\n/,$block;
#	print  "@lines\n";
	my $title = shift @lines;
	$seq = join "",@lines;
	
}
#print  "over!\n";
#print  "$seq\n";
#	7_0 8535737-10717598 2181862

$/="\n";
open POS,"$pos_file" || die"$!";
while (my $line = <POS>) {
	chomp $line;
	my @fields = split /\s/,$line;
	my $name = $fields[0];
	print  "$name\n";
	@s = split /-/,$fields[1];
	$start = $s[0];
	print  "start=$start\t";
	$end = $s[1];
	print  "end=$end\n";
	$length = $end-$start+1;
	my $sub_seq = substr $seq,$start-1,$length;
	print OUT ">$name"." $start"."_$end\n";
	$sub_seq =~ s/(.{50})/$1\n/ig;
	print OUT "$sub_seq\n";
}
