#!/usr/local/bin/perl  get the size of files in a dir
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use warnings;
use strict;
my @name;

print  "Input the Dir for checking size(end with \"/\")\n";
my $dir=<STDIN>;
chomp $dir;

system "ls -l $dir >du.tmp";


open(Handle , "du.tmp") || die("ERROR! Can't create du.tmp:$!\n"); 
my $size = 0;
while (my $line = <Handle>) {
	unless ($line =~/^total/) {
		
	my @section =split (" ",$line);
	$size = $size+$section[4];
	}
}	

system "rm du.tmp";
print  "Size of $dir is      $size\n";

