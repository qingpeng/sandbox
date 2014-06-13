############################################################################
#2003-12-15
#

($F_a,$F_b,$P_OVER,$P_VALUE) = @ARGV;

#F_a=EST, F_b=cDNA, P_OVER=length(default) or percent, P_VALUE=value of P_OVER

if(!defined($P_OVER)) { $P_OVER = "length"; }

if($P_OVER eq "percent")
{
	if(!defined($P_VALUE)) { $P_VALUE = 80; } 
	$OVER_PERCENT = $P_VALUE; 
}
elsif($P_OVER eq "length") 
{
	if(!defined($P_VALUE)) { $P_VALUE = 100; } 
	$OVER_SIZE = $P_VALUE; 
}
else { die"P_OVER shuld be percent or length\n"; }

warn"\nGame Start!\n";

open(A,$F_a);
while(<A>)
{
	##270     0       0       0       0       0       0       0       +[8]*       Scaffold10001_1[9]* 720[10]*     450[11]     720[12]     AK058426[13]*        607[14]     65[15]*      335[16]*     1[17]       270,[18]*        450,[19]    65,[20]* 
	if(!/^\d/) { next; }
	@temp = split(/\s+/,$_); if(@temp == 22) { shift(@temp); }
	$sbjct = $temp[13];
	$line = join("\t",@temp);
	$a{$sbjct} .= $line."\n";
	chomp; $a_start{$line} = $temp[15];
}
close(A);
warn"finish reading A\n";

open(B,$F_b);
while(<B>)
{
	##270     0       0       0       0       0       0       0       +       Scaffold10001_1 720     450     720     AK058426        607     65      335     1       270,        450,    65, 
	if(!/^\d/) { next; }
	@temp = split(/\s+/,$_); if(@temp == 22) { shift(@temp); }
	$sbjct = $temp[13];
	$line = join("\t",@temp);
	$b{$sbjct} .= $line."\n";
	chomp; $b_start{$line} = $temp[15];
}
close(B);
warn"finish reading B\n";

open(O,">$F_out");
foreach $sbjct (keys %a)
{
	if(!defined($a{$sbjct})) { next; }
	if(!defined($b{$sbjct})) { next; }
	@a = split(/\n/,$a{$sbjct});
	@b = split(/\n/,$b{$sbjct});
	@a = sort {$a_start{$a} <=> $a_start{$b}} @a;	# ∞¥ ≈≈–Ú
	@b = sort {$b_start{$a} <=> $b_start{$b}} @b;

	$K = 0;
	foreach $b (@b)
	{
		@tempb = split(/\s+/,$b);
		chop($tempb[18]); #print "$tempb[18]\n";
		@b_segment_size = split(/\,/,$tempb[18]);
		chop($tempb[20]);
		@b_sbjct_start = split(/\,/,$tempb[20]);
	
		$flag = 0;
		for($k=$K;$k<@a;$k++)
		{
			@tempa = split(/\s+/,$a[$k]);
			if($tempa[15] >= $tempb[16]) { last; }
			if($tempa[16] >= $tempb[15])
			{
				if($flag == 0) { $flag = 1; $K = $k;}
			}
			else { next; }

			chop($tempa[18]);
			@a_segment_size = split(/\,/,$tempa[18]);
			chop($tempa[20]);
			@a_sbjct_start = split(/\,/,$tempa[20]);
			
			$s=0;
			for ($i=0;$i<@b_sbjct_start;$i++) 
			{
				for ($j=$s;$j<@a_sbjct_start;$j++) 
				{
					if($b_sbjct_start[$i]+$b_segment_size[$i] < $a_sbjct_start[$j]+1) { last; }
					elsif($b_sbjct_start[$i]+1 > $a_sbjct_start[$j]+$a_segment_size[$j]) { $s = $j + 1; next; }
					else
					{
						if($b_sbjct_start[$i]+1 < $a_sbjct_start[$j]+1) { $start = $a_sbjct_start[$j]+1; } else { $start = $b_sbjct_start[$i] + 1; }
						if($b_sbjct_start[$i]+$b_segment_size[$i] < $a_sbjct_start[$j]+$a_segment_size[$j]) { $end = $b_sbjct_start[$i]+$b_segment_size[$i]; } else { $end = $a_sbjct_start[$j]+$a_segment_size[$j]; }
						if($end < $start) { die"error: END $end < START $start\n"; }
						$over += $end - $start + 1; #$add = $end - $start + 1; print "$start $end $add $over\n";
						if($b_sbjct_start[$i]+$b_segment_size[$i] > $a_sbjct_start[$j]+$a_segment_size[$j]) { $s = $j + 1; }
					}
				}
			}

			$over_per_a = int($over/$tempa[10]*10000)/100;
			$over_per_b = int($over/$tempb[10]*10000)/100;

			# print: a_name	b_name	a_strand	b_strand	a_size	l_over	p_over
			if($P_OVER eq "percent") 
			{ 
				if($over_per_a >= $OVER_PERCENT) { print  "$tempa[9]\t$tempb[9]\t$tempa[8]\t$tempb[8]\t$over\t$tempa[10]\t$over_per_a\t$tempb[10]\t$over_per_b\n"; } 
			}
			elsif($P_OVER eq "length") 
			{
				if($over >= $OVER_SIZE) { print  "$tempa[9]\t$tempb[9]\t$tempa[8]\t$tempb[8]\t$over\t$tempa[10]\t$over_per_a\t$tempb[10]\t$over_per_b\n"; }
			}
			
			$over = 0;
		}
	}
}
close(O);

warn"Game Over!\n";

exit;
############################################################################
