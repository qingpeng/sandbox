#!/usr/bin/perl -w
use strict;


# add position
# 2007-9-17 11:08
# Ö»±£ÁôuniqueµÄ
# 2007-9-19 13:50
# 


if (@ARGV < 3) {
    print "perl *.pl file_pos file_in file_out \n";
    exit;
}
my ($file_pos,$file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";


my %pos;

open POS,"$file_pos";
#
#S_N_5	chr20	+	32543832	32543853
#S_N_6	chr5	+	90214204	90214225
#S_N_7	chr10	-	87581587	87581608
#S_N_8	chr1	+	10505245	10505267
#S_N_9	chr11	+	9466881	9466902
#S_N_10	chr21	+	37768235	37768256

#N_3082185	chr10	-	100163425	100163446
#N_3071412	chr10	-	100178613	100178634
#N_2302647	chr10	-	100178622	100178646
#N_1170177	chr10	-	100178623	100178649
#N_947597	chr10	-	100178627	100178649

while (<POS>) {
    chomp;
    my @s = split /\t/,$_;

    $pos{$s[0]} = $_;
}



#
#N_2751959	34.22966014820828596588302901347
#N_2506443	32.02690857038523033744067774327
#N_6347	30.00927926181062913806458923063
#N_3055263	29.35484318622670716041082594996
#N_2489447	29.35484318622670716041082594996


my $newid;
while (<IN>) {
    chomp;
    my @s =split /\t/,$_;
    if (exists $pos{$s[0]}) {
        print OUT "$s[0]\t$s[1]\t$pos{$s[0]}\n";
    }

}




