#!/usr/bin/perl
#根据ortholog的位置信息定出ortholog repeat：名字相同 方向一致
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_pos,$file_repeat,$file_out) =@ARGV;
open POSITION,"$file_pos" || die "$!";
open REPEAT,"$file_repeat" || die"$!";
open OUT,">$file_out" || die"$!";

#chr8	144870722	chr13-40448143	chr15-76318765	bsah-18340
#chr8	144871899	chr13-40449179	chr11-61105555	bsah-18340

while (<POSITION>) {
	chomp;
	@s = split /\t/,$_;
	$hchr = $s[0];
	$hps = $s[1];
	@sdog = split "-",$s[2];
	@smus = split "-",$s[3];
	@sdeer = split "-",$[4];
	$dchr = $sdog[0];
	$dps = $sdog[1];
	$mchr = $smus[0];
	$mps = $smus[1];
	$bac = $sdeer[0];
	$bacps = $sdeer[1];
	push @{$human{$hchr}},$hps;
	push @{$dog{$dchr}},$dps;
	push @{$mouse{$mchr}},$mps;
	push @{$muntjac{$bac}},$bacps;
}

while (<REPEAT>) {
#bsab_human_chr3	12174459	12174769	C	L2	LINE/L2
#bsab_mouse_chr6	115643125	115643251	+	Charlie4	DNA/MER1_type
#bsab_dog_chr20	9122250	9122494	+	L3	LINE/CR1
#bsab_muntjac	520	818	+	L3	LINE/CR1
#
	chomp;
	@srepeat=split /\t+/,$_;
	@sname = split "-",$srepeat[0];
	$chro=$sname[2];
	$bacname=$sname[0];
	$direction=$srepeat[3];
	$repeat_name=$srepeat[4];
	$repeat_class=$srepeat[5];
	$start = $srepeat[1];
	$end = $srepeat[2];
	for ($n=1;$n < @{$human{$hchr}} ; $n++) {
		if (/human/ && $start > ${$human{$chro}}[$n-1]-100 && $end < ${$human{$chro}}[$n]+100) {
			$h_area="human_".$chro.(${$human{$chro}}[$n-1]-100)."_".(${$human{$chro}}[$n]+100);
			push @{$hum{$h_area}},$_;
		}
		elsif (/mouse/ && $start > ${$mouse{$chro}}[$n-1]-100 && $end < ${$mouse{$chro}}[$n]+100) {
			$m_area="mouse_".$chro.(${$mouse{$chro}}[$n-1]-100)."_".(${$mouse{$chro}}[$n]+100);
			push @{$mou{$m_area}},$_;
		}
		elsif (/dog/ && $start > ${$dog{$chro}}[$n-1]-100 && $end < ${$dog{$chro}}[$n]+100) {
			$d_area="dog_".$chro.(${$dog{$chro}}[$n-1]-100)."_".(${$dog{$chro}}[$n]+100);
			push @{$dog{$d_area}},$_;
		}
		elsif (/muntjac/ && $start > ${$muntjac{$bacname}}[$n-1]-100 && $end < ${$muntjac{$bacname}}[$n]+100) {
			$b_area="muntjac_".$bacname.(${$muntjac{$bacname}}[$n-1]-100)."_".($end < ${$muntjac{$bacname}}[$n]+100);
			push @{$bac{$b_area}},$_;
		}
	}
}