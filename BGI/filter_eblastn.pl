#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# 不落在同一个基因上（本身）
# 1.比上长度〉20bp,identity>70% 输出到文件
# 2. 精确比对长度〉49bp,输出到屏幕
# 2004-8-27 17:10
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
	$start{$s[0]} = $s[3];
	$end{$s[0]} = $s[4];
	$chr{$s[0]} = $s[1];
	$direction{$s[0]} = $s[2];
}

# Query-name	Letter	QueryX	QueryY	SbjctX	SbjctY	Length	Score	E-value	Overlap/total	Identity	Sbject-Name
# NM_000015	69	1	69	18268610[4]	18268678[5]	chr_length	 137	7e-31	69/69	100	chr8
# NM_000015	69	7	68	18239223	18239284	chr_length	52.0	3e-05	53/62	85	chr8
# NM_000015	69	5	58	18090657	18090710	chr_length	52.0	3e-05	47/54	87	chr8
# NM_000015	69	52	68	16979437	16979421	chr_length	34.2	7.9	17/17	100	chr8
# NM_000015	69	49	67	28839348	28839330	chr_length	38.2	0.50	19/19	100	chr15
# NM_000015	69	49	67	25995565	25995583	chr_length	38.2	0.50	19/19	100	chr15
# NM_000015	69	49	67	159248080	159248062	chr_length	38.2	0.50	19/19	100	chr1
# NM_000015	69	49	67	159248080	159248062	chr_length	38.2	0.50	19/19	100	chr1
# NM_000015	69	50	67	84062137	84062154	chr_length	36.2	2.0	18/18	100	chrX

<IN>;
while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (exists $direction{$s[0]}) {
	
	if ($direction{$s[0]} eq "+") {
	
	unless ($s[-1] eq $chr{$s[0]} && $s[4]<$s[5] && $s[4]>$start{$s[0]} && $s[5]<$end{$s[0]}) {
		@ss = split /\//,$s[9];
		if ($ss[1] >20 && $s[10]>70) {
			print OUT "$_\n";
		}
		if ($ss[0]>49) {
			print  "$_\n";

		}
	}

	}

	else {

	unless ($s[-1] eq $chr{$s[0]} && $s[4]>$s[5] && $s[5]>$start{$s[0]} && $s[4]<$end{$s[0]}) {
		@ss = split /\//,$s[9];
		if ($ss[1] >20 && $s[10]>70) {
			print OUT "$_\n";
		}
		if ($ss[0]>49) {
			print  "$_\n";

		}
	
	}

	}
	}

	else {
		print  "not defined!!!!   $s[0]\n";
	}


}




