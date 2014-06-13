#!/usr/local/bin/perl

#Author: Huang Xiangang

#Created by 2003-9-01
#Updated by 2003-9-09
#Updated by 2003-9-15
#Updated by 2003-9-25
#Updated by 2003-9-29
#Updated by 2003-9-30

use strict;
use warnings;
use Getopt::Long;

my %Opts;

GetOptions(\%Opts,"s=s", "m=i", "o=s", "h|help!");

my $Usage = <<"USAGE";

PROGRAM
	$0
OPTIONS
	-s All_Scoring     (Scoring Format)
	-m Min_Relations   (default 2)
	-o Output_Grouping (Grouping Format)
USAGE

die $Usage if (!exists($Opts{s}) || !exists($Opts{o}));
die $Usage if (exists($Opts{m}) and $Opts{m} < 1);

my $All_Scoring     = $Opts{s};
my $Min_Relations   = exists($Opts{m}) ? $Opts{m} : 2;
my $Output_Grouping = $Opts{o};

print "Loading data ...\n";

open(SCORING, "$All_Scoring") || die;

my %CC_Relations = ();
my %CC_Info = ();
my %New_Contigs = ();

my %C_C = ();
my %Grouped_Contigs = ();

while(<SCORING>)
{
	chomp;
	my @Elements = split;

	$CC_Relations{"$Elements[0] $Elements[1]"} = $Elements[4];
	$CC_Relations{"$Elements[1] $Elements[0]"} = $Elements[4];

	$CC_Info{"$Elements[0] $Elements[1]"} = join(" ", @Elements[2..6]);

	if($Elements[4] >= $Min_Relations)
	{
		$C_C{$Elements[0]}->{$Elements[1]} = 1;
		$C_C{$Elements[1]}->{$Elements[0]} = 1;

		$Grouped_Contigs{$Elements[0]} = 1;
		$Grouped_Contigs{$Elements[1]} = 1;
	}
	else
	{
		if(!exists($Grouped_Contigs{$Elements[0]}))
		{
			$New_Contigs{$Elements[0]} = 1;
		}
		if(!exists($Grouped_Contigs{$Elements[1]}))
		{
			$New_Contigs{$Elements[1]} = 1;
		}
	}
}

close(SCORING);

my @Grouped_Contigs = keys(%Grouped_Contigs);
my $Scaffold_Number = 0;

my @ScaffoldNo_Contigs = ();

foreach my $Current_Contig (@Grouped_Contigs)
{
	if(exists($Grouped_Contigs{$Current_Contig}))
	{
		my %Current_Grouped_Contigs = ();
		$Current_Grouped_Contigs{$Current_Contig} = 1;

		while(1)
		{
			my $Exit_Loop = 1;
			foreach my $Current_Contig (keys(%Current_Grouped_Contigs))
			{
				if(exists($C_C{$Current_Contig}))
				{
					foreach (keys(%{$C_C{$Current_Contig}}))
					{
						$Current_Grouped_Contigs{$_} = 1;
					}
					delete($C_C{$Current_Contig});

					$Exit_Loop = 0;
				}
			}
			if($Exit_Loop == 1)
			{
				last;
			}
		}

		foreach (keys(%Current_Grouped_Contigs))
		{
			$ScaffoldNo_Contigs[$Scaffold_Number]->{$_} = 1;
			delete($Grouped_Contigs{$_});
		}

		$Scaffold_Number ++;
	}
}

##########################

print "Clustering ...\n";

my $New_Contig_Number = 0;

foreach my $Current_New_Contig (keys(%New_Contigs))
{
	$New_Contig_Number ++;
	if($New_Contig_Number % 100 == 0)
	{
		print "Clustering New Contig$New_Contig_Number ...\n";
	}

	my @Current_ScaffoldNo_United = ();

	for(my $i = 0; $i < $Scaffold_Number; $i ++)
	{
		if($ScaffoldNo_Contigs[$i] == 0)
		{
			next;
		}

		my $Current_Total_Relations = 0;

		foreach (keys(%{$ScaffoldNo_Contigs[$i]}))
		{
			if(exists($CC_Relations{"$Current_New_Contig $_"}))
			{
				$Current_Total_Relations += $CC_Relations{"$Current_New_Contig $_"};
			}
		}

		if($Current_Total_Relations >= $Min_Relations)
		{
			push(@Current_ScaffoldNo_United, $i);
		}
	}

	if(@Current_ScaffoldNo_United)
	{
		my $First_ScaffoldNo_United = shift(@Current_ScaffoldNo_United);
		$ScaffoldNo_Contigs[$First_ScaffoldNo_United]->{$Current_New_Contig} = 1;

		foreach my $Current_ScaffoldNo (@Current_ScaffoldNo_United)
		{
			foreach (keys(%{$ScaffoldNo_Contigs[$Current_ScaffoldNo]}))
			{
				$ScaffoldNo_Contigs[$First_ScaffoldNo_United]->{$_} = 1;
			}
			$ScaffoldNo_Contigs[$Current_ScaffoldNo] = 0;
		}
	}
}

##########################

print "Printing Report ...\n";

open(OUTPUT, ">$Output_Grouping") || die;

my $Current_Scaffold_Number = 0;

for(my $i = 0; $i < $Scaffold_Number; $i ++)
{
	if($ScaffoldNo_Contigs[$i] == 0)
	{
		next;
	}

	my @Current_ScaffoldNo_Contigs = keys(%{$ScaffoldNo_Contigs[$i]});
	my $Current_Number_of_Contigs = scalar(@Current_ScaffoldNo_Contigs);

	$Current_Scaffold_Number ++;

	print OUTPUT ">group$Current_Scaffold_Number\n";

	for(my $j = 0; $j < $Current_Number_of_Contigs - 1; $j ++)
	{
		for(my $k = $j + 1; $k < $Current_Number_of_Contigs; $k ++)
		{
			my $CC_1 = "$Current_ScaffoldNo_Contigs[$j] $Current_ScaffoldNo_Contigs[$k]";
			my $CC_2 = "$Current_ScaffoldNo_Contigs[$k] $Current_ScaffoldNo_Contigs[$j]";

			if(exists($CC_Info{$CC_1}))
			{
				print OUTPUT "$CC_1\t$CC_Info{$CC_1}\n";
			}
			elsif(exists($CC_Info{$CC_2}))
			{
				print OUTPUT "$CC_2\t$CC_Info{$CC_2}\n";
			}
		}
	}
}

close(OUTPUT);
