#!/usr/bin/perl -w
use strict;
# 
# 2006-12-7 23:29
# 每次读进去一个染色体数据，对全部6个位置文件进行处理
# 

if (@ARGV < 2) {
	print "perl *.pl file_phast chr  \n";
	exit;
}
my ($file_phast,$chr) = @ARGV;

open PHAST, "$file_phast"     or die "Can't open $file_phast $!";



#fixedStep chrom=chr1 start=1025 step=1
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#0.000
#

my @score;
my $start;
my $average_score;

while (<PHAST>) {
    chomp;
    if ($_=~/start=(\d+)\sstep=1/) {
        $start = $1;
    }
    elsif ($_=~/chrom/) {
        print  "note!\n$_\n";
    }
    else {
        $score[$start] = $_;
        $start++;
    }
}

print  "Data loaded successfully\n";

#hg17_refGene_NM_000046	chr17	-	41544540	41544593
#hg17_refGene_NM_000046	chr17	-	9312342	9312395
#hg17_refGene_NM_000046	chr19	+	43161812	43161865
#hg17_refGene_NM_000046	chr19	+	43320388	43320438
#hg17_refGene_NM_000046	chr19	-	9867501	9867552
#hg17_refGene_NM_000046	chr20	+	48578433	48578486

my $a = "all.negative.ge30lt50.control_a.genome_pos.unique";
my $b = "all.negative.ge30lt50.genome_pos.unique";
my $c = "all.negative.ge50.control_a.genome_pos.unique";
my $d = "all.negative.ge50.genome_pos.unique";
my $e = "all.negative.lt30.control_a.genome_pos.unique";
my $f = "all.negative.lt30.genome_pos.unique";

my @file = ($a,$b,$c,$d,$e,$f);

foreach my $file (@file) {
	open POS,"$file";
	my $file_out = $file.".phast.".$chr;
	open OUT,">$file_out";


	my $sum;

	while (<POS>) {
		chomp;
		my @s =split /\t/,$_;
		if ($s[1] eq $chr) {
			$sum = 0;
			for (my $k=$s[3];$k<=$s[4] ;$k++) {
				if ( !defined $score[$k] ) {
					$score[$k] = 0;
				}
				$sum = $sum + $score[$k];
			}
			$average_score = $sum/($s[4]-$s[3]+1);
			print OUT "$_\t$average_score\n";
		}

	}
	close OUT;

}

