#!/usr/bin/perl 

($F_in,$F_out) = @ARGV;
open(FILE,"$F_in")||die "can not open $input_file\n";
open(OUT,">$F_out")||die "can not open $output_file\n";
while(<FILE>)
{
	chomp;
	if(/>(\S+)/) 
	{
		$name = $1; 
		if(defined($backup{$name})) { die"there are two $name in the fasta\n"; }
	}
	else 
	{ 
		$size{$name} += length($_);
		$backup{$name}++;
	} 
}
$name = $1; 
if(defined($backup{$name})) { die"there are two $name in the fasta\n"; }
close(FILE);

open(FILE,"$F_in");
#>0610007F07 "0610007F07",1294,"","0.884793",92,748,"" 
while(<FILE>)
{
	if(/>(\S+)/) 
	{ 
		$name = $1;
		print OUT ">$name \"$name\",$size{$name},\"\",\"\",1,$size{$name},\"\"\n";
	}
	else { print OUT; } 
}
close(FILE);
close(OUT);

