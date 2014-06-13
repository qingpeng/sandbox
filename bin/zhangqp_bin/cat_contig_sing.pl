#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# cat ���е�contig ���У��Լ�singlets����
#
($list,$contig_file,$singlet_file)= @ARGV;

open LIST,"$list" || die"$!";
open C,">$contig_file" || die"$!";
open S,">$singlet_file" || die"$!";

while (my $line = <LIST>) {
	chomp $line ;
	$contig = "$line/$line.fa.contigs";
	$singlet = "$line/$line.fa.singlets";

	open IN,"$contig" || die"$!";
	while (<IN>) {
		print C "$_";
	}
	close IN;
	open IN,"$singlet" || die"$!";
	while (<IN>) {
		print S "$_";
	}
	close IN;
}
close LIST;


