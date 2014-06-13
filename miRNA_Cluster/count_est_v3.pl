#!/usr/bin/perl -w
use strict;


if (@ARGV < 4) {
    print "perl *.pl pos_file EST_position_chr chr file_out \n";
    exit;
}
my ($file_pos,$file_est,$chr,$file_out) = @ARGV;

# 被EST完全覆盖才可以
# 2007-1-31 16:27
# 

open OUT,">$file_out";


print  "Preparing...\n";

##bin	matches	misMatches	repMatches	nCount	qNumInsert	qBaseInsert	tNumInsert	tBaseInsert	strand	qName	qSize	qStart	qEnd	tName	tSize	tStart	tEnd	blockCount	blockSizes	qStarts	tStarts
#585	330	13	0	0	2	2	3	4	-[9]	AA663731	346	1	346	chr1[14]	247249719	2802[16]	3149[17]	6	47,26,73,27,165,5,[19]	0,47,74,147,174,340,	2802,2850,2876,2951,2979,3144,[21]
#585	393	7	0	0	0	0	0	0	+	AA936549	409	9	409	chr1	247249719	4224	4624	1	400,	9,	4224,
#585	372	8	0	0	0	0	0	0	+	AA293168	380	0	380	chr1	247249719	4263	4643	1	380,	0,	4263,
#585	391	8	0	0	0	0	0	0	+	AA458890	399	0	399	chr1	247249719	4263	4662	1	399,	0,	4263,

open EST,"$file_est";
my $tmp = <EST>;
my @pos;

print  "Loading........";
while (<EST>) {
	chomp $_;
    my @s = split /\t/,$_;
#    next unless ($_ =~ /^(\W){1}\s+(\w+)\t(\w+)\t(\w+)\t(\w+)\t(\S+)\t(\S+)$/);
	my @size = split(',',$s[19]);
	my @start = split(',',$s[21]);
    
    for (my $block = 0;$block <$s[18] ;$block++) {
        push @pos,$start[$block];
        my $end = $start[$block]+$size[$block];
        push @pos,$end;
        push @pos,$s[9];
    }



}

print  " OK !\n";
#aaahsa-mir-197	chr1	+	109942763	109942837
#bbbhsa-mir-197	chr1	head+	109943313	109943387
#aaahsa-mir-554	chr1	+	149784600	149784695
#bbbhsa-mir-554	chr1	+	149785192	149785287
#aaahsa-mir-92b	chr1	+	153431296	153431391


open QUERY,"$file_pos";

while (<QUERY>) {
 	chomp $_;
    my @s = split /\s+/,$_;
    if ($s[1] eq $chr) {
#        print  "OK!!!!!\n";
        my $count = 0;
        for (my $k = 0;$k<scalar @pos ;$k=$k+3) {
#            print  "$s[2]  --$k-- $pos[$k]   $pos[$k+1]   $pos[$k+2]\n";
            if ($s[2] eq $pos[$k+2] && $s[3] >=$pos[$k] && $s[4]<=$pos[$k+1]) {
                $count++;
            }
        }
        print OUT "$_\t$count\n";
    }

}


