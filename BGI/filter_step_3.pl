#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# overlap > short_length/2 remove them!
#¡¡2005-3-9 11:12
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

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


my %start;
my %end;
my %line;

while (<IN>) {
	chomp;
	unless ($_ eq "") {
	
	@s =split/\t/,$_;
	if ($s[5]>$s[6]) {
		$start = $s[6];
		$end = $s[5];
	}
	else {
		$start = $s[5];
		$end = $s[6];
	}
	push @{$start{$s[-1]}},$start;
	push @{$end{$s[-1]}},$end;
	push @{$line{$s[-1]}},$_;

	}
}

# mark
foreach my $subject (sort keys %line) {
	$line_num = scalar @{$line{$subject}};
	for (my $k = 1;$k<$line_num;$k++) {
		$start = ${$start{$subject}}[$k];
		$end = ${$end{$subject}}[$k];
		$lengthh = $end-$start;
		for (my $kk=0;$kk<$k;$kk++) {
			$start_last = ${$start{$subject}}[$kk];
			$end_last = ${$end{$subject}}[$kk];
			$length_last = $end_last-$start_last;
			if ($lengthh>$length_last) {
				$short_length_2 = $length_last/2;
			}
			else {
				$short_length_2 = $lengthh/2;
			}
			if ($start<$end_last-$short_length_2 && $end>$start_last+$short_length_2) {
				${$mark{$subject}}[$kk] = "N";
				${$mark{$subject}}[$k] = "N";
			}
		}
	}
}

# remove line
foreach my $subject (sort keys %line) {
	$line_num = scalar @{$line{$subject}};
	for (my $k = 0;$k<$line_num;$k++) {
		if (! defined ${$mark{$subject}}[$k]) {
			print OUT "${$line{$subject}}[$k]\n";
		}
	}
	print OUT "\n";
}

