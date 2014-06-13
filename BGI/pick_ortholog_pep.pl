#!/usr/bin/perl

if (@ARGV<3) {
	print  "programm bac_region pep_file pep_list \n";
	exit;
}
($bac_region,$pep_file,$pep_list) =@ARGV;

open IN,"$bac_region" || die"$!";
open LIST,"$pep_file" || die"$!";
open OUT,">$pep_list" || die "$!";

while (<IN>) {
	chomp;
	
	@s=split /\t+/,$_;
		if ($s[2]=~/chr(\d+)|chr(\w+)/) {
		$chr_name=$1;
		}
	
	$bac_name = $s[0];
	$start_bac = $s[3]-10000;
	$end_bac = $s[4]+10000;
	
	$bac{$bac_name}=[$chr_name,$start_bac,$end_bac];
	
	
}
while (<LIST>) {
#>ENSP00000329982 pep:known chromosome:NCBI35:1:660959:661897:-1 gene:ENSG00000185097 transcript:ENST00000332831
#MDGENHSVVSEFLFLGLTHSWEIQLLLLVFSSVLYVASITGNILIVFSVTTDPHLHSPMY
#FLLASLSFIDLGACSVTSPKMIYDLFRKRKVISFGGCIAQIFFIHVVGGVEMVLLIAMAF
	chomp;
	if (/\>/) {
		@s=split /\s+/,$_;
		if ($s[0]=~/>(ENSP\S+)/) {
			$pep_name=$1;
		}
		$status=$s[1];
		if ($s[2]=~/chromosome:NCBI35:(\d+):(\d+):(\d+):\S+/) {
			$chr_name_pep=$1;
			$start_pep=$2;
			$end_pep=$3;
		}
		foreach $name(keys %bac) {
			if ($chr_name_pep = $bac{$name}->[0] && $bac{$name}->[1] < $start_pep && $bac{$name}->[2] > $end_pep) {
			print OUT "$name\thuman\_chr$bac{$name}->[0]\t$pep_name\t$status\t$s[3]\t$s[4]\n";
			}

		}
		
#		print ">>>>>>>>>>>>>\n";
		
	}
	
}