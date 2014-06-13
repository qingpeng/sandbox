#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
#last modified: 2003-9-16 23:36:22

use warnings;
use strict;

print  "querydir....(end with \"\/\")\n";
my $querydir = <STDIN>;
chomp $querydir;
print  "outdir...(end with \"\/\")\n";
my $outdir = <STDIN>;
chomp $outdir;
print  "output file...\n";
my $logfile = <STDIN>;
chomp $logfile;
open LOG,">$logfile" || die"$!";

opendir  (DBDIR,"$querydir" )|| die"can't open :$!";
my  @name = grep (!/^\.\.?$/,readdir DBDIR);
my %out;
foreach my $name (@name) {

	if ($name =~/^(.*).fa$/) {
		my $out = $1.".out";
		$out{$name}=$out;
	}
}
#my $n=0;
my @sortname =sort(@name);
foreach my $queryname (@sortname) {

print  "do $queryname\n";
my $outname = $out{$queryname};
my $id;
if (-e "$outdir$outname") {

open OUT,"$outdir$outname" || die"$!";
my @line = <OUT>;
my $lastline = $line[-1];
my @word =split " ",$lastline;
$id = $word[0];
#while (<OUT>) {
#	if (/^>(\w+)\s+\w+\s+chr.+$/) {
#		$id = $1;
#	}
#}


my $systemresult = `grep -n $id $querydir$queryname`;
my $linenumber= `wc $querydir$queryname`;
my @w = split " ",$linenumber;
my $linen = $w[0];
my @ww =split ":",$systemresult;
my $matchline =$ww[0];
my $percent = int ($matchline*100/$linen);


print LOG " grep -n $id $querydir$queryname    $matchline>>>      $percent%\n";
}

}
#print LOG "$n";