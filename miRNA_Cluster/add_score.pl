#!/usr/bin/perl -w
use strict;


open OUT,">overlap.result.score";

open SCORE,"LR_rankList_lt30.txt";

my %score;
#N_688484	44.76084906731926074070456987206
#N_2622374	43.46069015732849989430609259685
#N_2990043	40.91587334863728480417553677166
#N_2332195	40.78814813921715073509242667825
#N_1215274	35.86280497032200611238449129969
#N_2751959	34.22966014820828596588302901347
#N_2506443	32.02690857038523033744067774327
#N_6347	30.00927926181062913806458923063

while (<SCORE>) {
    chomp;
    my @s = split /\t/,$_;
    my $name = "S_".$s[0];
    $score{$name} = $s[1];
}




open OVERLAP,"overlap.result";
#
#S_N_2723566	1
#S_N_1236035	1
#S_N_1026464	1
#S_N_1961494	1
#S_N_1455714	1
#S_N_3003605	1
#S_N_792042	1
#S_N_1815697	1
#S_N_1642942	1
#S_N_998353	1
#S_N_3306249	1
#S_N_1337543	1
#S_N_1271712	1
#S_N_2853162	1

#my %overlap;

while (<OVERLAP>) {
    chomp;
    my @s =split /\t/,$_;
#    $overlap{$s[0]} = $s[1];
    if (exists $score{$s[0]}) {
        print OUT "$s[0]\t$score{$s[0]}\n";
    }
    else {
        print  "$s[0]\n";
    }
}


