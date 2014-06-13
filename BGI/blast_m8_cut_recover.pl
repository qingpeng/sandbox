#!/usr/local/bin/perl

my $Version =  "V.1.0";
my $Author  =  "HongkunZheng";
my $Date    =  "2003-09-11";
my $Modify  =  "2003-09-11 15:15";
my $Contact =  "zhenghk\@genomics.org.cn";
#-------------------------------------------------------------------
# Due to the length sequence, To run BLAST will use many Memmery, So
# we cut sequence into pieces, then use this program to convert the 
# position to chromosome position.
#-------------------------------------------------------------------

use strict;
use Getopt::Long;
use Data::Dumper;


my %opts;

GetOptions(\%opts,"if:s","id:s","od:s","help");


if( (!defined($opts{if}) && !defined($opts{id}))  || !defined($opts{od}) || defined($opts{help}) ){
	
	Usage();
	
}
my $InFile  =    defined $opts{if} ? $opts{if} : "";
my $InDir   =    defined $opts{id} ? $opts{id} : "";
my $OutDir  =    defined $opts{od} ? $opts{od} : "";


Head();


$OutDir =~s/\/$//;


if(!-d $OutDir){
	system("mkdir $OutDir");
}


if(defined $opts{if}){
	
	open(O,">$OutDir/$InFile.con")||die"output error [$OutDir/$InFile.con]\n";
	Convert($InFile);
	close O;
	
}

if(defined $opts{id}){
	
	$InDir =~s/\/$//;
	my @InFiles = `ls $InDir`;
	chomp @InFiles;
	foreach (@InFiles){
		open(O,">$OutDir/$_.con")||die"output error [$OutDir/$_.con]\n";
		Convert("$InDir/$_");
		close O;
	}
	
}


sub Convert {
	my ($file)=@_;
	my @info=();
	open(I,$file)||die"input error [$file]\n";
	#G630063E16      chr10_120000000_45950327       94.12   34      2       0       1465    1498    412839  412872  3.4e-07 52.03
	
	while(<I>){
		chomp;
		#print $_,"\n";
		@info=split(/\s+/,$_);
		my ($chr_name,$chr_start) = (split(/\_/,$info[1]))[0,2];
		
		$info[1]=$chr_name;
		
		$info[8] += $chr_start;
		$info[9] += $chr_start;
		
		my $line = join("\t",@info);
		
		print O $line,"\n";
		
	}
	close I;
}


sub Head {
	print <<"HEAD";
	
$0 $Version ($Date) - 

------------------------------------------------------------
Input file to search:        $InFile
Input dir  to search:        $InDir
Results written to:          $OutDir
Contract:		     $Contact
------------------------------------------------------------

Running......
HEAD
}



sub Usage #help subprogram
{
    print << "    Usage";

	Description :
	
		Function!

	Usage: $0 <options>

		-if            Input File name, blast m8 format
		
		-id            Input Directory name, blast m8 format

		-od            Output Directory
		
		-h or -help    show help , have a choice

    Usage

	exit(0);
};		
