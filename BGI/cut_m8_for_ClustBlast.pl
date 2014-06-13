#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

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



my $input =$opts{"i"};
my $output =$opts{"o"};
open INPUT,"$input" || die"can't open file:$!";
open OUTPUT,">$output" || die"can't open file:$!";

while (my $line = <INPUT>) {
	$line =~ s/\s+(.*?)\s+/\t/;
	print OUTPUT "$line";
}

