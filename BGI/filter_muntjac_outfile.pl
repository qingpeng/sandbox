#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#   SW  perc perc perc  query     position in query      matching     repeat         position in  repeat
#score  div. del. ins.  sequence  begin   end  (left)   repeat       class/family    begin  end (left)  ID
#
#   26   0.0  0.0  0.0  bsaa         61    86 (68984) +  AT_rich      Low_complexity      1   26    (0)   1      
#  204   4.0  0.0  0.0  bsaa        246   270 (68800) +  (TG)n        Simple_repeat       2   26    (0)   2      
#  345   4.7  0.0  0.0  bsaa        337   379 (68691) +  (CA)n        Simple_repeat       1   43    (0)   3      
# 1474   9.6  3.5  0.0  bsaa       2937  3134 (65936) +  Bov-tA3      SINE/BovA           9  213    (0)   4      
#18203  12.9  3.1  3.0  bsaa      63817 65125  (3945) +  Bov-B        LINE/BovB        2021 3327   (81)  96      


while (<IN>) {
	chomp;
	if (!/SW|score/ && $_ ne "") {
		@s=split /\s+/,$_;
			if ($s[0] eq "") {
				$bac_name=$s[5];
				$start=$s[6];
				$end=$s[7];
				$direction=$s[9];
				$repeat_name=$s[10];
				$repeat_class=$s[11];
				if ($repeat_class!~/Low_complexity|Simple_repeat|Unknown|snRNA|tRNA/) {
					print OUT "$bac_name\_muntjac\t$start\t$end\t$direction\t$repeat_name\t$repeat_class\n";

				}

			}
			else {
				$bac_name=$s[4];
				$start=$s[5];
				$end=$s[6];
				$direction=$s[8];
				$repeat_name=$s[9];
				$repeat_class=$s[10];
					if ($repeat_class!~/Low_complexity|Simple_repeat|Unknown|snRNA|tRNA/) {
						print OUT "$bac_name\_muntjac\t$start\t$end\t$direction\t$repeat_name\t$repeat_class\n";
					}

			}

	}
}