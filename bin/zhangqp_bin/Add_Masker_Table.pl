#!/usr/bin/perl
#This script is used to add the result of RepeatMasker result. file_in should be cat file of repeatmasker tables.


if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
	@s=split(/\s+/,$_);
	
	if (/^file/) {
		$line{"files"}.="_".$s[2];
	}

	if (/^total/ && $s[4]=~/\((\d+)/) {
		$current_length=$1;
		$line{$s[0]."_".$s[1]}=$line{$s[0]."_".$s[1]}+$current_length;
	}
	if (/^bases/) {
		$line{$s[0]."_".$s[1]}+=$s[2];
	}
	
	if (/^Total/) {
		$line{$s[0]."_".$s[1]."_".$s[2]}+=$s[3];
	}
	if (/^LTR|DNA|Small|Simple|Low/) {
		$line{$s[0]."_".$s[1]}=[$line{$s[0]."_".$s[1]}->[0]+$s[2],$line{$s[0]."_".$s[1]}->[1]+$s[3]];
	}
	if (/^GC/) {
		$GC=$GC+$current_length*$s[2]/100;
	}
	if (/SINEs|LINEs|Satellites|Unclassified/) {
		$line{$s[0]}=[$line{$s[0]}->[0]+$s[1],$line{$s[0]}->[1]+$s[2]];
	}
	elsif (/\%$/) {
        $line{$s[1]}=[$line{$s[1]}->[0]+$s[2],$line{$s[1]}->[1]+$s[3]];	}
	
}

print OUT "====================================================\n";
print OUT "Total Length:", $line{"total_length:"}," bp\n";
print OUT "GC level:" ,100*sprintf("%.4f",$GC/$line{"total_length:"})," \%\n";
print OUT "Total interpersed repeats: ",$line{"Total_interspersed_repeats:"},"bp\n";
print OUT "bases masked: $line{\"bases\_masked:\"} bp ","\(",100*sprintf("%.4f",$line{"bases_masked:"}/$line{"total_length:"}),"\%\)\n";
print OUT "====================================================\n";
print OUT "\t Number\t\t Length\t\t Percentage\n";
print OUT "----------------------------------------------------\n";
@name=("SINEs:","Alu/B1","MIRs","LINEs:","LINE1","BovB/Art2","LINE2","L3/CR1","LTR_elements:","MaLRs","ERVL",
		"ERV_classI","ERV_classII","DNA_elements:","MER1_type","MER2_type","Unclassified:","Small_RNA:","Satellites:",
		"Simple_repeats:","Low_complexity:");
foreach $n(@name){
	
	print OUT $n,"\t",$line{$n}->[0],"\t\t",$line{$n}->[1],"bp","\t\t",100*sprintf("%.4f",$line{$n}->[1]/$line{"total_length:"}),"\%\n";
}

print OUT "=====================================================\n";
print OUT "\nFiles: $line{\"files\"} \n";