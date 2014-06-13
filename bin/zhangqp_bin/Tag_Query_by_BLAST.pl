#!/usr/local/bin/perl -w
#Description: This program is to make Query Tags of BLAST.
#Author: Huang Xiangang

$Version = "Version: 1.0"; #Date: 2002-11-13

use Getopt::Std;
getopts "i:q:";

print "\n**********************\nAuthor: Huang Xiangang\n$Version\n**********************\n";

if(!defined $opt_i)
{
	die "
	***************************************************************************
	Usage: Tag_Query_by_BLAST.pl -i BLAST_Index_File [-q Query_Tags]
	-i: BLAST_Index_File
	-q: Query_Tags (default BLAST_Index_File.tag)
	***************************************************************************
	\n";
}

$BLAST_Index_File = $opt_i;
$Query_Tags       = (defined $opt_q)? $opt_q : "$BLAST_Index_File.tag";

$Start_Time = `date`;
chomp($Start_Time);

	#############################
	
	open(BLAST_INDEX, "$BLAST_Index_File") || die;
	
	%Query_X_Y = ();
	%Query_Letter = ();	
	<BLAST_INDEX>; #skip the first line
	
	while(<BLAST_INDEX>)
	{
		chomp;
		
		if(/^\s*(.+)/)
		{
			@elements = split(/\s+/, $1);
			$X = $elements[2] - 1;
			$Y = $elements[3] - 1;
			$Query_X_Y{$elements[0]} .= "$X $Y ";
			$Query_Letter{$elements[0]} = $elements[1];
		}
	}
		
	close(BLAST_INDEX);
	
	#############################
	
	print "Printing Query Tags ...\n";
	
	open(QUERY_TAGS, ">$Query_Tags") || die;
	
	while(($Query_Name, $X_Y) = each (%Query_X_Y))
	{
		@Current_Query_X_Y = split(/ /, $X_Y);
		
		$Current_Query_Letter = $Query_Letter{$Query_Name};
		
		@Current_Query_Tags = ();
		
		for($i = 0; $i < $Current_Query_Letter; $i ++)
		{
			push(@Current_Query_Tags, 0);
		}
		
		$Number = @Current_Query_X_Y;
		
		$i = 0;
		
		while($i < $Number)
		{
			$X = $Current_Query_X_Y[$i];
			$Y = $Current_Query_X_Y[$i + 1];
			
			for($j = $X; $j <= $Y; $j ++)
			{
				$Current_Query_Tags[$j] ++;
			}
			$i += 2;
		}
		$Current_Query_Tags = join(" ", @Current_Query_Tags);
		print QUERY_TAGS ">$Query_Name $Current_Query_Letter\n";
		print QUERY_TAGS "$Current_Query_Tags\n";
	}
	close(QUERY_TAGS);
	
################################
		
$End_Time = `date`;
chomp($End_Time);

print "\n
	Congratulations! Tag_Query_by_BLAST.pl done!\n
	----------------------------------------
	Start_Time: $Start_Time
	End_Time:   $End_Time
	----------------------------------------
	n";