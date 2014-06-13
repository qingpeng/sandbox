#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 找到存在正反向关系但是没有聚在一起

if (@ARGV<3) {
	print  "programm scaffold.out.new direction.log.filter out\n";
	exit;
}
($s,$d,$o) =@ARGV;

open S,"$s" || die"$!";
open D,"$d" || die"$!";
open O,">$o" || die"$!";


# Scaffold000001.	31012
# 	1	Contig19. C	1503
# 	1505	Contig42. C	6591
# 	8096	Contig35. U	2579
# 	10675	Contig45. U	4851
# 	15738	Contig30. C	1033

while (<S>) {
	chomp;
	if ($_ =~/^(Scaffold\d+)\./) {
		$scaffold = $1;
	}
	else {
		if ($_ = /.*(Contig\d+)\.\s/) {
			$contig = $1;
			$scaffold{$contig} = $scaffold;
		}
	}
}


# Contig31 R Contig39 R 4: 1861 1841 1654 1909
# Contig33 L Contig22 R 3: 1987 1934 1805
# Contig33 L Contig48 R 1: 1888
# Contig33 R Contig20 R 5: 1942 1979 1989 2104 1898

while (<D>) {
	chomp;
	@s = split /\s/,$_;
	if ($scaffold{$s[0]} ne $scaffold{$s[2]}) {
		print O "$_\n$scaffold{$s[0]}\t$scaffold{$s[2]}\n";
	}
}