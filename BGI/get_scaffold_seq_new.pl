#!/usr/local/bin/perl -w
# nipx 2001-10-30
# e-mail: nipx@genomics.org.cn

die "Usage:get_scaffold_seq.pl Scaffold_File Contig_Seq_File Scaffold_Seq_File [Prjoct_Name]\n" if (@ARGV<3);
($Scaffold_File, $Contig_Seq_File, $Scaffold_Seq_File, $Prj_Name)=@ARGV;

if (!defined $Prj_Name)
{
	$Prj_Name="Scaffold";
}
print "\n","="x 50,"\n";
print "Scaffold_File        = $Scaffold_File\n";
print "Contig_Seq_File      = $Contig_Seq_File\n";
print "Scaffold_Seq_File    = $Scaffold_Seq_File\n";
#print "Left_Contig_Seq_File = $Left_Contig_Seq_File\n";
print "="x 50,"\n";

$Add_Sequence = "N" x 100;
$Add_Quality="0 " x 100;

print "Loading the Contig_Seq_File:$Contig_Seq_File\n";
open (CON,"$Contig_Seq_File")|| die "Can't open $Contig_Seq_File:$!\n";
$i=0;
while (<CON>) 
{
	chomp;
	if (/>(\S+)/)
	{
		$Contig_Name=$S_Name[$i++]=$1;
		if (defined($Scaffold_Sequence{$Contig_Name}))
		{print "$Scaffold_Name repeat\n";
		}
		else{$Scaffold_Sequence{$Contig_Name}="";}
	}
	elsif (/\S/) 
	{
		$Scaffold_Sequence{$Contig_Name}.=$_;
	}
}
close(CON);
print "Joinning the Scaffold Sequence\n";
open (SCA,"$Scaffold_File")|| die "Can't open $Scaffold_File:$!\n";
while (<SCA>) 
{
	if (/^(\S+)/)
	{
		if (defined($Scaffold_Name))
		{
			#print FINALSEQ ">$Scaffold_Name\n";
			$Scaffold_Sequence{$Scaffold_Name} = join($Add_Sequence,@Sequence);
			#while (length($All_Sequence)>50) 
			#{
			#	print FINALSEQ  substr($All_Sequence,0,50)."\n";
			#	$All_Sequence = substr($All_Sequence,50,);
			#}
			#print FINALSEQ "$All_Sequence\n";
			$USED{$Scaffold_Name}=1;
		}
		$Scaffold_Name=$S_Name[$i++]=$1;undef(@Sequence);$Scaffold_Site{$Scaffold_Name}=$';
	}
	elsif (/\s+(\S+)\.\s+U/) 
	{
		$USED{$1}=1;
		push(@Sequence,$Scaffold_Sequence{$1});
		delete($Scaffold_Sequence{$1});
		$Scaffold_Site{$Scaffold_Name}.=$_;
	}
	elsif (/\s+(\S+)\.\s+C/) 
	{
		$USED{$1}=1;
		$temp=reverse($Scaffold_Sequence{$1});
		$temp=~tr/ATGCatgc/TACGTACG/;
		push(@Sequence,$temp);
		delete($Scaffold_Sequence{$1});
		$Scaffold_Site{$Scaffold_Name}.=$_;
	}
	else 
	{
		print $_;
	}
}
#print FINALSEQ ">$Scaffold_Name\n";
#$All_Sequence = join($Add_Sequence,@Sequence);
#while (length($All_Sequence)>50) 
#{
#	print FINALSEQ  substr($All_Sequence,0,50)."\n";
#	$All_Sequence = substr($All_Sequence,50,);
#}
#print FINALSEQ "$All_Sequence\n";
$Scaffold_Sequence{$Scaffold_Name} = join($Add_Sequence,@Sequence);
$USED{$Scaffold_Name}=1;
close(SCA);

foreach  (@S_Name) 
{
	if (defined $Scaffold_Sequence{$_})
	{
		push(@Temp_Name,$_);
		if(! defined $USED{$_})
		{
			$length=length($Scaffold_Sequence{$_});
			$Scaffold_Site{$_}=sprintf ("  %d\n%12d%31s%13d\n",$length,1,"$_. U",$length);
		}
	}
}
@S_Name = sort { length($Scaffold_Sequence{$a}) <=> length($Scaffold_Sequence{$b}) } @Temp_Name;
@S_Name = reverse (@S_Name);
$Time_Start = sub_format_datetime(localtime(time())); 
$Data_Vision = substr($Time_Start,0,10);
open (FINALSEQ,">$Scaffold_Seq_File")|| die "Can't write to $Scaffold_Seq_File:$!\n";
open (NEWSCA,">$Scaffold_File.new")|| print "Can't write to $Scaffold_File.new:$!\n";
$i=0;
foreach  (@S_Name) 
{
	$i++;
	printf NEWSCA "$Prj_Name%06d.$Scaffold_Site{$_}",$i;
	delete($Scaffold_Site{$_});
	printf FINALSEQ ">$Prj_Name%06d $Data_Vision BGI\n",$i;
	$All_Sequence = $Scaffold_Sequence{$_};
	delete($Scaffold_Sequence{$_});
	while (length($All_Sequence)>50)                       
	{                                                      
		print FINALSEQ  substr($All_Sequence,0,50)."\n";    
		$All_Sequence = substr($All_Sequence,50,);          
	}                                                      
	print FINALSEQ "$All_Sequence\n";                      
}
close(FINALSEQ);
close(NEWSCA);
undef(%Scaffold_Sequence);
#close(LEFT);

print "Loading the Contig_Seq_File.qual:$Contig_Seq_File.qual\n";
open (CON,"$Contig_Seq_File.qual")|| exit "Can't open $Contig_Seq_File.qual:$!\n";
while (<CON>) 
{
	chomp;
	if (/>(\S+)/)
	{
		$Contig_Name=$1;
		$Scaffold_Sequence{$Contig_Name}="";
	}
	elsif (/\S/) 
	{
		$aa=join(" ",split);
		$Scaffold_Sequence{$Contig_Name}.="$aa ";
	}
}
close(CON);
$i=0;
print "Joinning the Scaffold Quality\n";
open (SCA,"$Scaffold_File")|| die "Can't open $Scaffold_File:$!\n";
while (<SCA>) 
{
	if (/^(\S+)\.*/)
	{
		if (defined($Scaffold_Name))
		{
			$Scaffold_Sequence{$Scaffold_Name} = join($Add_Quality,@Sequence);
		}
		$Scaffold_Name=$1;undef(@Sequence);
	}
	elsif (/\s+(\S+)\.\s+U/) 
	{
		push(@Sequence,$Scaffold_Sequence{$1});
		delete($Scaffold_Sequence{$1});
	}
	elsif (/\s+(\S+)\.\s+C/) 
	{
		@temp=split(/\s+/,$Scaffold_Sequence{$1});
		@temp=reverse(@temp);
		$temp=join(" ",@temp);
		push(@Sequence,"$temp ");
		delete($Scaffold_Sequence{$1});
	}
	else 
	{
		print $_;
	}
}
$Scaffold_Sequence{$Scaffold_Name} = join($Add_Quality,@Sequence);
close(SCA);
open (FINALSEQ,">$Scaffold_Seq_File.qual")|| die "Can't write to $Scaffold_Seq_File.qual:$!\n";
$i=0;
foreach  (@S_Name) 
{
	$i++;
	printf FINALSEQ ">$Prj_Name%06d $Data_Vision BGI\n",$i;
	$All_Sequence = $Scaffold_Sequence{$_};
	delete($Scaffold_Sequence{$_});
	while (length($All_Sequence)>50)
	{
		if ($All_Sequence=~/^(.{50}\S* ?)/)
		{
			print FINALSEQ $1."\n";
			$All_Sequence=$';
		}
	}
	print FINALSEQ "$All_Sequence\n";                 
}
close(FINALSEQ);
sub sub_format_datetime
{
	local($sec, $min, $hour, $day, $mon, $year) = @_[0..5]; 
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
};
