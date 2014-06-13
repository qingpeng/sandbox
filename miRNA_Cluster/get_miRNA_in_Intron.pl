#!/usr/bin/perl -w
use strict;

if (@ARGV < 3) {
    print "perl *.pl file_refGene file_miRNA file_out \n";
    exit;
}
my ($file_refGene,$file_RNA,$file_out) = @ARGV;


open REF,"$file_refGene";
open RNA,"$file_RNA";
open OUT,">$file_out";

#
##bin	name	chrom	strand	txStart	txEnd	cdsStart	cdsEnd	exonCount	exonStarts[9]	exonEnds[10]	id	name2	cdsStartStat	cdsEndStat	exonFrames
#0	NM_024763	chr1	-	67051160	67163158	67052400	67163102	17	67051160,67060631,67065090,67066082,67071855,67072261,67073896,67075980,67078739,67085754,67100417,67109640,67113051,67129424,67131499,67143471,67162932,	67052451,67060788,67065317,67066181,67071977,67072419,67074048,67076067,67078942,67085949,67100573,67109780,67113208,67129537,67131684,67143646,67163158,	0	WDR78	cmpl	cmpl	0,2,0,0,1,2,0,0,1,1,1,2,1,2,0,2,0,
#0	NM_207014	chr1	-	67075875	67163158	67075923	67163102	10	67075875,67078739,67085754,67100417,67109640,67113051,67129424,67131499,67143471,67162932,	67076067,67078942,67085949,67100573,67109780,67113208,67129537,67131684,67143646,67163158,	0	WDR78	cmpl	cmpl	0,1,1,1,2,1,2,0,2,0,
#1	NM_145243	chr1	-	58718979	58785034	58719224	58777554	9	58718979,58744319,58765520,58768860,58772212,58772417,58774772,58777054,58784962,	58719434,58744469,58765595,58768989,58772320,58772591,58775001,58777570,58785034,	0	OMA1	cmpl	cmpl	0,0,0,0,0,0,2,0,-1,
#1	NM_012102	chr1	-	8335052	8800286	8337733	8638943	24	8335052,8338065,8338746,8340842,8342410,8342758,8344409,8345329,8346702,8347392,8348458,8405373,8448571,8477709,8480051,8491272,8523859,8539120,8540063,8597206,8606955,8638618,8775049,8799805,	8337767,8338246,8338893,8341563,8342633,8344137,8344523,8345491,8346902,8347485,8348621,8405454,8448670,8477809,8480176,8491321,8523964,8539217,8540169,8597332,8607026,8639087,8775234,8800286,	0	RERE	cmpl	cmpl	2,1,1,0,2,0,0,0,1,1,0,0,0,2,0,2,2,1,0,0,1,0,-1,-1,
#1	NM_024503	chr1	-	41748271	42156782	41748708	41823055	9	41748271,41751073,41756659,41762992,41813801,41817994,41867006,41939173,42156670,	41749524,41752008,41756746,41763168,41813947,41823576,41867205,41939253,42156782,	0	HIVEP3	cmpl	cmpl	0,1,1,2,0,0,-1,-1,-1,
#1	NM_001042682	chr1	-	8335052	8406334	8337733	8346780	13	8335052,8338065,8338746,8340842,8342410,8342758,8344409,8345329,8346702,8347392,8348458,8405373,8406207,	8337767,8338246,8338893,8341563,8342633,8344137,8344523,8345491,8346902,8347485,8348621,8405454,8406334,	0	RERE	cmpl	cmpl	2,1,1,0,2,0,0,0,0,-1,-1,-1,-1,



<REF>;
my %start;
my %end;
my %strand;
my %chr;

open LOG1,">1.log";
while (<REF>) {
    chomp;
    my @s = split /\t/,$_;
    my $name = $s[1];
    my @exonStarts = split /,/,$s[9];
    my @exonEnds = split /,/,$s[10];
    my $exon_number = $s[8];
    for (my $k=1;$k<$exon_number ;$k++) {
        my $intron_name = $name."_".$k;
        $start{$intron_name} = $exonEnds[$k-1];
        $end{$intron_name} = $exonStarts[$k];
        $strand{$intron_name} = $s[3];
        $chr{$intron_name} = $s[2];
print LOG1 "$intron_name\t$start{$intron_name}\t$end{$intron_name}\t$strand{$intron_name}\t$chr{$intron_name}\n";
    }
}

###gff-version 2
###date 2007-01-31
##
## Chromosomal coordinates of Homo sapiens microRNAs
## miRNA data:       miRBase Sequence (version 9.1)
## Genome assembly:  NCBI36
##
#1	.	miRNA	1092347	1092441	.	+	.	ACC="MI0000342"; ID="hsa-mir-200b";
#1	.	miRNA	1093106	1093195	.	+	.	ACC="MI0000737"; ID="hsa-mir-200a";
#1	.	miRNA	1094248	1094330	.	+	.	ACC="MI0001641"; ID="hsa-mir-429";
#1	.	miRNA	3467119	3467214	.	-	.	ACC="MI0003556"; ID="hsa-mir-551a";
#

open LOG,">2.log";
while (<RNA>) {
    chomp;
    if ($_=~/(\w+)\t\.\tmiRNA\t(\d+)\t(\d+)\t\.\t(\S)\t\.\tACC=\"\w+\";\sID=\"(.*)\";/) {
        my $chr = "chr".$1;
        my $start = $2;
        my $end = $3;
        my $direction = $4;
        my $name = $5;
        print LOG "$chr\t$start\t$end\t$direction\t$name\n";
        foreach my $key (keys %chr) {
            if ($chr eq $chr{$key} && $direction eq $strand{$key} && $start>$start{$key} && $end <$end{$key}) {
                print OUT "$name\t$chr\t$direction\t$start\t$end\t$key\t$chr{$key}\t$strand{$key}\t$start{$key}\t$end{$key}\n";
            }
        }

    }
}

