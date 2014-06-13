#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#last modified: 9/22/2003 11:58 AM 修正了xunit大小，注意取bin最好0.002/0.003 
#last modified:2003-9-24 22:43 修正了median 算法 增加species name 参数 增加作图-p 
#last modified: 2003-9-26 23:51 修正了median 取三位小数
#v1.1 2003-12-2 9:35 最后修改

# 输入文件：
# 一列排列的GC值

#0.4
#0.401
#0.398
#0.4
#0.399
#0.402
#0.311
#0.397
#0.445
#0.358
#0.288
#0.323
#0.442
#0.374
#0.408
#0.401
#0.33
#0.303
#0.366
#0.336
#....

# 输出文件
# .svg 
# .txt 作图用，可以进一步修改

# 例子：
#
# perl plot_gc_genome_v1.1.pl -i fruitfly.fa.gc1000 -b 0.003 -o fruit.svg -n Fruitfly -ob 1-Kb
#
#


use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","b:s","o:s","n:s","ob:s");
my $ver = "1.1";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Discription: Draw GC content distribution 
	Contact : zhangqp
	Usage : $0 [options]
		-i		file in （一列GC值）
		-b		bin
		-o		svg file name
		-n		species name
		-ob		bin  （500-bp  10-Kb） while calculating GC in genome
USAGE

die $usage unless $opts{"i"}and$opts{"b"}and$opts{"o"}and$opts{"n"}and$opts{"ob"};


my $bin = $opts{b};
my $file_in = $opts{i};
my $file_out = $opts{o};
my $species_name = $opts{n};
my $old_bin = $opts{ob};

my @number;
open IN,"$file_in" || die"can't open $file_in:$!";


my $min =0;
my $max =0;
my $count = 0;
my $sum = 0;
while (my $line = <IN>) {
	chomp $line;
	$count++;
	$sum = $sum +$line;
	my $locate =int( $line/$bin*1.00001);
	$number[$locate]++;
}
close (IN);

open INPUT,"$file_in" || die"can't open $file_in:$!";

my @lines = <INPUT>;
my $median = &define_median(@lines);#算中位数
 $median =  sprintf "%5.3f",$median;
print  "sum==$sum\tcount==$count\n";
my $mean = sprintf "%5.3f",$sum/$count;#算平均数

my $y_end;
my $y_step;
my $draw_number_txt = $file_out.".txt";

# number
open TXT,">$draw_number_txt" || die"$!";

my @sorted_y=sort{$a<=>$b}@number;
my $y_length = $sorted_y[-1];
my $y_length_ever = $y_length;
if ($y_length>1000) {
	 $y_length = $y_length/1000;####################################  Y__max
}
	 ($y_end,$y_step) = &define_axis($y_length);#确定作图时坐标

#my $x_unit = $bin *0.9;
my $x_unit = $bin;
my $y_note;
if ($y_length_ever>1000) { #确定作图中的Mark
	$y_note = "# of bins, X1000 ";
}
else {
	$y_note = "# of bins";
}

#生成作图文件
&put_maphead;

for (my $k = 0;$k< scalar @number;$k++) {
	if ($number[$k]) {
		my $x_num = $k*$bin;
		my $y_num = $number[$k];
		if ($y_length_ever>1000) {
			$y_num = $y_num/1000; #####################################Y_max
		}

	print TXT "$x_num:$y_num\n";
	}
}
close (TXT);
# 作图
print  "drawing....\n";
`perl /disk10/prj0326/zhangqp/bin/distributing_svg.pl  $draw_number_txt  $file_out`;

my $file_out_p = $file_out.".p.svg";
`perl /disk10/prj0326/zhangqp/bin/distributing_svg.pl  $draw_number_txt  $file_out_p -p`;
print  "Done!\n";

#**********************************************************
sub define_median () {#算中位数
	my $median;
	my @array = @_;
	my @sorted=sort{$a<=>$b}@array;
	my $num = scalar @sorted;
	if ($num =~/(1|3|5|7|9)$/) {#如果是奇数个
		$median = $sorted[($num-1)/2];
	}
	else {
		$median = ($sorted[$num/2]+$sorted[($num/2)-1])/2;
	}
	chomp $median;
	return $median;
}



sub define_axis () {
	my $i=0;
	my ($max)=@_;
	my $time=1;
	my @ret=();
	my @limit=(1,2,3,4,5,6,8,10,12,15,16,20,24,25,30,40,50,60,80,100,120);
	my @unlim=(0,1,2,3,4,5,6,8 ,10,11,14,15,18.5,21,23,29,37,47,56,76 ,92 ,110);

	while ($max >$unlim[21]) {
		$max=$max/10;
		$time=$time*10;
	}
	for ($i=0;$i<=20 ;$i++) {
		if ($max>$unlim[$i] && $max<=$unlim[$i+1]) {
			$ret[0]=$limit[$i]*$time;
			
			if ($i==2 || $i==5 || $i==9 || $i==14) {
				$ret[1]=$ret[0]/3;
			}
			elsif ($i==4 || $i==7 || $i==13 || $i==16){
				$ret[1]=$ret[0]/5;
			}
			else {
				$ret[1]=$ret[0]/4;
			}

		}
	}
	return @ret;
}

#*********************************************

sub put_maphead{
print TXT <<"map";
Type:Rect
XUnit:$x_unit
Width:600
Height:450
WholeScale:0.85
X:GC ($old_bin bins)
Y:$y_note
XStart:0
YStart:0
XEnd:1
YEnd:$y_end
XStep:0.2
YStep:$y_step
Note:$species_name
Mark2:
Median=$median
Mean=$mean
:END
Mark2pos:r
Mark2scale:0.85

Color:Blue
Mark:
map
}