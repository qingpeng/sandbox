#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use strict;

if(@ARGV<1){
	printf "Usage:program sequence_file positionfile outputfile\n";
	exit;
}

my ($seq_file,$pos,$out) = @ARGV;

open POS,"$pos" || die"$!";
my $k = 0;
my @start;
my @end;
my @length;

while (<POS>) {
	chomp;
	my @s = split /\t/,$_;
	$start[$k] = $s[0];
	$end[$k] = $s[1];
	$length[$k] = $end[$k]-$start[$k]+1;
	$k++;

}
print  "@start\t....@end\n";
my $Seq="";
open RF,"$seq_file" || die"$!";
        while(<RF>) {
              chomp;
              if(/^>(\S+)/) {
      #           $Name = $1;
                 $Seq  = "";
              }else{
                 $Seq .= $_;
               }
        }
        close(RF);

my $Sub_Name;
my $Sub_Seq;
my $start_r;
my %config;
my $out_file_name;
my $dat_file_name;
for (my $k = 0;$k<scalar @start;$k++) {
            $Sub_Name = $seq_file."_".$start[$k]."-".$end[$k];
            $Sub_Seq  = substr($Seq, $start[$k]-1, $length[$k]);
			$start_r = int($length[$k]/2-5);
$config{PRIMER_PRODUCT_OPT_SIZE} = int($length[$k]/2);	
my $right_length = $length[$k]-$start_r;
#_____________________________________________________________
		$config{EXCLUDED_REGION}="0,5 $start_r,$right_length";  
		$dat_file_name = $Sub_Name.".left.in";
	open IN,">$dat_file_name" || die"$!";
	&put_primer_head;
	close IN;
	$out_file_name = "$dat_file_name".".out";
	`primer3_core <$dat_file_name >$out_file_name `;
}

for (my $k = 0;$k<scalar @start;$k++) {
            $Sub_Name = $seq_file."_".$start[$k]."-".$end[$k];
            $Sub_Seq  = substr($Seq, $start[$k]-1, $length[$k]);
			$start_r = int($length[$k]/2+5);
$config{PRIMER_PRODUCT_OPT_SIZE} = int($length[$k]/2);		
		#_____________________________________________________________
		my $end_start =$length[$k]-5;
my $right_length = 5;
		$config{EXCLUDED_REGION}="0,$start_r $end_start,$right_length";  
		$dat_file_name = $Sub_Name.".right.in";
	open IN,">$dat_file_name" || die"$!";
	&put_primer_head;
	close IN;
	$out_file_name = "$dat_file_name".".out";
	`primer3_core <$dat_file_name >$out_file_name `;
}


my @Primer_Files = glob("*.out");
open OUT ,">$out";

#open LOG,">log.log" || die"$!";
my $Left_Loc;
my $left_length;
my $Left_End;
my $Right_Loc;
my $right_length;
my $Right_End;

foreach(@Primer_Files) {
#	@names = split "/",$_;
#	$Primer_File_name = $names[1];
#	@split_names = split "-",$Primer_File_name;
#	$Ref_Seq_file_name = $split_names[0];
#	print  "$Ref_Seq_file_name\n";
		my $Primer_File_name = $_;
        my $Left_Primer  = "";
        my $Right_Primer = ""; 
        open(PF, "$_")||die "$!\n";
		my $num = 0;

		my $Ref_Seq = $Seq;
#		print LOG ">$Ref_Seq_File_name\n$Ref_Seq\n";

        while(<PF>) {
              chomp;
              if(/PRIMER_LEFT.*_SEQUENCE\=(\S+)/) {
				$num ++;
				$Left_Primer = $1;
				$Left_Loc  = index($Ref_Seq, $Left_Primer);
				$Left_Loc++;
				$left_length = length $Left_Primer;
				$Left_End = $Left_Loc+$left_length-1;
				}
				elsif(/PRIMER_RIGHT.*_SEQUENCE=(\S+)/) {
					$Right_Primer = $1;
					$Right_Loc = index($Ref_Seq, dna_reverser($Right_Primer));
					$Right_Loc++;
					$right_length = length $Right_Primer;
					$Right_End = $Right_Loc +$right_length-1;
					if($Right_Loc < $Left_Loc) {
						print "$Primer_File_name".".$num wrong!\n";
						next;
					}
					print OUT "$Primer_File_name\t$num\tL\t$Left_Primer\t$Left_Loc\t$Left_End\n";
					print OUT "$Primer_File_name\t$num\tR\t$Right_Primer\t$Right_Loc\t$Right_End\n";
				}
				else{
                  next;
                }
        }
        close(PF);
		if ($Left_Primer eq "") {
			print  "No primer! $Primer_File_name \n";
		}
        
}

sub put_primer_head{
print IN <<"map";
PRIMER_SEQUENCE_ID=$Sub_Name
SEQUENCE=$Sub_Seq
PRIMER_OPT_SIZE=20
PRIMER_MAX_SIZE=23
PRIMER_MIN_SIZE=18
PRIMER_OPT_TM=59
PRIMER_MAX_TM=60
PRIMER_MIN_TM=58
PRIMER_PRODUCT_SIZE_RANGE="28-500"
PRIMER_PRODUCT_OPT_SIZE=$config{PRIMER_PRODUCT_OPT_SIZE}
PRIMER_PAIR_WT_PRODUCT_SIZE_LT=.10
PRIMER_PAIR_WT_PRODUCT_SIZE_GT=.30
PRIMER_MIN_GC=20
PRIMER_MAX_GC=50
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_GC_CLAMP=0
PRIMER_NUM_RETURN=10
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  

#-----------------------------------------------------
sub dna_reverser {
    my($Seq) = @_;
 my    $Rev_Seq = reverse($Seq);##
######
    $Rev_Seq =~ tr/[atgc]/[tacg]/;
    $Rev_Seq =~ tr/[ATGC]/[TACG]/;
    return($Rev_Seq);
}