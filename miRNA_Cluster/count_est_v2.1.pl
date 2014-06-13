#!/usr/bin/perl -w
if (@ARGV < 3) {
    print "perl *.pl pos_file EST_position file_out \n";
    exit;
}
my ($file_pos,$file_est,$file_out) = @ARGV;

# 被EST完全覆盖才可以
# 2007-1-31 16:27
# 

open OUT,">$file_out";


my %query;
my %est_count;
open(QUERY, shift);
my $tmp = <QUERY>;

open QUERY,"$file_pos";
#aaahsa-mir-197	chr1	+	109942763	109942837
#bbbhsa-mir-197	chr1	+	109943313	109943387
#aaahsa-mir-554	chr1	+	149784600	149784695
#bbbhsa-mir-554	chr1	+	149785192	149785287
#aaahsa-mir-92b	chr1	+	153431296	153431391


for(<QUERY>) {
 	chomp $_;
	my @tmp = split("\t",$_);
	push(@{$query{$tmp[1]}}, {'name'=>$tmp[0],'start'=>$tmp[3],'end'=>$tmp[4],'strand'=>$tmp[2]});
	$est_count{$tmp[0]} = 0;
}

##bin	matches	misMatches	repMatches	nCount	qNumInsert	qBaseInsert	tNumInsert	tBaseInsert	strand	qName	qSize	qStart	qEnd	tName	tSize	tStart	tEnd	blockCount	blockSizes	qStarts	tStarts
#585	330	13	0	0	2	2	3	4	-[9]	AA663731	346	1	346	chr1[14]	247249719	2802[16]	3149[17]	6	47,26,73,27,165,5,[19]	0,47,74,147,174,340,	2802,2850,2876,2951,2979,3144,[21]
#585	393	7	0	0	0	0	0	0	+	AA936549	409	9	409	chr1	247249719	4224	4624	1	400,	9,	4224,
#585	372	8	0	0	0	0	0	0	+	AA293168	380	0	380	chr1	247249719	4263	4643	1	380,	0,	4263,
#585	391	8	0	0	0	0	0	0	+	AA458890	399	0	399	chr1	247249719	4263	4662	1	399,	0,	4263,

open EST,"$file_est";
$tmp = <EST>;
for(<EST>) {
	chomp $_;
    my @s = split /\t/,$_;
#    next unless ($_ =~ /^(\W){1}\s+(\w+)\t(\w+)\t(\w+)\t(\w+)\t(\S+)\t(\S+)$/);
	my @size = split(',',$s[19]);
	my @start = split(',',$s[21]);
	foreach my $block (0..($s[18] - 1)) {
		foreach my $target (@{$query{$s[14]}}) {
			$est_count{$target->{'name'}} += 1 if ($s[9] eq $target->{'strand'} && $target->{'start'} >=$start[$block]  && $target->{'end'} <= ($start[$block] + $size[$block]) );
		}
	}
}

print OUT "$_\t$est_count{$_}\n" for (keys(%est_count));
