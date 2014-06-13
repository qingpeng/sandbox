#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# calculate GC of fasta file
#  2004-12-27 11:17
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;



open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
$/=">";
my $null = <IN>;# 要特殊处理第一行！

print OUT "ID\tGC_NUM\tLength\tGC\n";
while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];
	
		$seq = join "",@lines;
		$gc_num = ($seq =~ tr/GCgc/GCgc/);
		$length = length ($seq);
		$gc = int($gc_num*100/$length)/100;


		
		print OUT "$id\t$gc_num\t$length\t$gc\n";

}

