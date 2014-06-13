#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "1")
{
	#remove vector sequence: XXXXXXXXXX for EST submit
	#create 2003-11-7
	
	($type,$F_reads) = @ARGV;

	$P_MinSize = 30;

	open(E,$F_reads);
	while(<E>)
	{
		if(/^\>(\S+)/)
		{
			$name = $1;
		}
		elsif(/>/) { die"$_"; }
		else { chomp; $seq{$name} .= $_; }
	}
	close(E);

	open(Problem,">$F_reads.problem");
	foreach $name (keys %seq)
	{
		$seq = $seq{$name}; #print "$seq\n"; 
		$seq =~ tr/\r//d;
		@temp = split(/[Xx]+/,$seq);
		@temp = sort { length($b) <=> length($a) } @temp;
		$seq = $temp[0]; #print "$seq\n"; 

		if(length($seq)>$P_MinSize) 
		{
			$length = length($seq);
			print ">$name $length\n";
			while(length($seq) > 50)
			{
				$temp = substr($seq,0,50);
				substr($seq,0,50) = "";
				print "$temp\n";					
			}
			if(length($seq) > 0)
			{
				print "$seq\n";
			}
		}
		if($seq{$name} =~ /[^Xx]+[Xx]+[^Xx]+/)
		{
			$seq = $seq{$name};
			$length = length($seq);
			print Problem ">$name $length\n";
			while(length($seq) > 50)
			{
				$temp = substr($seq,0,50);
				substr($seq,0,50) = "";
				print Problem "$temp\n";					
			}
			if(length($seq) > 0)
			{
				print Problem "$seq\n";
			}
		}
	}
	close(Problem);

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
