#!/usr/bin/perl
#用于寻找在人，鼠，狗，麂子中共有的repeat
if (@ARGV<5) {
	print  "programm human mouse dog muntjac file_out \n";
	exit;
}
($human_in,$mouse_in,$dog_in,$muntjac_in,$file_out) =@ARGV;

open HUMAN,"$human_in" || die"$!";
open MOUSE,"$mouse_in"|| die "$!";
open DOG,"$dog_in" || die "$!";
open MUNTJAC,"$muntjac_in"|| die "$!";
open OUT,">$file_out" || die"$!";
#ARLTR2   
#Arthur1  
#BLACKJACK
#BOV-A2   
#BTLTR1   
#Bov-B    
#Bov-tA1  
#Bov-tA2  
#Bov-tA3  
#Charlie1 
#Charlie10
#Charlie1a
#Charlie4 
#Charlie4a
#Charlie8 
while (<HUMAN>) {
	chomp;
	$human{$_}=1;
}
while (<MOUSE>) {
	chomp;
	$mouse{$_}=1;
}
while (<DOG>) {
	chomp;
	$dog{$_}=1;
}
while (<MUNTJAC>) {
	chomp;
	$muntjac{$_}=1;
}
foreach $name (keys %muntjac) {
	if (exists $human{$name} && exists $dog{$name} && exists $mouse{$name}) {
		print OUT "$name\n";
	}
}