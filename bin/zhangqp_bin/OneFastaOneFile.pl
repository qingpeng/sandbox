#!/usr/local/bin/perl

my $Version =  "V.1.0";
my $Author  =  "HongkunZheng";
my $Date    =  "2003-05-23";
my $Modify  =  "2003-05-24 0:38";
my $Contact =  "zhenghk\@genomics.org.cn";
#-------------------------------------------------------------------

#-------------------------------------------------------------------

use strict;
use Getopt::Long;
use Data::Dumper;


my %opts;

GetOptions(\%opts,"i:s","od:s","t:s","help");


if(!defined($opts{i}) || !defined($opts{od}) || defined($opts{help}) ){
	
	Usage();
	
}
my $input   =    defined $opts{i} ? $opts{i} : "";
my $OutDir  =    defined $opts{od} ? $opts{od} : "";
my $type    =    defined $opts{t} ? $opts{t} : ".fa";

$OutDir=~s/\/$//;
$OutDir.='/';

if (!-d $OutDir){
	system("mkdir $OutDir");
}

Head();



ReadFile2Hash($input);


sub ReadFile2Hash(){
	my ($file,$r_hash)=@_;
	
	my $tag=0;
	
	my @info=();
	open(I,$file)||die"input error [$file]\n";
	while(<I>){
		if (/^>/){
			if ($tag == 1){
				close O;
			}
			my $output=(split(/\s+/,))[0];
			$output=~s/^>//;
			$output=$OutDir.$output.$type;
			print $output,"\n";
			open(O,">$output")||die"can't create $output\n";
			print O $_;
			$tag=1;
		}
		else {
			print O $_;
		}
	}
	close O;
	close I;
}


sub Head {
	print <<"HEAD";
	
$0 $Version ($Date) - 

------------------------------------------------------------
Input file to search:        $input
Results written to:          $OutDir
Run time:                    
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

		-i             Path/input_file , must be given (string)

		-od            Output directory
		
		-h or -help    show help , have a choice

    Usage

	exit(0);
};		
