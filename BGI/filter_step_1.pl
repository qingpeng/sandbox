#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 过滤出>250,同一个牛scaffold比到多个deer scaffold 去除了麂子的scaffold与牛的唯一对应的情况
# 2005-3-5 16:00
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



#Scaffold000004  6280    3289    4024    3809    3067    13794    630    1e-177  639/744 85      SCAFFOLD181247
#Scaffold000004  6280    3303    4024    1242    526     2865     632    1e-178  631/726 86      SCAFFOLD181705
#Scaffold000004  6280    3396    4024    5635    5009    7356     486    1e-134  538/631 85      SCAFFOLD181835
#Scaffold000002  10215   3904    5088    51      1232    1854     825    0.0     996/1186        83      SCAFFOLD182484
#Scaffold000001  52293   10247   10991   848     102     1000    1045    0.0     694/749 92      SCAFFOLD182902
#Scaffold000002  10215   3688    4877    1248    65      3330     759    0.0     997/1191        83      SCAFFOLD183495
#Scaffold000004  6280    3289    4024    40350   39610   40428    603    1e-169  638/746 85      SCAFFOLD185038
#Scaffold000002  10215   3688    4875    1232    2412    22568    916    0.0     1010/1189       84      SCAFFOLD185138
#Scaffold000004  6280    3483    4024    28221   28762   40713    486    1e-134  472/544 86      SCAFFOLD185212
#Scaffold000002  10215   3904    5683    9673    11457   15106   1051    0.0     1481/1789       82      SCAFFOLD185447
#Scaffold000001  52293   10255   10987   4139    4873    15860    846    0.0     660/737 89      SCAFFOLD185459
#Scaffold000001  52293   10255   10991   8720    9458    15860   1013    0.0     684/741 92      SCAFFOLD185459
#Scaffold000001  52293   10246   10864   11873   11253   15860    660    0.0     551/623 88      SCAFFOLD185459
#Scaffold000005  3494    218     794     9128    9703    12735    470    1e-129  499/581 85      SCAFFOLD185546
#Scaffold000005  3494    803     1534    9717    10451   12735    910    0.0     671/738 90      SCAFFOLD185546
#Scaffold000005  3494    218     788     5254    5824    16362    521    1e-145  501/574 87      SCAFFOLD185587
#Scaffold000005  3494    809     1534    6433    7162    16362    815    0.0     652/731 89      SCAFFOLD185587
$last_query="N";
$last_subject = "N";
$p = 0;
$lines = "";
while (<IN>) {
	chomp;
	unless ($_=~/^Query/) {
	
	
	@s =split/\t/,$_;
	@split_s = split /\//,$s[9];
	if ($split_s[1]>250 && $s[6]>3000) {
	
	$query = $s[0];
	$subject = $s[-1];
	if ($subject eq $last_subject && $query ne $last_query) {
		$p=1;
		$lines = $lines."\n".$_;
		$last_query = $query;
		$last_subject = $subject;
	}
	elsif ($subject eq $last_subject && $query eq $last_query) {

		

		$lines = $lines."\n".$_;
		$last_query = $query;
		$last_subject = $subject;
	}
	else {
		if ($p == 1) {
			print OUT "$lines\n";
		}
		$p = 0;
		$lines=$_;
		$last_query = $query;
		$last_subject = $subject;
	}

	}

	}
}

		if ($p == 1) {
			print OUT "$lines\n";
		}


