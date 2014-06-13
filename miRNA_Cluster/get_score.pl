#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
	print "perl *.pl file_in file_out \n";
	exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";

#>5
#AACAUGAGUGAGUGAAUGGUGUUUGCUCUUUUUUUGGUAAAGGUCCCAGGGGUUGUCGGGUACACAGGUCCUGUCUUUGGCCAUAAGCAAACUGAAAUGAGGCUUGGUCUCCUUCCCAGGAUCCCACACCAUGCCUCACAUGGUAGACCCCAGUGGGAAGUAUGUGACUGCCUGACUCAGGUGCCUCUCGUGGUCCAAGCCAUCCCUGCCCUGUCCCUUCCCUGGUUGUCGCCAGACCUGGAGCCCCUGC
#..((.(((.(((..(((...)))..)))..))).))..........((((((((.((((((...((((...((.(((.((((((..(((..((((..(.((((..((((.((((((((((.((....((((((.....)))))).)).))...)))))))...).)))))))).).)))).))).....)))))).))).))..)))).............(((((....))))))))))))))))))). (-81.10)
#>6
#UCCUUCACUUUGCAGCCUCCUCUUCUGUCACCAACUGGGAACCCACCUCUUCCUGAAAGUCCUCCCCCACUGACUCACCGGCUUGCCCCGAGUUUGUCAAGAAUGUCCCAGUAACCAGGGGACACACAGUGAAGUGACUGAGGGGUUACCUUGGAGUUGAUGCCUUGGCUCAGAUCCAGCUCCCCUGUUUUCUUCCUCUGUAACCUUGGGCAACCCAACCCCUCUAAGCCUCGGUGUUCUCAUUUGUGAA
#....((((...((((.........))))((((.(((((((.......((.....))..............((((..(((((......))).))..))))......)))))))....(((((....((((.((((.(((..(((((.....(((((.((((.((....)))))).)))))..))))))))..))))..))))......((....))...))))).........)))).........)))). (-69.90)



while (<IN>) {
    chomp;
    unless ($_=~/^>/ || $_=~/A|C|T|G/) {
		if ($_=~/.*\(-(\d+\.\d+)\)/) {
			my $score = $1;
			print OUT "$score\n";
		}
    }
}



