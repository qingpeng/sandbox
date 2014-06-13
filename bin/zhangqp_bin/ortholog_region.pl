#!/usr/bin/perl 
#programmer:zhouqi
#用于寻找以N隔开的bac上的与人同源的区域
if (@ARGV<2) {
	print  "programm file_in  file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
$/=">";
while (<IN>) {
	#Fasta format
	chomp;
	 @in=split(/\n/,$_,2);
	if ($_ ne '') {
		$in[0]=~s/\s+\S+//g;
		$in[0]=~s/\s+|\n//g;
		$in[1]=~s/\s+|\n//g;
		$in[1]=~s/ //g;
		$in[1]=uc($in[1]);
		@letter=split //,$in[1];
		$bac_name=$in[0];
		for ($n=2; $n<@letter; $n++) {
			if ($letter[$n-2] ne "N" && $letter[$n-1] eq "N" && $letter[$n] eq "N" ) {
				
                push @start,$n;
				
			}
			if ($letter[$n-2] eq "N" && $letter[$n-1] eq "N" && $letter[$n] ne "N") {
				
				push @end,$n;
			}
		}
	
#	for ($k=0; $k<@start;$k++) {
#	push @{$N_start{$in[0]}},$start[$k];
#	push @{$N_end{$in[0]}},$end[$k];
#	}
		print OUT "\n$in[0]\:";
		for ($m=0; $m<@start;$m++) {
			print OUT "$start[$m],$end[$m]\t";
		}
		@start="";
		@end="";
		
	}


}
#bsbg	40569	2543	31043	+	chr13	66159989	32847672	32931689	10	759	2543,2635;2971,3045;3934,3967;4631,4701;8075,8172;19868,19902;19925,19979;25018,25143;26666,26881;31008,31043;	32847672,32847764;32858937,32859011;32861315,32861348;32894329,32894399;32899319,32899414;32916552,32916586;32916600,32916654;32923008,32923133;32927089,32927303;32931654,32931689;	+81;+65;+32;+65;+88;+34;+48;+118;+194;+34;
#$/="\n";
#while (<SOLAR>) {
#	@info= split /\t/,$_;
#	$bac_name=$info[0];
#	@bac_position=split ";",$info[11];
#	@subject_position=split ";",$info[12];
#	for ($n=0;$n<@bac_position ;$n++) {
#		@tmp=split ",",$bac_position[$n];
#		$bac_start[$n]=$tmp[0];
#		$bac_end[$n]=$tmp[1];
#		@tmpp=split ",",$subject_position[$n];
#		$human_start[$n]=$tmpp[0];
#		$human_end[$n]=$tmpp[1];
#	}
#	for ($k=0;$k<@bac_start ;$k++) {
#	 push @{$align_start{$bac_name}},$bac_start[$k];
#	 push @{$align_end{$bac_name}},$bac_end[$k];
#	}
#}
##print ${$align_end{"bsab"}}[2];
#foreach $bac (keys %N_start) {
#	for ($m=0;$m < @bac_start ;$m++) {
#		for ($p=1; ${$align_end{$bac}}[$p] > ${$N_start{$bac}}[$m];$p++) {
#			
#		}
#		push @{$block_end{$bac}},${$align_end{$bac}}[$p-1];
#		print
#		for ($j=0; ${$align_start{$bac}}[$j] > ${$N_end{$bac}}[$m];$j++) {
#		}
#		push @{$block_start{$bac}},${$align_start{$bac}}[$j];
##		print ${$N_start{$bac}}[$m],"\n";
##		print ${$N_end{$bac}}[$m],"\n";
#	}
#   print OUT "\n$bac\:\t";
#   for ($s=0; $s< @{$block_start{$bac}}; $s++) {
#	   print OUT "${$block_start{$bac}}[$s]\,${$block_end{$bac}}[$s]\t";
#   }
#
#}
