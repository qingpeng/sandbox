#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# compare the step_6 result to the human order file 
# mark the conflict point
# 2005-3-11 18:59
# 
if (@ARGV<3) {
	print  "programm human_order file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

open LIST,"$file_list" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#
#	Scaffold000014		-
#+	Scaffold000012	2452	-	32	1558	1527	48973	50555	1583
#++	Scaffold000002	10965	-	464	2147	1684	61168	62924	1757
#
#+	Scaffold000016	1390	-	50	1353	1304	66173	67807	1635
#

my $p = 1;
while (<LIST>) {
	chomp;
	@s = split;
	unless ($_ eq "") {
		$position{$s[1]} = $p;
		$direction{$s[1]} = $s[3];
		$p++;
	}
}

#
#1	+	Scaffold000009	4264	3146	4216	7927	9007	69438	 946	0.0	940/1086	86	SCAFFOLD80004
#1	+	Scaffold000018	1323	830	1323	9970	10459	69438	 571	1e-160	444/494	89	SCAFFOLD80004
#1	+	Scaffold000020	994	73	585	10542	11055	69438	 658	0.0	471/515	91	SCAFFOLD80004
#1	+	Scaffold000020	994	702	994	11509	11804	69438	 335	2e-89	266/296	89	SCAFFOLD80004
#bsab_Scaffold000042	680	355	418	-	chr10	72717409	46820164	46820227	1	54	355,418;	46820227,46820164;	-54;
#bsab_Scaffold000033	858	286	381	+	chr20	61172541	9115421	9115517	1	80	286,381;	9115421,9115517;	+80;
#bsab_Scaffold000022	1106	533	617	+	chr20	61172541	9117435	9117519	1	71	533,617;	9117435,9117519;	+71;
#bsab_Scaffold000041	680	344	630	-	chr20	61172541	9121888	9122183	2	227	344,482;521,630;	9122183,9122045;9121999,9121888;	-124;-103;
#bsab_Scaffold000032	867	28	197	-	chr20	61172541	9124797	9124964	1	139	28,197;	9124964,9124797;	-139;


$last_pos = 0;
while (<IN>) {
	chomp;
	if ($_ eq ""){
		$last_pos = 0;
		print OUT "\n";
	}
	else {
		
	@s =split/\t/,$_;
	@name=split/_/,$s[0];
	if (!exists $position{$name[1]}){ # not appeare in the human order file
		$mark = "New";
	}
	else {
		if ($last_pos == 0){ # the first line of every BT scaffold block
			$last_pos = $position{$s[2]};
			$last_scaffold = $s[2];
			$last_direction = $s[4];
			$mark = "-";
		}
		else { 
			if ($s[2] eq $last_scaffold && $s[4] eq $last_direction){
				$mark="-";
			}
			else {
				
			if (($last_direction eq $direction{$last_scaffold} && $s[4] eq $direction{$s[2]} && $position{$s[2]} >$last_pos)||($last_direction ne $direction{$last_scaffold} && $s[4] ne $direction{$s[2]} && $position{$s[2]} <$last_pos)){
				$mark = "-";
				$last_pos = $position{$s[2]};
				$last_scaffold = $s[2];
				$last_direction = $s[4];
			}
			else {
				$mark = "?";
				$last_pos = $position{$s[2]};
				$last_scaffold = $s[2];
				$last_direction = $s[4];
			}
		}
	
		}
	}
	print OUT "$mark\t$_\n";
			

	}
}



