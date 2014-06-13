#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# cat files into severals

use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"id:s","od:s","n:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-id		dir where files to cat locate in without \/
		-od		dir catted files located in without \/ must exist!
		-n		number of files to cat in one file without \/
USAGE

die $usage unless $opts{"id"}and$opts{"od"}and$opts{"n"};

my $dir_in = $opts{"id"};
my $dir_out = $opts{"od"};
my $file_num = $opts{"n"};

# system "mkdir $dir_out";

opendir  (DIR_IN,"$dir_in" )|| die"can't open $dir_in:$!";
 my @name = grep (!/^\.\.?$/,readdir DIR_IN);
# @name = readdir (DBDIR);
#print  "@name";
my $n = 1;
#open(Handle , ">$newname") || die("ERROR! Can't create $newname:$!\n"); 
my $file_count =1;
&Openfile($dir_out,$file_count);


foreach my $oldname(@name) 
{
	open FILE,"$dir_in/$oldname" || die"$!";
print  "";
	if ($n > $file_num) {
		$file_count++;
		&Openfile($dir_out,$file_count);
		
		while (my $line = <FILE>) {
			print Handle "$line";
		}
		$n = 2;			
	}
	else {
#		open FILE,"$dir_in$oldname" || die"$!";
		while (my $line = <FILE>) {
			print Handle "$line";
		}
		$n++;
		
	}
}
sub Openfile () {
	my ($dir,$num) = @_;
	my $file = $dir."_".$num;
	close Handle;
	open Handle,">./$dir/$file" || die"can't open /$dir/$file:$!";
}
	
