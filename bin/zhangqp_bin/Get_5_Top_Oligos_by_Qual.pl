#!/usr/local/bin/perl -w
	
	defined(@ARGV) || die "Usage:\nInput(Oligo.Tm.seq) Output(*.3end)\n";
	
	($input, $output) = @ARGV;
	
	open(INPUT, "$input") || die;
	
	%Name_Pos = ();
	
	while(<INPUT>)
	{
		if(/^>(\S+)_(\d+)_(\d+)_(\d+)\s+(\d+)$/)
		{
			$Name = $1;
			$aa = $_;
			$bb = <INPUT>;
			$pos_format = sprintf("%08d%08d%08d%08d%s", $5, $2, $3, $4, "$aa$bb");
			
			$Name_Pos{$Name} .= "$pos_format<";
		}
	}
	close(INPUT);
	
#	@Quality_Output = ();
	
	open(OUTPUT, ">$output") || die;

	
	foreach (values (%Name_Pos))
	{
		@Pos = split(/\</, $_);
		@Pos = sort @Pos;
		$Number = @Pos;
		$i = $Number - 1;
		$j = 0;
		
#		$Current_Quality = 0;
#		$Current_Min_Quality = 10000;
#		
		$Current_Output = "";
		
		while($i >= 0)
		{
			$temp = substr($Pos[$i], 32);
			$Current_Output .= $temp;
			
#			$Current_Quality = substr($Pos[$i], 0, 8);
#			if($Current_Quality < $Current_Min_Quality)
#			{
#				$Current_Min_Quality = $Current_Quality;
#			}
			$i --;
			$j ++;
			if($j == 5)
			{
				last;
			}
		}
		print OUTPUT $Current_Output;
#		push(@Quality_Output, sprintf("%08d%s", $Current_Min_Quality, $Current_Min_Quality));
	}
#	@Quality_Output = sort @Quality_Output;
#	@Quality_Output = reverse(@Quality_Output);
#	
#	open(OUTPUT, ">$output") || die;
#	
#	foreach (@Quality_Output)
#	{
#		$output = substr($_, 8);
#		print OUTPUT $output;
#	}
	close(OUTPUT);
	
	