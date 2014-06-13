#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


open TABLE,"table" || die"$!";

$start = 1;
$start_40 = 41;
while (<TABLE>) {
	chomp;
	@s = split /\t/,$_;
	$count = $s[1];
	
	for ($k=$start;$k<$start+$count;$k++) {
		$gap[$k] = $s[0];
		print  "$k\t$s[0]\n";
	}
	$start = $start+$count;
	for ($k = $start_40;$k<$start_40+$count;$k++) {
		$gap[$k] = $s[0];
		print  "$k\t$s[0]\n";
	}
	$start_40 = $start_40+$count;
}

# >bdpd_02_A01.ab1  CHROMAT_FILE: bdpd_02_A01.ab1 PHD_FILE: bdpd_02_A01.ab1.phd.1 CHEM: unknown DYE: unknown TIME: Fri Jun 25 16:43:50 2004

$f{"A"} =1;
$f{"B"} =2;
$f{"C"} = 3;
$f{"D"} =4;
$f{"E"} = 5;
$f{"F"} =6;
$f{"G"} = 7;
$f{"H"} =8;

open READ,"bdpd.seq.screen" || die"$!";
open OUT,">reads.seq.pro" || die"$!";

while ($line = <READ>) {
	chomp $line ;
	
	if ($line =~ /^>bdpd_02_(\S)(\S\S)\.(.*)/) {
		$mark = $1;
		$num = $2;
		$other = $3;
		$count = ($num-1)*8+$f{$mark};
		print  "$mark\t$num == $count\n";
		$gap = $gap[$count];
		$print =  ">bdpd_02_$mark$num"."_$gap".".$other";
		print OUT "$print\n";
	}
	else {
		print OUT "$line\n";
	}
}

dfdfdf