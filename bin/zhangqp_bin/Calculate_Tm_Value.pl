#!/usr/local/bin/perl -w
#Description: This program is to count Tm Value and the optimistic range.
#Author: Huang Guozhen
#Comments: If you feel any questions, please drom me an email at huanggz@genomics.org.cn. Thanks. 
$Version = "Version: 1.0"; #Date: 2002-11-12
use Getopt::Std;
getopts "i:o:";
print "\n**********************\nAuthor: Huang Guozhen\n$Version\n**********************\n";
if(!defined $opt_i)
{
	die "
	***************************************************************************
	Usage:
	Calculate_Tm_Value.pl -i Input_File [-o Output_File]
	
	-i: Input_File
	-o: Output_File (default: Input_File.Tm)
	***************************************************************************
	\n";
}

$Input_File  = $opt_i;
$Output_File = (defined $opt_o)? $opt_o : "$Input_File.Tm";

$Start_Time = `date`;
chomp($Start_Time);
	
	###########################


open(INPUT,"$Input_File")||die" Can not open the file";
open(OUTPUT,">$Output_File")||die"Can not write the file";

while(<INPUT>)
{
	chomp;
	if(/^>(.+)/)
	{ 
		$name=$1;
	}
	else 
	{
		$Sequence = $_;
		$l=length($Sequence);
		$Count_GC = 0;
		while($Sequence =~ /G|C/g)
		{
			$Count_GC++;
		}
		$GC_Content=$Count_GC/$l;
		$Tm = 81.5+16.6*log(0.1)/log(10)+41*($GC_Content)-500/$l;
		$Tm = sprintf("%.2f",$Tm);
		$GC = sprintf("%.4f",$GC_Content);
		print OUTPUT "$name\t$Count_GC\t$GC\t$Tm\n";
	}
}

close(INPUT);
close(OUTPUT);


