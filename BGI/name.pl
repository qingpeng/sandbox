#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#bsab/:
#total 392
#-rw-r--r--  1 zhangqp prj0313  59305 2005-04-07 21:58 bsab_1431_59553_+.fa
#-rw-r--r--  1 zhangqp prj0313 117750 2005-04-07 21:40 dog_chr20_9125790_9241205_-.fa
#-rw-r--r--  1 zhangqp prj0313 119190 2005-04-07 21:43 human_chr3_12173310_12290136_+.fa
#-rw-r--r--  1 zhangqp prj0313  94555 2005-04-07 21:45 mouse_chr6_115642516_115735188_+.fa



while (<IN>) {
	chomp;
	if (/^bs(\w+)\/\:/) {
		$temp=$1;
		$bac_name="bs".$temp;
		

	}
	if (/\-rw\-r/) {
			@s=split /\s+/,$_;
			$file_name=$s[7];
#				print  "$file_name\n";
			if ($file_name =~/bs(\S+)/) {
				print  "$file_name\n";
				#$ff="mv $bac_name/"."$file_name $bac_name\_muntjac\n";
			#	print OUT "$file_name\n";
				print OUT "mv $bac_name/$file_name $bac_name\_muntjac\n";
			}
			if ($file_name =~/dog/) {
				print OUT "mv $bac_name/$file_name $bac_name\_dog\n";
			}
			if ($file_name =~/human/) {
				print OUT "mv $bac_name/$file_name $bac_name\_human\n";
			}
			if ($file_name =~/mouse/) {
				print OUT "mv $bac_name/$file_name $bac_name\_mouse\n";
			}
	}
}