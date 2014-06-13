#!/usr/local/bin/perl -w
#Description: This program is to generate Oligos with Hairpin and without Hairpin
#Author: Huang Xiangang
#Comments: If you feel any questions, please directly drom me an email at huangxg@genomics.org.cn. Thanks. 

$Version = "Version: 1.0"; #Date: 2002-11-11
$Version = "Version: 2.0"; #Date: 2002-11-25

use Getopt::Std;
getopts "i:";

print "\n**********************\nAuthor: Huang Xiangang\n$Version\n**********************\n";

if(!defined $opt_i)
{
	die "
	***************************************************************************
	Usage: Get_Oligo_without_Hairpin.pl -i Seq
	
	-i: Seq
	(default output: Seq.hairpin, Seq.nohairpin)
	***************************************************************************
	\n";
}

$Seq                    = $opt_i;
$Output_With_Hairpin    = "$Seq.hairpin";
$Output_Without_Hairpin = "$Seq.nohairpin";

$Start_Time = `date`;
chomp($Start_Time);

	###########################
	
	open(SEQUENCE, "$Seq") || die;
	open(WITH_HAIRPIN, ">$Output_With_Hairpin") || die;
	open(WITHOUT_HAIRPIN, ">$Output_Without_Hairpin") || die;
	
	$Sequence="";
	
	while(<SEQUENCE>)
	{
		if(/^>(.+)/)
	  	{
	  		if($Sequence ne "")
	     		{
	     			$Length_of_Sequence = length($Sequence);
	     			
	     			$Number = $Length_of_Sequence - 9;
	     			$Flag_Hairpin = 0;
	     			for($i = 0; $i < $Number; $i ++)
	     			{
	     				$Current_Fragment = substr($Sequence, $i, 10);
	     				$Complementary_Fragment = reverse($Current_Fragment);
	     				$Complementary_Fragment =~ tr/ATGC/TACG/;
	     				if($Sequence =~ /$Complementary_Fragment/)
	     				{
	     					$Next_Pos = index($Sequence, $Complementary_Fragment);
	     					if($Next_Pos >= $i + 10)
	     					{
	     						print WITH_HAIRPIN ">$Name\n";
	     						print WITH_HAIRPIN "$Sequence\n";
	     						$Flag_Hairpin = 1;
	     						last;
	     					}
	     				}
	     			}
	     			if($Flag_Hairpin == 0)
	     			{
	     				print WITHOUT_HAIRPIN ">$Name\n";
	     				print WITHOUT_HAIRPIN "$Sequence\n";
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
	
	$Length_of_Sequence = length($Sequence);
	$Number = $Length_of_Sequence - 9; # 10 - 1 = 8;
	$Flag_Hairpin = 0;
	for($i = 0; $i < $Number; $i ++)
	{
		$Current_Fragment = substr($Sequence, $i, 10);
		$Complementary_Fragment = reverse($Current_Fragment);
	     	$Complementary_Fragment =~ tr/ATGC/TACG/;
	     	if($Sequence =~ /$Complementary_Fragment/)
	     	{
	     		$Next_Pos = index($Sequence, $Complementary_Fragment);
	     		if($Next_Pos >= $i + 10)
	     		{
	     			print WITH_HAIRPIN ">$Name\n";
	     			print WITH_HAIRPIN "$Sequence\n";
	     			$Flag_Hairpin = 1;
	     			last;
	     		}
	     	}
	}
	if($Flag_Hairpin == 0)
	{
		print WITHOUT_HAIRPIN ">$Name\n";
		print WITHOUT_HAIRPIN "$Sequence\n";
	}
	
	close(SEQUENCE);
	close(WITH_HAIRPIN);
	close(WITHOUT_HAIRPIN);
	
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