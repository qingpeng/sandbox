#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use Getopt::Long;

my %opts;
GetOptions(\%opts,"o:s","s:s","g:s","r:s","b:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : ligq
	Usage : $0 [options]
		-o		svg file out
		-s		fgenesh result
		-g		genewise
		-r		join bac length file
		-b		bac
USAGE

die $usage unless $opts{"o"}and$opts{"s"}and$opts{"g"}and$opts{"r"}and$opts{"b"};

my $svg_file = $opts{"o"};
my $scaffold_map = $opts{"s"};
my $human_gene = $opts{"g"};
my $region_file = $opts{"r"};
my $bac = $opts{"b"};
my $svg_in = $svg_file.".in";

# chr3	12173309	12300452

open R,"$region_file" || die"$!";
while (<R>) {
	chomp;
	 @s = split /\t/,$_;
	 $length{$s[0]} = $s[1];
}

$length = $length{$bac};

$title = $bac."_length_".$length;

open OUT,">$svg_in" || die"$!";

print OUT "WholeScale:0.5
Long:50000
LongScale:0.075
Unit:5000
UnitDiv:5
ScaleUnit:1000
LineWidth:3
MarkRows:1
Title:$title
Start:0
End:$length
MarkScale:1.5
LMarkScale:1.5



";

print OUT "\nType:Scale\n";


print OUT "
Type:Rect
Mark:Genewise 
Color:blue
WithArrow:1\n";

if(open(IN,$human_gene))
{
	while (<IN>) {
		print OUT $_;
	}
}

print OUT "
Type:Rect
Mark:Fgenesh
Color:red
WithArrow:1\n";

if(open(IN,$scaffold_map))
{
	while (<IN>) {
		print OUT $_;
	}
}


`~/bin/map_svg.pl $svg_in $svg_file`;
print  "Done! \n";





