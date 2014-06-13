#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";

#C_70872 C_51983 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_51983 100.00  17      0       0       8       24      22      6       0.008   34.2
#C_70872 C_49931 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_49931 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_47637 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_47637 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_41652 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_41652 100.00  17      0       0       8       24      22      6       0.008   34.2
#C_70872 C_41190 100.00  17      0       0       8       24      17      1       0.008   34.2
#C_70872 C_37345 100.00  17      0       0       8       24      6       22      0.008   34.2
#C_70872 C_35299 100.00  17      0       0       8       24      18      2       0.008   34.2
#C_70872 C_35299 95.00   20      1       0       2       21      20      1       0.033   32.2
#C_70872 C_30499 95.24   21      1       0       2       22      24      4       0.008   34.2
#C_70872 C_30499 100.00  17      0       0       8       24      22      6       0.008   34.2



my $hub = "0";
#my @group;
my $number;
my @nab;
my %seen;

while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    if ($s[8] <$s[9]) {
    
    if ($s[0] eq $hub) {
#        push @group,$s[1];
        unless ($s[1] eq $s[0]) {
            $seen{$s[1]} = 1;
        }
    }
    else {
        unless ($hub eq "0") {
            @nab = keys %seen;

            $number = scalar @nab;
#            $number = scalar @group;
            print OUT "$number\t$hub\t@nab\n";
        }
        %seen = ();
        $hub = $s[0];
        unless ($s[1] eq $s[0]) {
            $seen{$s[1]} = 1;
        }
#        @group = ();
#        push @group,$s[0];
#        push @group,$s[1];
#        $last = $s[0];
    }
    }

}


            @nab = keys %seen;

            $number = scalar @nab;
#            $number = scalar @group;
            print OUT "$number\t$hub\t@nab\n";



