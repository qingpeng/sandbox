#!/usr/local/bin/perl -w

($Tm, $Seq, $in_Tm,$out_Tm,$min,$max) = @ARGV;

open(TMIN, "$Tm") || die "Can not read file";
open(SEQ,"$Seq")||die "Can not read file";
open(INTMSEQ, ">$in_Tm") || die "Can not write file";
open(OutTm, ">$out_Tm")|| die;
 
%Tm_In=();
while(<TMIN>)
{
	chomp;
	@temp = split(/\s+/, $_);
	$Tm1 = pop(@temp);
	$a = sprintf("%.1f", $Tm1);
	if($a >= $min && $a <= $max)
	{
	     $Tm_In{$temp[0]}=1;
        }
        else
        {
             $Tm_out{$temp[0]}=1;
        } 
  
}
close(TMIN);
while(<SEQ>)
{
	if(/^>(\S+)/)
    	{
		$name=$1;
		$Name = $_;
    	}
	else
	{
		if(exists ($Tm_In{$name}))
		{
			print INTMSEQ "$Name";
			print INTMSEQ "$_";
        	}
                if(exists ($Tm_out{$name}))
                {
                       print OutTm "$Name";
                       print OutTm "$_";
                }
	}
}

close(SEQ);
close(INTMSEQ);



