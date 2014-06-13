#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# 不落在同一个基因上（本身）
# determine whether the oligo is in ORF region
#　2005-1-11 15:12
# 


if (@ARGV<3) {
	print  "programm refGene.txt file_in file_out \n";
	exit;
}
($file_refgene,$file_in,$file_out) =@ARGV;

open REFGENE,"$file_refgene" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# NM_012331	chr8	+	9949235	10323803	9949436	10323232	6	9949235,10102752,10140023,10196453,10214802,10323067,	9949578,10102821,10140143,10196558,10214909,10323803,
# NM_173683	chr8	-	10791065	10897401	10792871	10819677	3	10791065,10819553,10897307,	10793836,10819750,10897401,

while (<REFGENE>) {
	@s = split /\t/,$_;
	$start{$s[0]} = $s[3]+1;
	$end{$s[0]} = $s[4];
	$orf_start{$s[0]} = $s[5]+1;
	$orf_end{$s[0]} = $s[6];
	$chr{$s[0]} = $s[1];
	$direction{$s[0]} = $s[2];
}

# Query-name	Letter	QueryX	QueryY	SbjctX	SbjctY	Length	Score	E-value	Overlap/total	Identity	Sbject-Name
# NM_000015	69	1	69	18268610[4]	18268678[5]	chr_length	 137	7e-31	69/69	100	chr8
# NM_000015	69	7	68	18239223	18239284	chr_length	52.0	3e-05	53/62	85	


<IN>;
while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (exists $direction{$s[0]}) {
		if ($s[2] == 1 && $s[3] == 69 && $s[-2] == 100) { # 确认完全比上
			if ($direction{$s[0]} eq "+") {	
				if ($s[-1] eq $chr{$s[0]} && $s[4]<$s[5] && $s[4]>=$start{$s[0]} && $s[5]<=$end{$s[0]}) {# 确认在基因区内
					if ($s[-1] eq $chr{$s[0]} && $s[4]<$s[5] && $s[4]>=$orf_start{$s[0]} && $s[5]<=$orf_end{$s[0]}) {# 确认在orf区内
						print OUT "$_\tIn_ORF\n";
					}
					else {
						print OUT "$_\tOut_Of_ORF\n";
					}
				}
			}
			else {
				if ($s[-1] eq $chr{$s[0]} && $s[4]>$s[5] && $s[5]>=$start{$s[0]} && $s[4]<=$end{$s[0]}) {# in genomics region
					if ($s[-1] eq $chr{$s[0]} && $s[4]>$s[5] && $s[5]>=$orf_start{$s[0]} && $s[4]<=$orf_end{$s[0]}) {# in orf region
						print OUT "$_\tIn_ORF\n";
					}
					else {
						print OUT "$_\tOut_Of_ORF\n";
					}
				}
			}
		}
	}
	else {
		print  "not defined!!!!   $s[0]\n";
	}
}



