#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<1) {
	print  "to transfer 7_xx.in to the format to draw SVG \n programm 7_xx_in \n";
	exit;
}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";

print  "
Type:Rect
Mark:Primers
Color:blue
WithArrow:1
";

while (my $line = <IN>) {
	chomp $line;
	my @fields = split /\t/,$line;
	print  "$fields[1]:$fields[2]:::\n";

}

