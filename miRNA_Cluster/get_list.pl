#!/usr/bin/perl -w
use strict;

my $file_in = "a.all";
my $file_list = "refSeq_geneID.list";

open IN,"$file_in";
open LIST,"$file_list";

my %name;
while (<LIST>) {
    chomp;
    my @s =split /\t/,$_;
    $name{$s[0]} = $s[1];

}
while (<IN>) {
    chomp;
    my @t = split /\t/,$_;
    my $hash{$t[0]}->$t[1] =1;
}

foreach my $key (sort keys %hash) {
    my @keys = sort keys %{$hash{$key}};
    foreach my $newkey (@keys){
        print  "$key\t$name{$newkey}\n";
        
    }
}


