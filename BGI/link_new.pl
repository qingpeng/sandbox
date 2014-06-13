#!/usr/bin/perl -w
#$Title: link2.pl
#$Version:
#$Usage:
#$Parameter:
#$Author:
#$Date:

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"l:s","t:s","o:s","c:s");
my $ver="1.0";
my $usage=<<"Usage";
    Name: $0
    Description:
    Version: $ver
    Contact: "liut AT genomics DOT org DOT cn"
    Usage: $0 [options]
    -l location file, e.g. "xx.location"
    -t gene table file, e.g. "templateHumanGeneExon.index"    
    -o out file
    -c chr
Usage

die $usage unless exists $opts{"l"} and exists $opts{"t"} and exists $opts{"o"} and exists $opts{"c"}  ;

########end of template.pl####################
open (TAB,"$opts{t}") || die;
open (LOC,"$opts{l}") || die;

#####example of gene table file###################
#
#@ENSG00000000003,X,-1
#>ENSE00000401072,98659339,98659422
#>ENSE00000673407,98660259,98660393
#>ENSE00000673408,98660785,98660883
#

# Section I
# read and divid to individual chromosomes...
print "Section I
read $opts{t}...\n";

$/="\@";
my %exonsInChr;
<TAB>; # pass the first \@
while ( <TAB> ) {
    chomp; # remove the trailing \@
    my @lines = split /\n/;
    my $geneName = $lines[0]; # first line is gene's name
    my $chrName;
    my $strand;

# >NM_004466_8,91216535,91217486
# @NM_000784,9,1
# >NM_000784_0,219849244,219849700
# >NM_000784_1,219876839,219877030
# >NM_000784_2,219879484,219879684
# >NM_000784_3,219879814,219880012
# >NM_000784_4,219880186,219880359
# >NM_000784_5,219881283,219881450   


# >U63139_25,132054086,132055671
# @U72936,X,-1
# >U72936_0,75517065,75517722
# >U72936_1,75517724,75517754
# >U72936_2,75517756,75517775
# >U72936_3,75517778,75518244
# >U72936_4,75518276,75519566
# >U72936_5,75519567,75519981
# >U72936_6,75532140,75532268
# >U72936_7,75532755,75532850
# >U72936_8,75533615,75533740
# >U72936_9,75534604,75534753


# if ($geneName=~/ENSG\d+\,(\w+)\,(\-?1)/) {
    if ($geneName=~/\w+\,(\w+)\,(\-?1)/) {
	$chrName=lc($1);
	$strand=$2;
    } else {die "$lines[0]\n";}
    if ("chr$chrName" ne "$opts{c}") {next;}
    for (my $i=1;$i<@lines;$i++) {
	my ($exonName,$exonStart,$exonEnd);
	if ($lines[$i]=~/^\>(\w+)\,(\d+)\,(\d+)/) {
	    ($exonName,$exonStart,$exonEnd)=($1,$2,$3);
	} else {die "$lines[$i]";}
	$exonsInChr{"chr$chrName"}->{$exonName}={name=>$exonName,gene=>$geneName,chr=>"chr$chrName",
					    start=>$exonStart,end=>$exonEnd,strand=>$strand};
    } 
}
close TAB;
#foreach my $chr (keys %exonsInChr) {
#    print $chr,"\n";
#    foreach my $exon (sort 
#		      { 
#			  $exonsInChr{$chr}->{$a}->{start} <=>
#			      $exonsInChr{$chr}->{$b}->{start}
#		      } keys %{$exonsInChr{$chr}}) {
#	my $ed=$exonsInChr{$chr}->{$exon};
#	print $ed->{name}," of ",$ed->{gene}," in ",$ed->{chr},
#	" from ",$ed->{start}," to ",$ed->{end},"\n";
#    }
#}
#exit;
#####example of reads' location file#####################
#
#A01.abd.ADD356            479     10 ------  488        chr15      526    46147466 ------   46147991    |-
#A02.abd                   563     51 ------  613        chr5       613    95309442 ------   95310054    |-
#A02.abd.ADD1458           653      1 ------  653        chr3       980    67750467 ------   67751446    |+
#A02.abd.ADD2332           605    146 ------  750        chr5       668    95309387 ------   95310054    |-
#
##############################################
print "Section II
read $opts{l}...\n";

$/="\n";
my %readsInChr;
while ( <LOC> ) {
    next if (/^\#/);
    chomp; # remove the trailing \n
    my ($readName,$readStart,$readEnd,$chrName,$chrStart,$chrEnd,$direction);
    if (/^(\S+)\s+\d+\s+(\d+)\s+\-+\s+(\d+)\s+(chr\S+)\s+\d+\s+(\d+)\s+\-+\s+(\d+)\s+\|([\-\+])/) {
	($readName,$readStart,$readEnd,$chrName,$chrStart,$chrEnd,$direction)=
	    ($1,$2,$3,$4,$5,$6,$7);
    } else {die "not enough:\n$_\n";}
    $chrName=lc($chrName);
    next if $chrName ne "$opts{c}";

    if ( $readStart > $readEnd or $chrStart > $chrEnd ) {
	die "upside down:\n$_\n";
    }
    $readsInChr{$chrName}->{$readName}={name=>$readName,chr=>$chrName,
					readstart=>$readStart,readend=>$readEnd,
					chrstart=>$chrStart,chrend=>$chrEnd,
					direction=>$direction};
}
close LOC;
#foreach my $chr (keys %readsInChr) {
#    print "-$chr\n";
#    foreach my $read (keys %{$readsInChr{$chr}}) {
#	my $rd=$readsInChr{$chr}->{$read};
#	print $rd->{name},"\t",$rd->{readstart}," ------ ",$rd->{readend},
#	"\t",$rd->{chr},"\t",$rd->{chrstart}," ------ ",$rd->{chrend},"\t\|",$rd->{direction},"\n";
#    }
#}
#exit;
# Section III
# Now I find the overlap...
print "Section III
finding the overlap...\n";

open ( OUT,"> $opts{o}" ) || die;

my $overlapMin = 0; # minimum overlap size of read and exon 

foreach my $chr (keys %readsInChr) {
    (print"pass $chr\n"),next unless $chr eq $opts{"c"};
    print "in $chr\n";
    # for every chromosome, I search for the overlap...
    foreach my $read (keys %{$readsInChr{$chr}}) {
	# for every read
	my $rd = $readsInChr{$chr}->{$read};
	#my $count = 0;
	# print "OOCH~~\n" if not exists $exonsInChr{$chr};
	foreach my $exon (sort 
			  { 
			      $exonsInChr{$chr}->{$a}->{start} <=>
				  $exonsInChr{$chr}->{$b}->{start}
			  } keys %{$exonsInChr{$chr}}) {
	    # search every exons in this chromosome in ORDER
	    my $ed = $exonsInChr{$chr}->{$exon};
	    #print "in\n";
	    #$count ++;
	    # if read's chrend is smaller than exon's start,
	    # then the following exons should be safely bypassed. 
	    if ($rd->{chrend} <= $ed->{start}) {
		#print $rd->{name},":",$rd->{chrstart}," >= ",$ed->{name},":",$ed->{end},"\n";
		last;
	    }
	    
	    # THEN...
	    # if read's chrstart is smaller than exon's end,
	    # there should be an overlap!

	    # $exonsInChr{$chrName}->{$exonName}={name,gene,chr,start,end,strand};
	    # $readsInChr{$chrName}->{$readName}={name,chr,readstart,readend,
	    #                                     chrstart,chrend,direction};

	    if ( $rd->{chrstart} < $ed->{end} ) {
		# sort four locs, middle two is the position of overlap!
		my @pos = sort { $a<=>$b
				 } ($rd->{chrend},$rd->{chrstart},$ed->{start},$ed->{end});
		my ($overlapS,$overlapE) = @pos[1,2];
		my ($overlapInReadStart,$overlapInReadEnd);
		# find the _relative_ position in read's own sequence
		if ( $rd->{direction} eq "+" ) {
		    # legend:
		    # rs: $rd->{readstart}
		    # ros: $overlapInReadStart
		    # roe: $overlapInReadEnd
		    # rd: $rd->{readend}
		    # cs: $rd->{chrstart}
		    # os: $overlapS
		    # oe: $overlapE
		    # ce: rd->{chrend}
		    # rs --ros---roe--- rd
		    #       |    |
		    #       |    |
		    #       |    |
		    #       |    |
		    #       |    |
		    #       |    |
		    # cs --os----oe---- ce
		    $overlapInReadStart = $overlapS + $rd->{readstart} - $rd->{chrstart};
		    $overlapInReadEnd =  $overlapE + $rd->{readend} - $rd->{chrend};
		} elsif ( $rd->{direction} eq "-" ){
		    # reverse complement
		    # legend:
		    # rs: $rd->{readstart}
		    # ros: $overlapInReadStart
		    # roe: $overlapInReadEnd
		    # rd: $rd->{readend}
		    # cs: $rd->{chrstart}
		    # os: $overlapS
		    # oe: $overlapE
		    # ce: rd->{chrend}
		    # rs --ros---roe--- rd
		    #      \     /
		    #       \   /
		    #        \ /
		    #         \
		    #        / \
		    #       /   \
		    # cs --os----oe---- ce
		    $overlapInReadStart = $rd->{readstart}+($rd->{chrend}-$overlapE);
		    $overlapInReadEnd = $rd->{readend}-($overlapS-$rd->{chrstart});
		} else {
		    die"no excuse";
		}
		if ( $overlapInReadEnd > $overlapInReadStart) {
		    # if the overlap is valid in the read's own sequence, print it!
		    print OUT
			$rd->{name}," to ",
			$ed->{name},",",$ed->{start},",",$ed->{end}," of ",
			$ed->{gene},
			" \@chr ",$overlapS," -> ",$overlapE,
			" \@read ",$overlapInReadStart," -> ",$overlapInReadEnd,
			" \&direction ",$rd->{direction},
			"\n";			
		}
	    }
	}
	#print "last $count\n";
    }
}

close OUT;

exit;
