#!/usr/local/bin/perl -w
#Description: This program is to make tags of Queries and Targets from the results of BLAT.
#Author:ChenChen

$Version = "Version: 1.0"; #Date: 2002-10-29
$Version = "Version: 2.0"; #Date: 2002-11-01

use Getopt::Std;
getopts "i:o:t:";

print "\n**********************\nAuthor:ChenChen\n$Version\n**********************\n";

if(!defined $opt_i)
{
	die "
	***************************************************************************
	Usage: less_base_deleted.pl -i Oligo_File [-o Deleted_less_N_File] [-t N_File] 
	-i: Oligo_File
	-o: Deleted_Few_N_File (default Deleted_less_N)
	-t: N_File (default N_File)
	***************************************************************************
	\n";
}

$Oligo_File   = $opt_i;
$Less_N       = (defined $opt_o)? $opt_o : "$Oligo_File\_less_N";
$N_File       = (defined $opt_t)? $opt_t : "$Oligo_File\_N_File";


open (FD,$Oligo_File)||die " can not open the file";
while(<FD>)
{
	if(/^>(\S+)/)
	{
		$name=$1;
		$hash1{$name}=$_;
	}
	else
	{
		chomp $_;
		$hash{$name}=$_;
		
	}
}
close(FD);
open (ED,">$Less_N")||die " can not open";
open (DD,">$N_File");
foreach $word (sort keys(%hash))
{
	$min=0;$count_a = 0;$count_t = 0;$count_c = 0;$count_g = 0;
	@seq=split(//,$hash{$word});
	foreach $key(@seq)
	{
		
		if($key eq "A"){$count_a ++;}
		elsif($key eq "C"){$count_c ++;}
		elsif($key eq "G"){$count_g ++;}
		elsif($key eq "T"){$count_t ++;}
#		print "$seq[$key]\n";
	}
	#print "$count_c";	
	$min = ($count_a < $count_c)? $count_a : $count_c;
	#print "$min\n";
	$min = ($min < $count_g)? $min : $count_g;
	$min = ($min < $count_t)? $min : $count_t;
	#print $min;
	if($min > 5){print DD "$hash1{$word}$hash{$word}\n";}
	else {print ED "$hash1{$word}$hash{$word}\n";}
}
close(DD);
close(ED);
