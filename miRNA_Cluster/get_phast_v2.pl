#!/usr/bin/perl -w
use strict;
# 
# 2006-12-7 23:29
# 每次读进去一个染色体数据，对全部6个位置文件进行处理
# 
# v2 2006-12-27 11:55
# 改进 分块做，保证能跑动
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
my $new_start;
my $cutoff;

my $average_score;
my $count = 0;
while (<PHAST>) {
    chomp;
    if ($_=~/start=(\d+)\sstep=1/) {
        $start = $1;
        if ($start<50000000) {
            $new_start = $start;
            $cutoff = 1;

        }
        elsif ($start<100000000) {
           # print  "100000000\n";
            if ($cutoff == 1) {
            print  "1\n";
               &output(\@score,$cutoff);
               @score = ();
                $cutoff = 2;
           }
            $new_start = $start - 50000000;
        }
        elsif ($start<150000000) {
            if ($cutoff == 2) {
            print  "2\n";
               &output(\@score,$cutoff);
               @score = ();
                $cutoff = 3;
           }
            $new_start = $start - 100000000;
        }
        elsif ($start<200000000) {
            if ($cutoff == 3) {
            print  "3\n";
               &output(\@score,$cutoff);
               @score = ();
                $cutoff = 4;
           }
            $new_start = $start - 150000000;
        }

        else {
            if ($cutoff == 4) {
            print  "4\n";
                 &output(\@score,$cutoff);
                 @score = ();
                $cutoff = 5;
            }
            $new_start = $start - 200000000;            
        }
    }
    elsif ($_=~/chrom/) {
        print  "note!\n$_\n";
    }
    else {
        $score[$new_start] = $_;
        $new_start++;
    }

}
print  "$cutoff\n";
&output(\@score,$cutoff);


sub output {
    my ($ref_score,$cutoff) = @_;
    #print  "a\n";

    my $left;
    my $right;
    $left = ($cutoff-1)*50000000;
    $right = $cutoff*50000000;



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
	my $file_out = $file.".phast.".$chr.".".$cutoff;
	open OUT,">$file_out";
print  "$file_out\n";

	my $sum;

	while (<POS>) {
		chomp;
		my @s =split /\t/,$_;
        
		if ($s[1] eq $chr) {
        if ($s[3]>=$left && $s[4]<$right) {
			$sum = 0;
#            print  "b\n";
			for (my $k=$s[3]-$left;$k<=$s[4]-$left ;$k++) {
				if ( !defined $$ref_score[$k] ) {
					$score[$k] = 0;
				}
				$sum = $sum + $$ref_score[$k];
			}
			$average_score = $sum/($s[4]-$s[3]+1);
			print OUT "$_\t$average_score\n";
        }
		}

        }

	}
	close OUT;

}

