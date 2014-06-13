#!/usr/local/bin/perl -w

($Input, $OutNum,$OutSeq) = @ARGV;

open(IN, "$Input") || die "Can not read file";
open(OUT, ">$OutNum") || die "Can not write file";
open(OUTPUT,">$OutSeq")||die "Can not write file";
$count=0;
%hash=();
$oligo_name="";
while(<IN>)
{
	if(/^>(\S+)(\_\d+\_\d+\_\d+)/)
	{       
	    
	   if(!exists $hash{$1})
	   {   
			chomp;
			$oligo_name="$1";
            		$oligo_name.="$2";
             		$count++;
	        	$hash{$1}=1;
			$Seq=<IN>;
         		print OUTPUT "$1\t$oligo_name\t$Seq";
			
          }
             	
        
    }
    	

}
print OUT "$Input : $count";

close(IN);
close(OUT);
close(OUTPUT);