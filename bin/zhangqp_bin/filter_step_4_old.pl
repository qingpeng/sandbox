#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 同一个deer scaffold region (+/- 100bp)比到多于10个牛scaffold，丢掉
#　2005-3-10 15:43
# 

if (@ARGV<3) {
	print  "programm >=repeat_num file_in file_out \n";
	exit;
}
($repeat,$file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#+	Scaffold000012	1782	479	1187	36002	36698	50804	1027	0.0	662/709	93	SCAFFOLD45109
#+	Scaffold000012	1782	1230	1724	36741	37241	50804	 636	1e-180	459/504	91	SCAFFOLD45109
#+	Scaffold000004	7582	530	1525	38750	39743	50804	1253	0.0	912/1001	91	SCAFFOLD45109
#+	Scaffold000004	7582	2488	3158	40631	41291	50804	 912	0.0	621/672	92	SCAFFOLD45109
#+	Scaffold000004	7582	3751	4456	41815	42515	50804	 805	0.0	639/708	90	SCAFFOLD45109
#+	Scaffold000004	7582	4486	5575	42516	43620	50804	1463	0.0	1021/1106	92	SCAFFOLD45109
#-	Scaffold000020	764	15	764	48365	47613	50804	 924	0.0	687/754	91	SCAFFOLD45109
#+	Scaffold000010	2654	347	1128	48671	49463	50804	1078	0.0	733/793	92	SCAFFOLD45109

@lines = <IN>;
chomp @lines;

for (my $k = 0;$k<scalar @lines;$k++) {
	$line = $lines[$k];
	%subject =();
	if ($line eq "") {
		print OUT "\n";
	}
	else {
		
	
	@s = split /\t/,$line;
	$start = $s[3];
	$end = $s[4];
	$query =$s[1];
	for (my $kk = 0;$kk<scalar @lines;$kk++) {
		unless ($lines[$kk] eq "") {
		
		@ss = split /\t/,$lines[$kk];
		if ($ss[1] eq $query && $ss[3] >$start-100 && $ss[3]<$start+100 && $ss[4]>$end - 100 && $ss[4]<$end+100) {
			$subject{$ss[-1]} = 1;
		}

		}
	}
	$num = scalar keys %subject;
	unless($num>=$repeat) {
		print OUT "$line\n";
	}

	}
}


