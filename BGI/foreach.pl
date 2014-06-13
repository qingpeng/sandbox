#!/usr/bin/perl

($path,$outfile)=@ARGV;
@filelist = `ls $path`;
#chomp(@filelist);

#open (OUT,">$outfile");
foreach $file(@filelist)
{$name="";
        $L_seq="";$L_lenth="";$Ltm="";$Lgc="";$R_seq="";$R_lenth=""; $Rtm=""; $Rgc="";
	#print "File:$file\n============================================================\n";
	open (IN, "$path/$file");
	#while($line = <IN>)
	#{
	    
	#	if ($line =~ m/^\>/)
	#	{
	#		print "$line\n";			 		 
	#	}
	#}
	#open input,"$file";
    open output,">>$path/primer.out";
    while (<IN>) 
	{
		
		if (/(PRIMER_SEQUENCE_ID=)(\S+)/) 
			{
			$name=$2;
		     }
		
        if (/(PRIMER_LEFT_SEQUENCE=)(\w+)/) 
			{
            $L_seq=$2;
           }
		 if (/(PRIMER_LEFT=)(\d+)\S(\d+)/) {
			  $L_start=$2;
              $L_lenth=$3;
		   }
		 if (/(PRIMER_LEFT_TM=)(\S+)/) 
		{
			 $Ltm=$2;
		 }
		 if (/(PRIMER_LEFT_GC_PERCENT=)(\S+)/) 
		{
			 $Lgc=$2;
		 }
         if (/(PRIMER_RIGHT_SEQUENCE=)(\w+)/) 
			{
            $R_seq=$2;
			}
		 if (/(PRIMER_RIGHT=)(\d+)\S(\d+)/) {
			   $R_lenth=$3;
               $R_start=$2;
		   }
		 if (/(PRIMER_RIGHT_TM=)(\S+)/) 
		{
			 $Rtm=$2;
		 }
          if (/(PRIMER_RIGHT_GC_PERCENT=)(\S+)/) 
		{
			 $Rgc=$2;
		 }
		
		 }
	if ($L_seq ne "") {
    print output $name."\t".$L_seq."\t".$L_lenth."\t".$Ltm."\t".$Lgc."\t".$L_start."\t".$R_seq."\t".$R_lenth."\t".$Rtm."\t".$Rgc."\t".$R_start."\n";
    }
	close (IN);close (output);
}

