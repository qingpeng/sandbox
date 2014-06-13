#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# select the top 3, remove the <10.

use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","o:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-i		file in 
		-o		file out
USAGE

die $usage unless $opts{"i"}and$opts{"o"};


my $inputfile = $opts{"i"};
my $outputfile = $opts{"o"};

open IN,"$inputfile" || die"can't open $inputfile:$!";
open OUT,">$outputfile" || die"can't open $outputfile:$!";


my @lines = <IN>;
my @a_fields;
my @b_fields;



my $field_0 = "";
my $field_5 = "";
my $count_line ;
for (my $k = 0;$k<scalar @lines;$k++) {
	my $line = $lines[$k];
	my @fields = split /\s+/,$line;
	if ($fields[0] ne $field_0) {
		print OUT "$line";
		$count_line =2;
		$field_5 = $fields[5];
	}
	else {
		if ($count_line<4) {
			print OUT "$line";
			$count_line ++;
		}
		else {
			if ($fields[5] > 10) {
				print OUT "$line";
			}
		}
	}
	$field_0 = $fields[0];
}