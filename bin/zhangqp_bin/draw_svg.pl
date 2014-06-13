#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm gene_name file_cdna file_scaffold file_svg file_length \n";
	exit;
}
($gene_name,$file_cdna,$file_scaffold,$file_svg,$file_length) =@ARGV;

open LENGTH,"$file_length" || die"$!";


while (<LENGTH>) {
	chomp;
	@s = split /\t/,$_;
	$length{$s[0]}=$s[1];

}

$length = $length{$gene_name};

$svg_in = $file_svg.".txt";
open OUT,">$svg_in" || die"$!";

print OUT "WholeScale:0.5
Long:50000
LongScale:0.075
Unit:5000
UnitDiv:5
ScaleUnit:1000
LineWidth:3
MarkRows:1
Title:Gene:$gene_name
Start:0
End:$length
MarkScale:1.5
LMarkScale:1.5



";

print OUT "\nType:Scale\n";


print OUT "
Type:Rect
Mark:Gene_Sequence 
Color:Orange\n";
$out = "1:".$length.":::Gene_Sequence";
print OUT "$out\n\n";




print OUT "
Type:Rect
Mark:cDNA 
Color:blue
WithArrow:1\n";



if(open(CDNA,$file_cdna))
{
	while (<CDNA>) {
		print OUT "$_";
	}
}


print OUT "
Type:Rect
Mark:Scaffold 
Color:Red
WithArrow:1\n";



if(open(SCA,$file_scaffold))
{
	while (<SCA>) {
		print OUT "$_";
	}
}




`~/bin/map_svg.pl $svg_in $file_svg`;
print  "Done! \n";






