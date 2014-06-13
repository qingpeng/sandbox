#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#last modified: 2003-9-17 11:07
use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"dd:s","o:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-dd		dbdir 
		-o		shellfile out
USAGE

die $usage unless $opts{"dd"}and$opts{"o"};


my $dbdir = $opts{"dd"};
my $shell_file = $opts{"o"};


my @name;


opendir  (DBDIR,"$dbdir" )|| die"can't open $dbdir:$!";
 @name = grep (!/^\.\.?$/,readdir DBDIR);
# @name = readdir (DBDIR);
close ;
my $n;
open(Handle , ">./$shell_file") || die("ERROR! Can't create <formatdb.sh>:$!\n"); 
$n =0; # restrict blast number
#print Handle @name;
foreach my $name (@name) #Generate shell file to formatdb
{
	if ($name =~ /cut$/) {
	
	$n++;
#	if($n > 30){ $n=0; print Handle "wait\n"; }
		print Handle "formatdb -i ".$dbdir."$name -p F &\n";
	}

}
print Handle "wait\n";
close(Handle);
