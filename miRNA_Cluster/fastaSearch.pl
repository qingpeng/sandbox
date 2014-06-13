#!/usr/local/bin/perl
#
# Program to blast a series of files in a directory
#
# Author J Han, modified on P.V.'s script
# 
# Date 12/13/2002
#
#

use Getopt::Std;

$ENV{'BLASTDB'} = "/tome/dsk1/wwwblast/db/";
$ENV{'BLASTMAT'} = "/usr/local/ncbi/matrix";


getopt('do');
my $inpd;
my $outd;
my $blast = "/usr/local/ncbi/blastall";
my $blast_ana = "/usr/local/ncbi/blast_ana.pl";

my $ref_file="/vidal/dsk3/jhan/projects/yeast/perl/all_contig.pep.fa";
if ( !$opt_d ){
  # ask for the directory where sequences files are stored
  print "\nEnter the directory where the sequence files are stored\n";
  print "-> ";
  $c = "";
  while ( $c ne "\n" ){
    $inpd .= $c;
    $c = getc;
  }
}else {
  $inpd = $opt_d;
}

if ( !$opt_o ){
  # ask for the directory where results will be stored
  print "\nEnter the directory where the output will be stored\n";
  print "-> ";
  $c = "";
  while ( $c ne "\n" ){
    $outd .= $c;
    $c = getc;
  }
}else {
  $outd = $opt_o;
}


if ( !-e $inpd ){
  die ("$inpd does not exists\n");
}

if ( !-e $outd ){
  system ("mkdir $outd");
}

opendir (DIR,$inpd);
my @files = readdir DIR;
closedir DIR;

# remove  the files . and .. from the list
shift @files;
shift @files;

while ( my $file = shift @files ){
  my $cmd="fasta34 -O $outd/$file -Q -A -b 3 $inpd/$file \"$ref_file 0\"";
  print $cmd;
  system ("$cmd");
}

print "The blast are done do you want to receive the files by E-mail ?\n";

my $mail_blast;
$c = "";
while ( $c ne "\n" ){
  $mail_blast .= $c;
  $c = getc;
}


if ( $mail_blast ne 'y' ){
  exit();
}else {
  my $mail_ad;
  print "Enter you e-mail address \n ->";
  $c = "";
  while ( $c ne "\n" ){
    $mail_ad .= $c;
    $c = getc;
  }
  system ("mail -v $mail_ad < your results are ready in $outd");
}





