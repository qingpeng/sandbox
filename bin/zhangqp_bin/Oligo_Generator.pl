#!/usr/local/bin/perl -w
#Description: This program is to generate Oligo
#Author: Huang Xiangang
#Comments: If you feel any questions, please drom me an email at huangxg@genomics.org.cn. Thanks. 

$Version = "Version: 1.0"; #Date: 2002-11-11

use Getopt::Std;
getopts "i:l:d:o:p:";

print "\n**********************\nAuthor: Huang Xiangang\n$Version\n**********************\n";

if(!defined $opt_i)
{
	die "
	***************************************************************************
	Usage: Oligo_Generator.pl -i Seq [-l Oligo_Length]
	[-d Distance_between_Oligos] [-o Output_Oligo] [-p Output_PolyN]
	
	-i: Seq
	-l: Oligo_Length (default 70)
	-d: Distance_between_Oligo (default 2)
	-o: Output_Oligo (default Seq.Oligo)
	-p: Output_PolyN (default Seq.Oligo.PolyN)
	***************************************************************************
	\n";
}


$Seq                    = $opt_i;
$Oligo_Length           = (defined $opt_l)? $opt_l : 70;
$Distance_between_Oligo = (defined $opt_d)? $opt_d : 2;
$Output_Oligo           = (defined $opt_o)? $opt_o : "$Seq.Oligo";
$Output_PolyN           = (defined $opt_p)? $opt_p : "$Seq.Oligo.PolyN";

$Start_Time = `date`;
chomp($Start_Time);
	
	###########################
	
	open(SEQUENCE, "$Seq") || die;
	open(OLIGO, ">$Output_Oligo") || die;
	open(POLYN, ">$Output_PolyN") || die;
	
	@PolyN = ("AAAAAAAAA", "TTTTTTTTT", "GGGGGGGGG", "CCCCCCCCC"); # poly (N) tract length <= 8
	
	$Sequence="";
	
	while(<SEQUENCE>)
	{
		if(/^>(\S+)/)
	  	{
	  		if($Sequence ne"")
	     		{
	     			$Sequence = uc($Sequence);
	     			$Length_of_Sequence = length($Sequence);
	     			
	     			$Oligo_Number = 1;
	     			$PolyN_Number = 1;
	     			
	     			$Number_of_Oligo = $Length_of_Sequence - $Oligo_Length + 1;
	     			for($i = 0; $i < $Number_of_Oligo; $i += $Distance_between_Oligo)
	     			{
	     				$flag_PolyN = 0;
	     				$Oligo_Sequence = substr($Sequence, $i, $Oligo_Length);
	     				for($j = 0; $j < 4; $j ++)
	     				{
	     					if($Oligo_Sequence =~ /$PolyN[$j]/)
	     					{
	     						print POLYN ">$Name\_$PolyN_Number\n";
	     						print POLYN "$Oligo_Sequence\n";
	     						$PolyN_Number ++;
	     						$flag_PolyN = 1;
	     						last;
	     					}
	     				}
	     				if($flag_PolyN == 0)
	     				{
		     				print OLIGO ">$Name\_$Oligo_Number\n" ;
		     				print OLIGO "$Oligo_Sequence\n";
		     				$Oligo_Number ++;
		     			}
			        }
			}
			$Name = $1;
			$Sequence = "";
		}
		else
		{
			chomp;
	    		$Sequence .= $_;
	    	}
	}
	close(SEQUENCE); 
	
	$Sequence = uc($Sequence);
	$Length_of_Sequence = length($Sequence);
	
	$Oligo_Number = 1;
	$PolyN_Number = 1;
	
	$Number_of_Oligo = $Length_of_Sequence - $Oligo_Length + 1;
	for($i = 0; $i < $Number_of_Oligo; $i += $Distance_between_Oligo)
	{
		$flag_PolyN = 0;
		$Oligo_Sequence = substr($Sequence, $i, $Oligo_Length);
		for($j = 0; $j < 4; $j ++)
		{
			if($Oligo_Sequence =~ /$PolyN[$j]/)
			{
				print POLYN ">$Name\_$PolyN_Number\n";
				print POLYN "$Oligo_Sequence\n";
				$PolyN_Number ++;
				$flag_PolyN = 1; 
				last;
			}
		}
		if($flag_PolyN == 0)
		{
			print OLIGO ">$Name\_$Oligo_Number\n" ;
			print OLIGO "$Oligo_Sequence\n";
			$Oligo_Number++;
		}
	}
			        
	close(OLIGO);  
	close(POLYN);

	###########################
	
$End_Time = `date`;
chomp($End_Time);

print "\n
	Congratulations! Your program done!\n
	----------------------------------------
	Start_Time: $Start_Time
	End_Time:   $End_Time
	----------------------------------------
	See you later. Wish you well!
	\n";