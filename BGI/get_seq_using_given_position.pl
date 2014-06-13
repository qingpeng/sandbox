#! /usr/local/bin/perl
# Copyright (c) BGI 2003
# Author:         lijun <junli@genomics.org.cn>
# Program Date:   
# Modifier:       
# Last Modified:  
# Description:  

use strict;
use Getopt::Long;
use Data::Dumper;
my $info="";
my @temp=();
my $bin=1;
my ($i,$n)=(0,0);
my $sum=0;
my $multiple=0;
my $perscripname="";
my $chr_fa="";
my %chr_fa=();
my $chr_no=0;
my ($sec, $min, $hour, $day, $mon, $year) = (); 
my $temp="";
my %opt;
GetOptions(\%opt,"s=s","o=s","p=s","r=s","help");
unless ((defined $opt{p}  and defined $opt{s} and defined $opt{o}) or defined $opt{help} ){
	&usage (); 
}

my $Time_Start = sub_format_datetime(localtime(time())); 
print "Now = $Time_Start\n";
print "\n";

if(! -e $opt{p}){
	die"can't open $opt{p}\n";
}
if(! -e $opt{o}){
	`mkdir $opt{o}`;
}


my $seq_name="";
open CHRO,"$opt{s}" or die "can't open $opt{s}:$!";
while(<CHRO>){
	chomp; 
	if(/^\>/){
		@temp=split(/\s+/,$_);
		@temp=split(/\>/,$temp[0]);
		$seq_name=$temp[1];	
		#print "$seq_name\n";
		next;		
	}
	$chr_fa{$seq_name}.=$_;
	
}
close CHRO; 

open IN,"$opt{p}" or die "can't open $opt{p} :$!";
open RUN_LIST,">$opt{r}";
my @temp2=();
while($info=<IN>){
	chomp $info;
	@temp=split(/\t/,$info);
	#print "$temp[0]\n";

	
	open OUT,">$opt{o}/$temp[0]_$temp[1]_$temp[3]_$temp[4].cut";
	print OUT ">$temp[0]_$temp[1]_$temp[3]_$temp[4]\n";
	print RUN_LIST "$temp[0]\t$temp[0]_$temp[1]_$temp[3]_$temp[4]\n";
	if($temp[3]<0){
		$temp[3]=1;
	}
	my $entry_all=substr($chr_fa{$temp[1]},$temp[3]-1,($temp[4]-$temp[3]+1));
	$entry_all=uc$entry_all;
	#print OUT "$entry_all\n";
	my $multiple=int((length$entry_all)/60*1.0000001);
	my $residual=(length$entry_all)%60;
	if($temp[2]eq"-"){
		$_=$entry_all;
		tr/ATGC/TACG/;
		$entry_all=$_;
		$entry_all=reverse($entry_all);
		#print OUT "$entry_all\n";
	}	
	for($i=0;$i<=$multiple-1;$i++){
		$temp=substr($entry_all,$i*60,60);
		print OUT "$temp\n";
	}
	if($residual==0){
		next;
	}
	$temp=substr($entry_all,$multiple*60,$residual);
	print OUT "$temp\n";
	#print OUT "$entry_all\n";
	close OUT;
	#system("formatdb -i cut_seq/$temp[0]_$temp[1]_$temp[3].cut -p F ");
	
		
	
}

my $Time_End = sub_format_datetime(localtime(time())); 
print "Running from [$Time_Start] to [$Time_End]\n";
print("............................................................\n");
sub usage{
    warn <<"usage"; 
    
******* This is a usage document.********

 	Description:Cut sequence using given position information.A runlist file  can also be created at the same time.

	Usage: perl $0 <options>
	
    	Options
 	           -p		Path/position-information-file, must be given
    		   
    		   -s		Path/sequence-file(fasta), must be given 
    		   
    		   -o		Output directory, must be given
    		   
    		   -r		Path/runlist file 
    		   
    		   -help	Display this usage information

****************************************

usage
    exit(1);
}

sub sub_format_datetime
{
	($sec, $min, $hour, $day, $mon, $year) = @_[0..5]; 
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}