#!/usr/bin/perl -w
use strict;

if (@ARGV < 3) {
    print "perl *.pl file_in file_out file_log\n";
    exit;
}
my ($file_in,$file_out,$file_log) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";
open LOG,">$file_log";

#
#N_1422721       chr1    -       9899931 9899952
#N_3028645       chr1    -       9900002 9900027
#NE_230386       chr1    -       9900007 9900032
#NE_141063       chr1    -       9900609 9900632
#NE_141064       chr1    -       9900663 9900691
#N_886818        chr1    -       9900700 9900725
#NE_319785       chr1    -       9900712 9900737
#NE_261499       chr1    -       9901559 9901586
#NE_121926       chr1    -       9901589 9901617
#N_1422726       chr1    -       9901619 9901640
#N_1422727       chr1    -       9901661 9901683
#N_3028647       chr1    -       9901695 9901716
#N_3028648       chr1    -       9902419 9902442
#N_1422728       chr1    -       9902426 9902450
#N_1422729       chr1    -       9902460 9902484
#NE_92360        chr1    -       9902485 9902509
#


my $last_start = 0;
my $last_end = 0;
my $last_chr = "0";
my $last_strain = "0";
my $size;
my $length;
my $all_length = 0;
my @last_cluster;
my $cluster = 0;
while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    if ($s[1] ne $last_chr || $s[2] ne $last_strain ||$s[3] > $last_end) { # another cluster 
        $size = @last_cluster;
        $length = $last_end-$last_start+1;
        $all_length = $all_length+$length;
        if ($last_chr ne "0") {
                $cluster++;
                print OUT "C_$cluster\t$last_chr\t$last_strain\t$last_start\t$last_end\t$length\t$size\t@last_cluster\n";
        }
        $last_start = $s[3];
        $last_end = $s[4];
        $last_chr = $s[1];
        $last_strain = $s[2];
        @last_cluster = ();
        push @last_cluster, $s[0];

    }
    else { # have overlap 
        if ($s[4]>$last_end) {
            $last_end = $s[4];
        }
        push @last_cluster,$s[0];
    }
}
        $size = @last_cluster;
        $length = $last_end-$last_start+1;
        $all_length = $all_length+$length;
        $cluster++;
                print OUT "C_$cluster\t$last_chr\t$last_strain\t$last_start\t$last_end\t$length\t$size\t@last_cluster\n";


print LOG "all_length = $all_length\n";
