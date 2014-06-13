#!/usr/local/bin/perl -w


# 将repeatmasker 结果插入tba result结果文件中
# 2005-4-8 18:03 上午

# bsab    1431    59553   +       chr3    12173310        12290136        +       chr6    115642516       115735188       +       chr20   9125790      9241205 -
# bsac    4658    92326   +       chr15   99182814        99274349        +       chr7    53422908        53517408        -       chr3    43086599     43171417        -
# bsaf    2267    49199   +       chr10   77556485        77644843        +       chr14   18947482        19015782        +       chr4    29468088     29538531 


if (@ARGV<4) {
        print  "programm bac_name file_tba_repeat file_list  file_out \n";
        exit;
}
($bac_name,$file_in,$file_list,$file_out) =@ARGV;


open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open LIST,"$file_list"||die "$!";
# open REPEAT,"$file_repeat"||die "$!";

		
$bac=$bac_name; # bac


while (<LIST>){
	chomp;
	@s = split /\t/,$_;
	$human{$s[0]} = $s[4]."_".$s[5]."_".$s[6]."_".$s[7];
	$mouse{$s[0]} = $s[8]."_".$s[9]."_".$s[10]."_".$s[11];
	$dog{$s[0]} = $s[12]."_".$s[13]."_".$s[14]."_".$s[15];
	$deer{$s[0]} = $s[0]."_".$s[1]."_".$s[2]."_".$s[3];
}

$region{muntjac} = $deer{$bac};
$region{human} = $human{$bac};
$region{mouse} = $mouse{$bac};
$region{dog} = $dog{$bac};



# repeat file
# 252  26.6  3.1  0.0  chr10_77556485_77644843_+       528    591  (87768) +  (CATG)n         Simple_repeat       2   67    (0)    1
#   24   3.2  0.0  0.0  chr10_77556485_77644843_+      2283   2313  (86046) +  AT_rich         Low_complexity      1   31    (0)    2
#    865  28.1  2.8  0.8  chr10_77556485_77644843_+      3102   3356  (85003) +  MIR             SINE/MIR            1  260    (2)    3
 



#	a score=35258.0
#human
#Aatagtctaaagtagaagttcatagcaaggggtcttcaaccagactactgggattcaattcctagctcttctactctctggctttgctaccctg---ggtaaattacttaacctctctgatttcagtttcttcatatgtaa
#3441    3695
#dog
#AATGATCTA------AAATtaatggtagagcctctt-taccagactacctggattcaattcccagcttttaaacttcctagcttcattaatttcctgggtgaattatttcccctctctgatttcagtttcatcatatgtaa
#4224    4458
#mouse
#AATGGTCTAAAGTAGCAGTTACTACTAATATctcttaaattagacaatatggatttgtttctttgcccttccactctta----tagctaccctg---cataaatgatttacctattctgagtcaagtttttt-atctgtaa
#3669    3864
#muntjac
#GGTTgtctaaagtagaagttaatagtgagaaatatt-gaccagattacctgggttcaattcctggttctgtcacttaccatctttcttagcttc---ggtagcttgcttaacctctctgatttccatttcttcatatataa
#2611    2858

while (<IN>) {
	chomp;
	if ($_=~/^a/) {
		print OUT "$_\n";
	}
	elsif ($_=~/(human|dog|muntjac|mouse)/) {
		$specie = $1;
		$region = $region{$specie};
#		print "$region\n";
		print OUT "$_\n";
	}
	elsif ($_=~/(\d+)\s+(\d+)/) {
		print OUT "$_\n";
		$start = $1;
		$end = $2;
		$repeat_file = $specie.".seq.out";
#		print "$repeat_file\n";
		open REPEAT,"$repeat_file";
		while (<REPEAT>) {
			chomp;
			if ($_=~/\d+/) {
#  573  25.9  4.2  6.6  chr10_77556485_77644843_+     15645  15933  (72426) C  L1ME3B          LINE/L1         (189) 6051   5770   12
#  252   5.9  0.0  0.0  chr10_77556485_77644843_+     15955  15988  (72371) +  (TTA)n          Simple_repeat       3   36    (0)   13
#27061   4.2  0.2  0.1  chr10_77556485_77644843_+     15989  22117  (66242) C  L1PA4           LINE/L1          (19) 6136      4   14
				
				#	print "aaaa $_\n";
				@s = split /\s+/,$_;
				if ($_=~/^\d/){
					$region_here=$s[4];
					$start_here=$s[5];
					$end_here=$s[6];
				}
				else {
					$region_here = $s[5];
					$start_here = $s[6];
					$end_here = $s[7];
				}

				#print "start==$start_here\tend==$end_here\tregion==$region_here\n";   
				if($region eq $region_here  && $start>=$start_here  && $end<=$end_here) {
					#	print "Here~~~\n";
					print OUT "REPEAT:	$_\n";
				}
			}
		}
		close REPEAT;
	}else {
		print OUT "$_\n";
	}
}



					
					
					
			
		
