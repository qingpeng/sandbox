#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 
# 考虑两种情况
# 2004-6-7 17:38
# 增加算百分比分布 
# # 修正每一个横坐标都画出来，哪怕是0
# 2004-6-1417:54
# 


use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","b:s","o:s","x:s","y:s","n:s","t:s","x_z:s","y_z:s","l:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-i		file in 
		-b		bin (default 1 )
		-o		output svg file 
		-x		x note
		-y		y note
		-n		note
		-t		cumulate/count/percent
		-x_z		x_zoom (default 1)(1000,1000000 preferred)
		-y_z		y_zoom (default 1)(1000,1000000 preferred)
		-l		log yes/no (default no)
USAGE

die $usage unless $opts{"i"}and$opts{"o"}and$opts{"x"}and$opts{"y"}and$opts{"n"}and$opts{"t"};
die $usage if (exists($opts{b}) and $opts{b} < 1);



my $file_in = $opts{i};
my $file_out = $opts{o};
my $x_note = $opts{x};
my $y_note = $opts{y};
my $note = $opts{n};
my $type = $opts{t};

my $bin   = exists($opts{b}) ? $opts{b} : 1;
my $x_z   = exists($opts{x_z}) ? $opts{x_z} : 1;
my $y_z   = exists($opts{y_z}) ? $opts{y_z} : 1;
my $log   = exists($opts{l}) ? $opts{l} : "no";

print  "log ==$log\n";


my @number;
my $draw_number_txt = $file_out.".txt";
open TXT,">$draw_number_txt" || die"$!";

print  "file_In==$file_in\n";
print  "bin=$bin\n";

my @all_x_y;

my $figure_type;
#############生成x-y坐标 ### bin在子程序中处理
if ($type eq "cumulate") {
	$figure_type = "Line";
	 @all_x_y = &cumulate($file_in,$bin);
}
elsif ($type eq "count") {
	$figure_type = "Rect";
	 @all_x_y = &count($file_in,$bin);
}
elsif ($type eq "percent") {
	$figure_type = "Line";
	@all_x_y = &percent($file_in,$bin);
}


#print  "@all_x_y\n";
print  "$type .... over!\n";


# 有多少点画多少点 

my $y_end;
my $y_step;
my $x_length = (scalar @all_x_y);
my $final_x_length = $x_length/$x_z;
if ($log eq "yes") {
	$final_x_length = log($final_x_length)/log (10);
}

#print  "$final_x_length\n";
my ($x_end,$x_step) = &define_axis($final_x_length);
#print  "$x_end\t$x_step\n";
my @sorted_y=sort{$a<=>$b}@all_x_y;
 my $y_length = $sorted_y[-1];
 my $final_y_length = $y_length/$y_z;
($y_end,$y_step) = &define_axis($final_y_length);

my $xunit = $x_end/200;

if ($figure_type eq "Line") {
	$xunit = "";
}

if ($bin != 1) {
	$x_note=$x_note."(bin=$bin)";
}



  if ($log eq "yes") {
  	$x_note = $x_note."(Log)";
  }
  if ($x_z != 1) {
  	if ($x_z == 1000) {
  		$x_note = $x_note." (x 1K)";
  	}
  	elsif ($x_z == 1000000) {
  		$x_note = $x_note." (x 1M)";
  	}
  	else {
  		$x_note = $x_note." (x $x_z)";
  	}
  }
  
  if ($y_z != 1) {
  	if ($y_z == 1000) {
  		$y_note = $y_note." (x 1K)";
  	}
  	elsif ($y_z == 1000000) {
  		$y_note = $y_note." (x 1M)";
  	}
  	else {
  		$y_note = $y_note." (x $x_z)";
  	}
  }






&put_maphead;

my $print_x;
my $print_y;
#print  "x_length=$x_length\n";
for (my $k = 0;$k< $x_length+1;$k=$k+$bin) {
#	print  "$k\t$all_x_y[$k]aaa\n";
#	if ($all_x_y[$k]) {
		$print_x = $k/$x_z;
		if ($log eq "yes") {
			$print_x = log($print_x)/log(10);
		}
		$print_y = $all_x_y[$k]/$y_z;
#		print  "$all_x_y[$k]\t$print_y\n";
	print TXT "$print_x:$print_y\n";
#	}
}
close (TXT);






print  "drawing....\n";
`perl /disk10/prj0326/zhangqp/bin/distributing_svg.pl  $draw_number_txt  $file_out`;

my $file_out_p = $file_out.".p.svg";
`perl /disk10/prj0326/zhangqp/bin/distributing_svg.pl  $draw_number_txt  $file_out_p -p`;
print  "Done!\n";




sub put_maphead{
print TXT <<"map";
Type:$figure_type
XUnit:$xunit
Width:600
Height:450
WholeScale:0.85
X:$x_note
Y:$y_note
XStart:0
YStart:0
XEnd:$x_end
YEnd:$y_end
XStep:$x_step
YStep:$y_step
Note:$note

Color:Blue
Mark:
map
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



sub cumulate{
	# input:
	# 2
	# 4
	# 2
	# 6
	# 7
	# output:
	# 0:0
	# 1:0
	# 2:2
	# 3:2
	# 4:6
	# 5:6
	# 6:12
	# 7:19
	# 比横坐标小的累积
	# 2004-6-7 16:53

my ($file_in,$bin) =@_;

my @all_x_y;
print  "$file_in\n";
open IN,"$file_in" || die"$!";

my $max = 0;
my %length;
while (<IN>) {
	chomp;
	$length{$_} = $length{$_}+$_;
	if ($_ >$max) {
		$max = $_;
	}
}

my $length;
for	(my $k = $bin;$k<$max+1;$k=$k+$bin) {
	for (my $kk = $k-$bin+1;$kk<$k+1;$kk++) {
		$length = $length+$length{$kk};
	}
#	print  "$k:$length\n";
	$all_x_y[$k] = $length;
}

return @all_x_y;

}



sub count{
	# input:
	# 2
	# 4
	# 2
	# 6
	# 7
	# output:
	# 0:0
	# 1:0
	# 2:2
	# 3:0
	# 4:1
	# 5:0
	# 6:1
	# 7:1
	# 对每个x计数
	# 2004-6-7 16:53

my ($file_in,$bin) =@_;

my @all_x_y;
open IN,"$file_in" || die"$!";
while (my $line = <IN>) {
	chomp $line;
#	print  "line=$line\n";
	my $locate =int( $line/$bin*1.00001);
	$number[$locate]++;
#	print  "locate=$locate\tnumber=$number[$locate]\n";

}
#print  "number=@number\n";
my @all_x_y;
my $x_length = (scalar @number);
my $x_real;
my $y_real;
	
for (my $k = 0;$k<$x_length+1;$k++) {
	$x_real = $k*$bin;
	$y_real = $number[$k];
	$all_x_y[$x_real] = $y_real;
#	print  "x_real=$x_real\ty_real=$y_real\n";
}

return @all_x_y;
}



sub percent{
	# input:
	# 2
	# 4
	# 2
	# 6
	# 7
	# output:
	# 0:0
	# 1:0
	# 2:40
	# 3:0
	# 4:20
	# 5:0
	# 6:20
	# 7:20
	# 对每个x计数
	# 2004-6-7 16:53

my ($file_in,$bin) =@_;

my @all_x_y;
#print  "$file_in\n";
open IN,"$file_in" || die"$!";

my $line_count = 0;
while (my $line = <IN>) {
	chomp $line;
	my $locate =int( $line/$bin*1.00001);
	$number[$locate]++;
	$line_count++;
}

my @all_x_y;
my $x_length = (scalar @number);
my $x_real;
my $y_real;
	
for (my $k = 0;$k<$x_length+1;$k++) {
	$x_real = $k*$bin;
	$y_real = $number[$k]*100/$line_count;
	$all_x_y[$x_real] = $y_real;
}

return @all_x_y;
}