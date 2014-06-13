#!/usr/local/bin/perl
#
# Program to blast a series of files in a directory
#
# Author J Han, modified on P.V.'s script
# 
# Date 12/13/2002
#
#
use strict;

my $inpd=$ARGV[0];

my $out_file1="yeastProteinsWithDuplicates.txt";
my $out_file2="yeastProteinsWithNoDuplicates.txt";
opendir (DIR,$inpd);
my @files = readdir DIR;
closedir DIR;

# remove  the files . and .. from the list
shift @files;
shift @files;
open(OUT1,">$out_file1");
open(OUT2,">$out_file2");
while ( my $file = shift @files ){
  print $file,"\n";
  open (IN, "$inpd/$file");
  my $glen;
  my $olen;
  my $cnt=0;
  my $oldalign;
  my $oldeval;
  my $oldpen;
  my $align;
  my $evalue;
  while (my $line=<IN>) {
    $cnt=0;
    if($line=~qr/$file,/i && ($line!~/>>/) && $line=~/aa/ ){
      print $line;
      my @dums=split(" ",$line);
      $olen=$dums[1];
    }
    if($line=~/>>/) {
      my ($gene,undef)=split(" ",$line);
      $gene=~s/>>//;
      $glen=substr($line,rindex($line,"(")+1,rindex($line,"aa)")-rindex($line,"(")-1);
      next if(uc($gene) eq $file);
      $line=<IN>;
      chomp($line);
      $evalue=substr($line,rindex($line,"E():")+4);
      $evalue=~s/\s//g;
      $line=<IN>;
      $align=substr($line,rindex($line,"in")+2,rindex($line,"aa")-rindex($line,"in")-2);
      my $smaller=($olen<$glen)? $olen:$glen;
      print "glen $glen\n";
      print "olen $olen\n";
      print "small $smaller\n";
      print "align $align\n";
      my $pen= $align/$smaller;
      if($evalue<0.1 && $pen>0.5){
	print OUT1 "$file\t$gene\t$evalue\t$align\t$smaller\t$pen\n" ;
	print "GOOD $file\t$gene\t$evalue\t$align\t$smaller\t$pen\n" ;
        last;
      }
      else {
	if ($oldeval){
	  print OUT2 "$file\t$gene\t$evalue\t$align\t$smaller\t$oldpen\n" ;
	  print  "BAD $file\t$gene\t$evalue\t$align\t$smaller\t$oldpen\n" ;
	  last;
	}
	else{
	  $oldeval=$evalue;
	  $oldalign=$align;
	  $oldpen=$pen;
	}
      }
    }
  }
  close(IN);
}
close(OUT1);
close(OUT2);

