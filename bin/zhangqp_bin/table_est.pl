#!/usr/bin/perl -w

# 修改成对EST处理！！
# line 60
# 	$gene{$geneName}->{$exonName}->{$readName}={content=>"$readName\,est\t$overlapInReadStart\t$overlapInReadEnd\t$direction\n"}; ##### 注意这儿！！！！！！！

use strict;

die "need 1 para: $0 <linked_file_name>\n" if @ARGV!=1;
open ( IN,"< $ARGV[0]" ) || die "cannot open $ARGV[0]:$!\n" ;

# transfer linked table into my familiar format

# from:
# format: rdname to edname,edstart,edend of edgene @chr overlapS -> overlapE @read overlapInReadStart -> overlapInReadEnd &direction rddirection
#rdpaxb0_240010.y1.scf to ENSE00000839624,24047332,24047497 of ENSG00000001460,1,-1 @chr 24047332 -> 24047497 @read 138 -> 301 &direction -
#bda_86845.z1.abd to ENSE00001281633,20459989,20460730 of ENSG00000117245,1,-1 @chr 20460158 -> 20460728 @read 44 -> 573 &direction -
#--
# to:
#@ENSG00000000003,X,-1
#>ENSE00000401072,98659339,98659422
#>ENSE00000673407,98660259,98660393
#>ENSE00000673408,98660785,98660883
#>ENSE00000673409,98662032,98662106
#>ENSE00000673410,98662412,98662600
#byd_xxxx.z1.abd,genome 4 189 +
#byd_yyyy.z1.abd,genome 2 189 -
#--
#

my %gene;

# initial
open ( TAB,"< templateHumanGeneExon.index" ) || die "cannot open templateHumanGeneExon.index:$!\n";

$/="\@";
<TAB>; # pass the first \@
while ( <TAB> ) {
    chomp; # remove the trailing \@
    my @lines = split /\n/;
    my $geneName = $lines[0]; # first line is gene's name
    for (my $i=1;$i<@lines;$i++) {
	my $exonName;
	if ($lines[$i]=~/^\>(\w+,\d+\,\d+)/) {
	    $exonName=$1;
	} else {die "$lines[$i]";}
	$gene{$geneName}->{$exonName}->{""}={content=>""};
    } 
}
close TAB;

$/="\n";

# rbyd_57322.y1.abd to NM_000560_7,110740472,110741271 of NM_000560,1,1 @chr 110741157 -> 110741271 @read 471 -> 560 &direction -
# dpcxa0_079013.z1.scf to L24498_0,67518543,67523920 of L24498,1,1 @chr 67523246 -> 67523647 @read 15 -> 423 &direction -
 
 while (<IN>) {
    if (/(\S+) to (\w+\,\d+\,\d+) of (\w+\,\w+\,\-?1) \@chr \d+ \-\> \d+ \@read (\d+) \-\> (\d+) \&direction (\S)/) {
	my ($readName,$exonName,$geneName,$overlapInReadStart,$overlapInReadEnd,$direction)=
	    ($1,$2,$3,$4,$5,$6);
	$gene{$geneName}->{$exonName}->{$readName}={content=>"$readName\,est\t$overlapInReadStart\t$overlapInReadEnd\t$direction\n"}; ##### 注意这儿！！！！！！！
    }else {die "wrong line:\n$_\n"}
}
close IN;

# output:

foreach my $geneName (sort keys %gene) {
    # for every gene
    print "\@$geneName\n";
    foreach my $exonName (sort keys %{$gene{$geneName}}) {
	# for every exon
	print "\>$exonName\n";
	foreach my $readName (keys %{$gene{$geneName}->{$exonName}}) {
		print $gene{$geneName}->{$exonName}->{$readName}->{content};
	}
    }
}

# over
exit 0;
