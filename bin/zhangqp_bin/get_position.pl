#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#chr12	105721288	chr10-35180195	chr10-84624571	bsax-52592	673
#chr12	105724749	chr10-35176608	chr10-84628737	bsax-54291	478
#chr12	105740000	chr10-35168749	chr10-84638338	bsax-56108	94
#chr14	54311326	chr8-33570306	chr14-39753339	bsba-5875	55
#chr14	54315448	chr8-33574061	chr14-39756020	bsba-9689	217

while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	@dog=split "-",$s[2];
	@mouse=split "-",$s[3];
	@muntjac=split "-",$s[4];
	$dog_ch=$dog[0];
	$mouse_ch=$mouse[0];
	$bac=$muntjac[0];
	$dog_site=$dog[1];
	$mouse_site=$mouse[1];
	$muntjac_site=$muntjac[1];
	if (!exists $hash{$bac}) {
		$hash{$bac}=[$dog_ch,$dog_site,$mouse_ch,$mouse_site];
		$dog_start{$bac}=[$dog_ch,$dog_site];
        $mouse_start{$bac}=[$mouse_ch,$mouse_site]; 
	}
	else {
		$hash{$bac}=[$dog_ch,$dog_site,$mouse_ch,$mouse_site];
	}

}
foreach $bac_name (sort keys %hash) {
	if ($dog_start{$bac_name}->[1] > $hash{$bac_name}->[1]) {
		print OUT "$hash{$bac_name}->[0]\t$hash{$bac_name}->[1]\t$dog_start{$bac_name}->[1]\t+\n";
	}
	else {
		print OUT "$hash{$bac_name}->[0]\t$dog_start{$bac_name}->[1]\t$hash{$bac_name}->[1]\t+\n"
	}
}

#$mouse_start{$bac_name}->[0]\t$mouse_start{$bac_name}->[1]\t$hash{$bac_name}->[3]\t+\n
print OUT  "##########################################\n";
foreach $bac_name (sort keys %hash) {
	if ($mouse_start{$bac_name}->[1] > $hash{$bac_name}->[3]) {
		print OUT "$mouse_start{$bac_name}->[0]\t$hash{$bac_name}->[3]\t$mouse_start{$bac_name}->[1]\t+\n";
	}
	else {
		print OUT "$mouse_start{$bac_name}->[0]\t$mouse_start{$bac_name}->[1]\t$hash{$bac_name}->[3]\t+\n";
	}
}