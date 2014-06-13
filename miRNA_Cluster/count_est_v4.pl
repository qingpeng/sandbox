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
my $max_est_size_positive = 0 ;
my $max_est_size_negative = 0;
my @pos_start_positive;
my @pos_end_positive;
my @pos_start_negative;
my @pos_end_negative;

while (<EST>) {
	chomp $_;
    my @s = split /\t/,$_;
    if ($s[9] eq "+") {
    
#    next unless ($_ =~ /^(\W){1}\s+(\w+)\t(\w+)\t(\w+)\t(\w+)\t(\S+)\t(\S+)$/);
        my @size = split(',',$s[19]);
        my @start = split(',',$s[21]);
        
        for (my $block = 0;$block <$s[18] ;$block++) {
            push @pos_start_positive,$start[$block];
            my $end = $start[$block]+$size[$block];
            if ($size[$block]>$max_est_size_positive) {
                $max_est_size_positive = $size[$block];
            }
            push @pos_end_positive,$end;
        }
    }
    else {
        my @size = split(',',$s[19]);
        my @start = split(',',$s[21]);
        
        for (my $block = 0;$block <$s[18] ;$block++) {
            push @pos_start_negative,$start[$block];
            my $end = $start[$block]+$size[$block];
            if ($size[$block]>$max_est_size_negative) {
                $max_est_size_negative = $size[$block];
            }
            push @pos_end_negative,$end;
        }
        
    }



}

my $est_count_positive = scalar @pos_start_positive;
my $est_count_negative = scalar @pos_start_negative;

print  "max_est_size_positive: $max_est_size_positive\nmax_est_size_negative: $max_est_size_negative\n";


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
        if ($s[2] eq "+") {
            
    #        print  "OK!!!!!\n";
            my $count = 0;
            my $id_region_start = 0;
            my $id_region_end = $est_count_positive;
            FOR1:for (my $k = 0;$k<$est_count_positive;$k++) {
                my $id = $id_region_start+ int(($id_region_end-$id_region_start)*0.618);
                if ($pos_end_positive[$id] <$s[3]) {
                    $id_region_start=$id+1;
                    # 取后半截
                }
                elsif ($pos_start_positive[$id]>$s[4]) {
                    $id_region_end = $id-1;
                    #取前半截
                } # 除此以外，一定是有overlap,找到位置！
                else {
                    for (my $kk = $id;$kk>=0 ;$kk--) { #  往后退
                        if ($pos_start_positive[$kk]<$s[3] - $max_est_size_positive) {# 脱离
                            last;
                        }
                        else {
                            if ($pos_end_positive[$kk] >=$s[4] && $pos_start_positive[$kk] <=$s[3]) {
                                print  "$pos_start_positive[$kk]\t$pos_end_positive[$kk]\n";
                                $count++;
                            }
                        }
                    }
                    for (my $kk = $id;$kk<$est_count_positive ;$kk++) {# 往前走
                        if ($pos_start_positive[$kk]>$s[4]) {
                            last;
                        }
                        else {
                            if ($pos_end_positive[$kk]>=$s[4] && $pos_start_positive[$kk]<=$s[3]) {
                                print  "$pos_start_positive[$kk]\t$pos_end_positive[$kk]\n";
                                $count++;
                            }
                        }
                    }
                    print OUT "$_\t$count\n";
                    last FOR1;
                }
            }
        }
        else {
    #        print  "OK!!!!!\n";
            my $count = 0;
            my $id_region_start = 0;
            my $id_region_end = $est_count_negative;
            FOR1:for (my $k = 0;$k<$est_count_negative;$k++) {
                my $id = $id_region_start+ int(($id_region_end-$id_region_start)*0.618);
                if ($pos_end_negative[$id] <$s[3]) {
                    $id_region_start=$id+1;
                    # 取后半截
                }
                elsif ($pos_start_negative[$id]>$s[4]) {
                    $id_region_end = $id-1;
                    #取前半截
                } # 除此以外，一定是有overlap,找到位置！
                else {
                    for (my $kk = $id;$kk>=0 ;$kk--) { #  往后退
                        if ($pos_start_negative[$kk]<$s[3] - $max_est_size_negative) {# 脱离
                            last;
                        }
                        else {
                            if ($pos_end_negative[$kk] >=$s[4] && $pos_start_negative[$kk] <=$s[3]) {
                                print  "$pos_start_positive[$kk]\t$pos_end_positive[$kk]\n";
                                $count++;
                            }
                        }
                    }
                    for (my $kk = $id;$kk<$est_count_negative ;$kk++) {# 往前走
                        if ($pos_start_negative[$kk]>$s[4]) {
                            last;
                        }
                        else {
                            if ($pos_end_negative[$kk]>=$s[4] && $pos_start_negative[$kk]<=$s[3]) {
                                print  "$pos_start_positive[$kk]\t$pos_end_positive[$kk]\n";
                                $count++;
                            }
                        }
                    }
                    print OUT "$_\t$count\n";
                    last FOR1;
                }
            }
            
        }
}
}


