#!/usr/local/bin/perl  formatdb in batch 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use warnings;
use strict;
my @name;

print  "Input the Dir you want to cat(end with \"/\")\n";
my $dir=<STDIN>;
chomp $dir;
print  "Name of the catted file\n";
my $newname = <STDIN>;
chomp $newname;

opendir  (DIR,"$dir" )|| die"can't open $dir:$!";
 @name = grep (!/^\.\.?$/,readdir DIR);
# @name = readdir (DBDIR);

my $n;
open(Handle , ">$newname") || die("ERROR! Can't create $newname:$!\n"); 

foreach my $oldname(@name) #Generate shell file to formatdb
{
	open FILE,"$dir$oldname" || die"$!";
	
	while (my $line = <FILE>) {
		print Handle "$line";
	}	
	}