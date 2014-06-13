#!/usr/bin/perl
#this script is for calculating the length of a batch of fasta files
open (IN,"$ARGV[0]") || die;
while (<IN>) {
	if ($_=~/>/) {
		$id =(split(/\s+/,$_))[0];
		$id =(split(/>/,$id))[1];
		next;
	}
	else{
	$hash{$id}.=$_;
	}

}

	foreach $ID(keys %hash) {
	print $ID,"\n";
	$length=length($hash{$ID});
	$total_length+=$length;
	print $length,"\n";
}
print "\n Total_Length=$total_length\n";