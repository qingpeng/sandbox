#!/usr/local/bin/perl

#Author: Huang Xiangang

#Created by 2003-8-29
#Updated by 2003-9-01
#Updated by 2003-9-09
#Updated by 2003-9-15
#Updated by 2003-9-25
#Updated by 2003-12-16

use strict;
use warnings;
use Getopt::Long;

my %Opts;

GetOptions(\%Opts,"i=s", "insert=s", "o=s", "h|help!");

my $Usage = <<"USAGE";

PROGRAM
	$0
OPTIONS
	-i Phrap_List
	-insert Insert_Lib
	-o Output_File
USAGE

die $Usage if (!exists($Opts{i}) || !exists($Opts{insert}) || !exists($Opts{o}));

my $Phrap_List  = $Opts{i};
my $Insert_Lib  = $Opts{insert};
my $Output_File = $Opts{o};

print "Loading data ...\n";

my %Library_Insert_Size = ();

open(INSERT, "$Insert_Lib") || die;
while(<INSERT>)
{
	if(/^(\S+)\s+(\d+)/)
	{
		if($2 == 1)
		{
			$Library_Insert_Size {$1} = [12000, 4000];
		}
		elsif($2 == 0)
		{
			$Library_Insert_Size {$1} = [3600, 1800];
		}
	}
}

close(INSERT);

my %Read_Contig_Info;
my %Contig_Size;

open(INPUT, "$Phrap_List") || die;

while(<INPUT>)
{
	if(/^Contig/)
	{
		chomp;
		my @Temp_Elements = split;

		my $Current_Contig = $Temp_Elements[0];
		$Current_Contig =~ s/\.//;

		$Contig_Size {$Current_Contig} = $Temp_Elements[3];

		while(<INPUT>)
		{
			if(/^(C?)\s+(-?\d+)\s+(\d+)\s+([^\.]+)/)
			{
				my $Current_Strand;

				if($1 eq "C")
				{
					$Current_Strand = 'C';
				}
				else
				{
					$Current_Strand = 'U';
				}

				$Read_Contig_Info {$4} .= "$Current_Contig $Current_Strand $2 $3 ";
			}
			elsif(/^Contig/)
			{
				@Temp_Elements = split;

				$Current_Contig = $Temp_Elements[0];
				$Current_Contig =~ s/\.//;

				$Contig_Size {$Current_Contig} = $Temp_Elements[3];
			}
		}
	}
}

close(INPUT);

print "Processing Data ...\n";

my %CC_Info = ();
my %CC_Lib = ();

while((my $Read, $_) = each (%Read_Contig_Info))
{
	if($Read =~ /^([^\d]+)/)
	{
		my $Current_Lib = $1;

		if(!exists($Library_Insert_Size{$Current_Lib}))
		{
			$Library_Insert_Size{$Current_Lib} = [3600, 1800];
		}

		my @Elements = split;
		my $Number_of_Elements = @Elements;

		if($Number_of_Elements == 8)
		{
			if($Elements[0] ne $Elements[4])
			{
				$CC_Info {"$Elements[0] $Elements[4]"} .= "$Elements[1] $Elements[2] $Elements[3] $Elements[5] $Elements[6] $Elements[7] ";
				$CC_Lib {"$Elements[0] $Elements[4]"} .= "$Current_Lib ";
			}
		}
		elsif($Number_of_Elements > 8)
		{
			print "Warning: $Current_Lib\t$Read\t$_\n";
		}
	}
}

my @Output_Report = ();

foreach my $CC(sort keys(%CC_Info))
{
	my @Contigs = split(/\s+/, $CC);
	my @Elements = split(/\s+/, $CC_Info{$CC});
	my @Current_CC_Lib = split(/\s+/, $CC_Lib{$CC});

	my $Number_of_Elements = @Elements;

	my %Direction_Positive = ();
	my %Direction_Max_Distance = ();
	my %Direction_Min_Distance = ();

	for(my $i = 0, my $j = 0; $i < $Number_of_Elements; $i += 6, $j ++)
	{
		my $Current_Insert_Size_Reference = $Library_Insert_Size {$Current_CC_Lib[$j]};

		my $Current_Max_Insert_Size = $Current_Insert_Size_Reference->[0];
		my $Current_Min_Insert_Size = $Current_Insert_Size_Reference->[1];

		if($Elements[$i] eq "U")
		{
			if($Elements[$i + 3] eq "C")
			{
				my $Distance_1;
				my $Distance_2;

				if($Elements[$i + 1] < 0)
				{
					$Distance_1 = $Contig_Size {$Contigs[0]};
				}
				else
				{
					$Distance_1 = $Contig_Size {$Contigs[0]} - $Elements[$i + 1] + 1;
				}

				if($Elements[$i + 5] > $Contig_Size {$Contigs[1]})
				{
					$Distance_2 = $Contig_Size {$Contigs[1]};
				}
				else
				{
					$Distance_2 = $Elements[$i + 5];
				}

				my $Current_Max_Distance = $Current_Max_Insert_Size - $Distance_1 - $Distance_2;

				if($Current_Max_Distance >= 0)
				{
					$Direction_Positive {"U U"} ++;
					$Direction_Max_Distance {"U U"} += $Current_Max_Distance;

					my $Current_Min_Distance = $Current_Min_Insert_Size - $Distance_1 - $Distance_2;
					if($Current_Min_Distance < 0)
					{
						$Current_Min_Distance = 0;
					}
					$Direction_Min_Distance {"U U"} += $Current_Min_Distance;
				}
			}
			else
			{
				my $Distance_1;
				my $Distance_2;

				if($Elements[$i + 1] < 0)
				{
					$Distance_1 = $Contig_Size {$Contigs[0]};
				}
				else
				{
					$Distance_1 = $Contig_Size {$Contigs[0]} - $Elements[$i + 1] + 1;
				}

				if($Elements[$i + 4] < 0)
				{
					$Distance_2 = $Contig_Size {$Contigs[1]};
				}
				else
				{
					$Distance_2 = $Contig_Size {$Contigs[1]} - $Elements[$i + 4] + 1;
				}

				my $Current_Max_Distance = $Current_Max_Insert_Size - $Distance_1 - $Distance_2;

				if($Current_Max_Distance >= 0)
				{
					$Direction_Positive {"U C"} ++;
					$Direction_Max_Distance {"U C"} += $Current_Max_Distance;

					my $Current_Min_Distance = $Current_Min_Insert_Size - $Distance_1 - $Distance_2;
					if($Current_Min_Distance < 0)
					{
						$Current_Min_Distance = 0;
					}
					$Direction_Min_Distance {"U C"} += $Current_Min_Distance;
				}
			}
		}
		else
		{
			if($Elements[$i + 3] eq "C")
			{
				my $Distance_1;
				my $Distance_2;

				if($Elements[$i + 2] > $Contig_Size {$Contigs[0]})
				{
					$Distance_1 = $Contig_Size {$Contigs[0]};
				}
				else
				{
					$Distance_1 = $Elements[$i + 2];
				}

				if($Elements[$i + 5] > $Contig_Size {$Contigs[1]})
				{
					$Distance_2 = $Contig_Size {$Contigs[1]};
				}
				else
				{
					$Distance_2 = $Elements[$i + 5];
				}

				my $Current_Max_Distance = $Current_Max_Insert_Size - $Distance_1 - $Distance_2;

				if($Current_Max_Distance >= 0)
				{
					$Direction_Positive {"C U"} ++;
					$Direction_Max_Distance {"C U"} += $Current_Max_Distance;

					my $Current_Min_Distance = $Current_Min_Insert_Size - $Distance_1 - $Distance_2;
					if($Current_Min_Distance < 0)
					{
						$Current_Min_Distance = 0;
					}
					$Direction_Min_Distance {"C U"} += $Current_Min_Distance;
				}
			}
			else
			{
				my $Distance_1;
				my $Distance_2;

				if($Elements[$i + 2] > $Contig_Size {$Contigs[0]})
				{
					$Distance_1 = $Contig_Size {$Contigs[0]};
				}
				else
				{
					$Distance_1 = $Elements[$i + 2];
				}

				if($Elements[$i + 4] < 0)
				{
					$Distance_2 = $Contig_Size {$Contigs[1]};
				}
				else
				{
					$Distance_2 = $Contig_Size {$Contigs[1]} - $Elements[$i + 4] + 1;
				}

				my $Current_Max_Distance = $Current_Max_Insert_Size - $Distance_1 - $Distance_2;

				if($Current_Max_Distance >= 0)
				{
					$Direction_Positive {"C C"} ++;
					$Direction_Max_Distance {"C C"} += $Current_Max_Distance;

					my $Current_Min_Distance = $Current_Min_Insert_Size - $Distance_1 - $Distance_2;
					if($Current_Min_Distance < 0)
					{
						$Current_Min_Distance = 0;
					}
					$Direction_Min_Distance {"C C"} += $Current_Min_Distance;
				}
			}
		}
	}

	if(scalar(%Direction_Positive))
	{
		my $Total_Number = scalar @Current_CC_Lib;

		my $Current_Direction = (sort {$Direction_Positive{$b} <=> $Direction_Positive{$a}} keys(%Direction_Positive))[0];
		my $Current_Positive = $Direction_Positive{$Current_Direction};
		my $Current_Negative = $Total_Number - $Current_Positive;

		if($Current_Positive > $Current_Negative)
		{
			my $Current_Max_Average_Distance = sprintf("%.0f", $Direction_Max_Distance{$Current_Direction}/$Current_Positive);
			my $Current_Min_Average_Distance = sprintf("%.0f", $Direction_Min_Distance{$Current_Direction}/$Current_Positive);

			push(@Output_Report, "$CC\t$Current_Direction $Current_Positive $Current_Negative $Current_Min_Average_Distance $Current_Max_Average_Distance");
		}
	}
}

print "Printing Report ...\n";

open(OUTPUT, ">$Output_File") || die;
print OUTPUT join("\n", @Output_Report), "\n";
close(OUTPUT);
