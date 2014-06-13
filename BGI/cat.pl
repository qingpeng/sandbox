#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


	($F_sort,$F_out) = @ARGV;


open I,"$F_sort" || die"$!";
open O,">$F_out" || die"$!";

$nul = ":::";
while (<I>) {
	chomp;
	@s = split;
	push @all,@s;
}

	@cat = &cat(0,@all);
	for (my $k = 0;$k<scalar @cat;$k=$k+2) {
		print O "$cat[$k]:$cat[$k+1]$nul\n";
	}


close I ;
close O;


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#####################################################################33333
sub std
{
	my(@sample) = @_;
	my $num = @sample;
	my $sum_mean = 0;
	my $mean = 0;
	my $sum_std = 0;
	my $std = 0;

	for(my $i=0;$i<@sample;$i++)
	{
		$sum_mean += $sample[$i];
	}
	$mean = $sum_mean / $num;

	for(my $i=0;$i<@sample;$i++)
	{
		$sum_std += ($sample[$i] - $mean) ** 2;
	}
	$std = sqrt($sum_std / ($num - 1));
	return($std);
}
######################################################################33333
sub mean
{
	my(@sample) = @_;
	my $num = @sample;
	my $sum_mean = 0;
	my $mean = 0;
	my $sum_std = 0;
	my $std = 0;

	for(my $i=0;$i<@sample;$i++)
	{
		$sum_mean += $sample[$i];
	}
	$mean = $sum_mean / $num;

	return($mean);
}
######################################################################33333
######################################################################33333
sub median
{
	my(@sample) = @_;
	@sample = sort {$a <=> $b} @sample;
	my $median = $sample[int($#sample/2+0.5)];

	return($median);
}
######################################################################33333
###################################################################

	sub cat
	#function:quit redundance
	#input:($para,@array), para is the merge length 
	#output:(@array), 
	#for example (0,1,3,4,7,5,8)->(1,3,4,8) (1,1,3,4,7,5,8)->(1,8)
	{
		my($merge,@input) = @_;
		my $i = 0;
		my @output = ();
		my %hash = ();
		my $each = 0;
		my $begin = "";
		my $end = 0;

		for ($i=0;$i<@input;$i+=2) 
		{
			$Qb = $input[$i];
			$Qe = $input[$i+1];

			if($Qb > $Qe) { next; }
			if(defined($hash{$Qb}))	{ if($hash{$Qb} < $Qe) { $hash{$Qb} = $Qe; } }
			else { $hash{$Qb} = $Qe; }
			$Qb = 0;
		}

		foreach $each (sort {$a <=> $b} keys %hash) 
		{
			if($begin eq "")
			{
				$begin = $each;
				$end = $hash{$each};
			}
			else
			{
				if($hash{$each} > $end) 
				{
					if($each > $end + $merge) 
					{ 
						push(@output,$begin);
						push(@output,$end);
						$begin = $each; 
						$end = $hash{$each};
					}
					else { $end = $hash{$each}; }
				}
			}
		}
		if(%hash > 0)
		{
			push(@output,$begin);
			push(@output,$end);
		}

		%hash = ();

		return(@output);
	}
#########################
if($ARGV[0] eq "testcat")
{
	@temp = (6,6,99,69);
	@temp = &cat(1,@temp);
	$out = join(" ",@temp);
	print "$out\n";
}
#############################################################################
#####################################################################3333
###################################################################

	sub L
	#function: compute total length by start and stop
	#input:(@array)
	#output:($length)
	#for example (1,3,5,8)->(7)
	{
		my(@input) = @_;
		my $i = 0;
		my $length = 0;

		for ($i=0;$i<@input;$i+=2)
		{
			$length += $input[$i+1] - $input[$i] + 1;
		}

		return($length);
	}
#####################################################################3333
######################################################################33333
###################################################################

	sub over
	#function: find overlap between two groups
	#input:($array1,$array2) 
	#output:(@array)
	#for example (0,1,5,8) + (1,3,4,8) -> (1,1,5,8)
	{
		my($array1,$array2) = @_;
		my @array1 = split(/\s+/,$array1);
		my @array2 = split(/\s+/,$array2);
		my $i = 0;
		my $j = 0;
		my $s = 0;
		my @output = ();
		my $start = 0;
		my $end = 0;

		for ($i=0;$i<@array1;$i+=2) 
		{
			for ($j=$s;$j<@array2;$j+=2) 
			{
				if($array1[$i+1] < $array2[$j]) { last; }
				elsif($array1[$i] > $array2[$j+1]) { $s = $j + 2; next; }
				else
				{
					if($array1[$i] < $array2[$j]) { $start = $array2[$j]; } else { $start = $array1[$i]; }
					if($array1[$i+1] < $array2[$j+1]) { $end = $array1[$i+1]; } else { $end = $array2[$j+1]; }
					if($end < $start) { die"error: END $end < START $start\n"; }
					push(@output,$start);
					push(@output,$end);
					if($array1[$i+1] > $array2[$j+1]) { $s = $j + 2; }
				}
			}
		}

		return(@output);
	}
#########################
if($ARGV[0] eq "testover")
{
	$a = "1 4 5 8";
	$b = "2 6";
	@temp = &over($a,$b);
	$out = join(" ",@temp);
	print "$out\n";
}
#############################################################################
#####################################################################3333
##################################################################

	sub dog
	#function: translate position to the contrary strand
	#input:($length,@array) 
	#output:(@array)
	#for example (100,1,5,20,58) -> (43,81,96,100)
	{
		my($length,@array) = @_;
		my $i = 0;
		my @output = ();
		my $start = 0;
		my $end = 0;

		for ($i=0;$i<@array;$i+=2) 
		{
			$start = $length+1-$array[$i+1];
			$end = $length+1-$array[$i];
			unshift(@output,$end);
			unshift(@output,$start);
		}

		return(@output);
	}

#########################
if($ARGV[0] eq "testdog")
{
	@temp = (1,5,20,58);
	@temp = &dog(100,@temp);
	$out = join(" ",@temp);
	print "$out\n";
}
#############################################################################
##################################################################

	sub NOT
	#function: translate align_position to not_align_position
	#input:($length,@array) 
	#output:(@array)
	#for example (100,1,5,20,58) -> (6,19,59,100)
	{
		my($length,@array) = @_;
		my $i = 0;
		my @output = ();
		my $start = 0;
		my $end = 0;
		
		@array = &cat(1,@array);
		for ($i=0;$i<@array;$i+=2) 
		{
			$array[$i] -= 1;
			$array[$i+1] += 1;
		}
		push(@array,$length);
		unshift(@array,1);
		@output = &cat(1,@array);
		return(@output);
	}

#########################
if($ARGV[0] eq "testNOT")
{
	@temp = (1,5,3,100);
	@temp = &NOT(100,@temp);
	$out = join(" ",@temp);
	print "$out\n";
}
#############################################################################
######################################################################3333

	sub gap
	{
		#function: compute gap(N) loci from a sequence
		#input:($seq,$P_mingap)
		#output:(%gap) $gap{$gap_loci} = $gap_size
		#case: ("NNNNANGAAAAANNNNNG",4) -> (1,4,13,5)
		#create: 
		#last update: 2003-10-28

		my ($seq,$P_mingap) = @_;
		$seq = uc($seq);
		my @tempN = split(/[^N]+/,$seq);
		my @tempATGC = split(/N+/,$seq);
		my %gap = ();
		if($tempN[0] eq "") { shift(@tempN); }
		my $i = 0;
		my $posi = 1;
		for($i=0;$i<@tempN;$i++)
		{
			$posi += length($tempATGC[$i]);
			if(length($tempN[$i]) >= $P_mingap) { $gap{$posi} = length($tempN[$i]); }
			$posi += length($tempN[$i]);
		}
		
		return(%gap);
	}
#########################
if($ARGV[0] eq "testgap")
{
	$seq = "ANNNNANGAAAAANNNNNGNNNN";
	$P_mingap = 4;
	$out = join(" ",&gap($seq,$P_mingap));
	print "$out\n";
}
#############################################################################
#####################################################################3333

