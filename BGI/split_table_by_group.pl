#!/usr/local/bin/perl

use strict;
use Getopt::Long;


my %opts;

GetOptions(\%opts,"i:s","g:s","o:s","help");


if(!defined($opts{i}) || !defined($opts{g}) || !defined($opts{o}) || defined($opts{help}) ){
	
	Usage();
	
}

my $input=$opts{i};
my $group=$opts{g};
my $pre=(split(/\//,$input))[-1];
my $post=(split(/\./,$pre))[-1];
my $out_num=0;

my $all_line=CountLine($input);
my $every=int($all_line/$group+0.5);
#print $every,"\n";
my $num=0;


open (IN,$input)||die"input error [$input]\n";
while(<IN>){
	if ($num % $every == 0 && $out_num < $group) {
		
		if($num == $every) { 
			print "$pre\_$out_num\.$post	$num\n"; 
		}
		close(OUT);
		$out_num++;
		$num = 0;
		open(OUT,">$pre\_$out_num\.$post");
	}
	$num++;
	print OUT;
}
print "$pre\_$out_num\.$post	$num\n";
close IN;



sub CountLine() {
	my ($in)=@_;
	
	my $line=`wc $in`;
	$line=~s/^\s+//;
	$line=(split(/\s+/,$line))[0];
	
	print $line,"\n";
	
	return $line;
}
	

sub Usage #help subprogram
{
    print << "    Usage";

	Description :
	
		Function!

	Usage: $0 <options>

		-i             Path/input_file , must be given (string)

		-o            Cutoff output
		
		-h or -help    show help , have a choice

    Usage

	exit(0);
};		
