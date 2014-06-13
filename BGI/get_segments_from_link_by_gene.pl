#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从link文件中取出比上需要的基因的reads ,输出segment名称
# 2004-9-6 10:34
# 与segment fasta文件一致，只输入长度>=70bp的segments
# 2004-9-6 11:03
# 

if (@ARGV<3) {
	print  "programm gene_list file_link file_out \n";
	exit;
}
($file_gene,$file_link,$file_out) =@ARGV;

open GENE,"$file_gene" || die"$!";
open LINK,"$file_link" || die"$!";
open OUT,">$file_out" || die"$!";


# 
# AF042162
# AF055270
# AK024508
# AK025719
# AK026717
# AK027136
# AK055533

while (<GENE>) {
	chomp;
	$mark{$_} = 5;
}


# Link file
# cluster1245_2_Step1 to L24498_0,67518543,67523920 of L24498,1,1 @chr 67521017 -> 67521138 @read 166 -> 286 &direction +
# cluster1245_-8_Step1 to L24498_0,67518543,67523920 of L24498,1,1 @chr 67523290 -> 67523535 @read 9 -> 256 &direction +
# cluster1094_7_Step1 to AK055088_1,59736554,59736692 of AK055088,1,-1 @chr 59736554 -> 59736653 @read 459 -> 558 &direction -


while (my $line = <LINK>) {
	chomp $line;
    if ($line =~/(\S+) to \w+\,\d+\,\d+ of (\w+)\,\w+\,\-?1 \@chr \d+ \-\> \d+ \@read (\d+) \-\> (\d+) \&direction \S/) {
			($readName,$geneName,$read_start,$read_end)=($1,$2,$3,$4);
			if (exists $mark{$geneName}) {
				#print  "$line\n";
			
			$est_read = $readName;
			if ($est_read =~/singleton_(.*)/) {
				$est_read = $1;
			}
			if ($read_end - $read_start+1 >=70) {
			
			print OUT "$est_read\_$read_start\_$read_end\n";
			}

			}

	}
	
}


