#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



#  <"bsah_1","bsah_1",1152,"","",1,1152,""
#  -4,100,288,592,2.05,290,95,0.32
#  >"bsah",94830,"",4,100
#  E,R,1,441,8126,7686,441,100,
#  I,R,7685,7593,93,
#  E,R,442,948,7592,7086,507,100,
#  I,R,7085,6991,95,
#  E,R,949,1086,6990,6853,138,100,
#  I,R,6852,5264,1589,
#  E,R,1087,1152,5263,5198,66,100,


while (my $line = <IN>) {
	chomp $line;
	if ($line =~/^<\"(\S+?)\",\"/) {
		$gene_id = $1;
	}
	elsif ($line =~/^E,/) {
		@s =split /,/,$line;
		if ($s[1] eq "R") {
			$mark = "-";
		}
		else {
			$mark = "+";
		}
		$start = $s[4];
		$end = $s[5];
		if ($s[4]>$s[5]) {
			$end = $s[4];
			$start = $s[5];
		}
		$print_line = $start.":".$end.":".$mark."::".$gene_id;
		print OUT "$print_line\n";
	}
}




