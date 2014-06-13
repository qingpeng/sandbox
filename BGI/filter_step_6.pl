#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 对每个recored判断 the region of the deer bac match to the number of bt scaffold
# 2005-3-11 16:10
# 对麂子scaffold比上牛scaffold的个数计数
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#-	Scaffold000007	1611	719	1448	25960	25226	79789	 474	1e-131	618/738	83	SCAFFOLD130009
#
#+	Scaffold000014	1426	478	1158	1867	2549	10711	 868	0.0	624/684	91	SCAFFOLD131007
#-	Scaffold000019	1272	25	582	2876	2316	10711	 523	1e-146	490/562	87	SCAFFOLD131007
#
#-	Scaffold000040	691	3	691	9918	9247	16212	 706	0.0	604/689	87	SCAFFOLD136073
#+	Scaffold000013	1435	9	523	9933	10448	16212	 698	0.0	476/516	92	SCAFFOLD136073
#+	Scaffold000013	1435	673	1390	10707	11425	16212	1051	0.0	674/720	93	SCAFFOLD136073
#-	Scaffold000028	983	1	676	14987	14311	16212	 914	0.0	624/677	92	SCAFFOLD136073




@lines = <IN>;
chomp @lines;

for (my $k = 0;$k<scalar @lines;$k++) {
	if ($lines[$k] eq "") {
		print OUT "\n";
	}
	else {
		
	@s = split /\t/,$lines[$k];
	$query = $s[1];
	$start = $s[3];
	$end = $s[4];
	my %subject =();
	for (my $kk = 0;$kk<scalar @lines;$kk++) {
		unless ($lines[$kk] eq "") {
		
		@ss = split /\t/,$lines[$kk];
		if ($query eq $ss[1] &&(($start<$ss[3]+100 && $start>$ss[3]-100) || ($end<$ss[4]+100 && $end>$ss[4]-100))) {
			$subject{$ss[-1]} = 1;
		}

		}
	}
	$count = scalar keys %subject;
	print OUT "$count\t$lines[$k]\n";
	}

}
