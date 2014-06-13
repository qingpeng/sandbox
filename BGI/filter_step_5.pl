#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#  去掉一对一的record，并且按照deer scaffold num排序
# 2005-3-11 9:51
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



while (<IN>) {
	chomp;
	unless ($_ eq "") {
	
	@s =split/\t/,$_;
	push @{$lines{$s[-1]}},$_;
	${$mark{$s[-1]}}{$s[1]} = 1;

	}
}

@subjects = keys %lines;

@sort_subjects = sort comp @subjects;


sub comp{
	@a_num = keys %{$mark{$a}};
	@b_num = keys %{$mark{$b}};
	$a_num = scalar @a_num;
	$b_num = scalar @b_num;
	$b_num <=> $a_num;
}

foreach my $subject (@sort_subjects) {
	$query_num = scalar keys %{$mark{$subject}};
	$t =0 ;
	if ($query_num>1) {
		$t = 1;
		for (my $k = 0;$k<scalar @{$lines{$subject}};$k++) {
			print OUT "${$lines{$subject}}[$k]\n";
		}
	}
	if ($t==1) {
		print OUT "\n";
	}
}

