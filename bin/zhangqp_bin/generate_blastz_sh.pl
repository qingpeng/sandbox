#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#last modified: 2003-9-17 11:13

use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"db:s","qd:s","od:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : $0
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-db		db dir with \/
		-qd		query dir with \/
		-od		output dir with \/
USAGE

die $usage unless $opts{"db"}and$opts{"qd"}and$opts{"od"};



my $dbdir=$opts{"db"};
my $querydir=$opts{"qd"};
my $outputdir=$opts{"od"};
my @name;
opendir  (DBDIR,"$dbdir" )|| die"can't open db dir:$!";
 @name = grep (!/^\.\.?$/,readdir DBDIR);
# @name = readdir (DBDIR);
close ;

my %query_db;
foreach my $filename (@name){
	if ($filename =~/^(.*scf)_.*cut$/) {
		my $query = $1.".fa";
		$query_db{$filename}=$query;

	}
}

my $n;
open(Handle , ">./blast.sh") || die("ERROR! Can't create <blast.sh>:$!\n"); #生成shell文件
$n =1; # restrict blast number
#print Handle @name;
my @dbname= sort (keys %query_db);
foreach my $dbname(@dbname) #generate shell file for blast
{
	    my $query_name = $query_db{$dbname};
		print Handle "/usr/local/genome/BLASTZ-2003-05-14-64bit/blastz  ".$querydir."$query_name ".$dbdir."$dbname > ".$outputdir."$dbname" . ".out  &\n";
}

close(Handle);
