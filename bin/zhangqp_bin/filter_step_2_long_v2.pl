#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 1. BT scaffold length >3K
# 2. query start/end in +/- 10bp
# 3. sort subject by the query scaffold num 
# 2005-3-7 15:55
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#Scaffold000001	15284	13451	14135	17082	16394	49859	 583	1e-163	593/689	86	SCAFFOLD105146
#Scaffold000005	6514	287	930	17128	16484	49859	 456	1e-125	545/646	84	SCAFFOLD105146
#Scaffold000001	15284	13415	14073	25616	26271	49859	 579	1e-161	569/659	86	SCAFFOLD105146
#

while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	if ($s[6]>3000) {
	
	$query = $s[0];
	$subject = $s[-1];
	$start = $s[2];
	$end = $s[3];
	#$key = $query."-".$subject;
	if (exists ${$start{$subject}}{$query}) {
		$num = scalar @{${$start{$subject}}{$query}};
		for (my $k=0;$k<$num;$k++) {

	if ($subject eq "SCAFFOLD151267") {
		print  "$subject\t$query\t$k\n$start---${${$start{$subject}}{$query}}[$k]\n$end---${${$end{$subject}}{$query}}[$k]\n";
	}

		
			
			if ($start<${${$start{$subject}}{$query}}[$k]+10 && $start>${${$start{$subject}}{$query}}[$k]-10 && $end<${${$end{$subject}}{$query}}[$k]+10 && $end>${${$end{$subject}}{$query}}[$k]-10) {
				${${$mark{$subject}}{$query}}[$k] = "N";
				${${$mark{$subject}}{$query}}[$num] = "N";
				print  "$subject\t$query\t$k\t$num--- N\n";
			}
#			else {
				#${${$mark{$subject}}{$query}}[$k] = "Y";
				#${${$mark{$subject}}{$query}}[$num] = "Y";
				#print  "$subject\t$query\t$k\t$num--- Y\n";
#			}
		}
	}
#	else {
#		${${$mark{$subject}}{$query}}[0] = "Y";
#	}
	push @{${$start{$subject}}{$query}},$start;
	push @{${$end{$subject}}{$query}},$end;
	push @{${$lines{$subject}}{$query}},$_;
	}
}

foreach my $subject (sort keys %lines) {
	@querys = sort keys %{$lines{$subject}};
	foreach my $query (@querys) {
		@lines = @{${$lines{$subject}}{$query}};
		for (my $kk = 0 ;$kk<scalar @lines;$kk++) {
			if (! defined ${${$mark{$subject}}{$query}}[$kk] ) {
				print  "$subject -- $query -- $kk\n${${$lines{$subject}}{$query}}[$kk]\n";
				push @{${$print_lines{$subject}}{$query}},${${$lines{$subject}}{$query}}[$kk];
			}
		}
	}
}


@subjects = keys %print_lines;
#print  "1111\n@subjects\n";
#$s = "aCAFFOLD10239";
#print  %{$print_lines{$s}};
#@an= keys %{$print_lines{"SCAFFOLD90022"}};
#@bn= keys %{$print_lines{"SCAFFOLD100356"}};
#print  "An--@an\n";
sub comp{
	@a_num = keys %{$print_lines{$a}};
	@b_num = keys %{$print_lines{$b}};
	$a_num = scalar @a_num;
	$b_num = scalar @b_num;
	$b_num <=> $a_num;
}

@sort_subjects = sort comp @subjects;

#print  "2222\n@sort_subjects\n";
foreach my $subject (@sort_subjects) {
	@querys = sort keys %{$print_lines{$subject}};
#	if ($subject eq "SCAFFOLD90022") {
#		print  "$subject---- @querys\n";
	foreach my $query (@querys) {
		@lines = @{${$print_lines{$subject}}{$query}};
 #          print  "@lines\n";
		for (my $kk = 0 ;$kk<scalar @lines;$kk++) {
#				print  "$subject\t$query\t$kk\n";
				print OUT "${${$print_lines{$subject}}{$query}}[$kk]\n";
		}
	}

#	}
}

