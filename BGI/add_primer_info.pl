#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 添加primer信息于reads名
# 并分到两个文件中
# 2004-6-1 10:46 
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

open TABLE,"reads_primer.table" || die"$!";

my $first_line = <TABLE>;
while (<TABLE>) {
	chomp;
	@s = split /\t/,$_;
	$left = $s[0];
	for (my $k = 1;$k<13;$k++) {
		if ($k<10) {
			$hole = $left."0".$k;
			$primer{$hole} = $s[$k];
			print  "$hole===$s[$k]\n";
		}
		else {
			$hole = $left.$k;
			$primer{$hole} = $s[$k];
			print  "$hole===$s[$k]\n";
		}
	}
}

# >rbspd0_0001_D05.ab1  CHROMAT_FILE: rbspd0_0001_D05.ab1 PHD_FILE: rbspd0_0001_D05.ab1.phd.1 CHEM: unknown DYE: unknown TIME: Mon May 31 17:36:31 2004
$file_p = "bsbp_".$file_out;
$file_q = "bsbq_".$file_out;

while (my $line=<IN>) {
	chomp $line;
	if ($line=~/^>(\S+?)\s/) {
		$print = "n";
		$read_name = $1;
		@s_1 = split /\./,$read_name;
		@s_2 = split /_/,$s_1[0];
		$hole = $s_2[-1];
		print  "hole==$hole\nprimer===$primer{$hole}\n";
		if (length $primer{$hole} >1) {
			$print = "y";
		
		$primer = $primer{$hole};
		print  "$primer\n";
		if ($primer=~/^P/) {
			open O,">>$file_p" || die"$!";
		}
		else {
			open O,">>$file_q" || die"$!";
		}

		$new_read_name = $s_1[0]."_".$primer.".".$s_1[1];
#		print  "$new_read_name\n";

		$line=~s/$read_name/$new_read_name/;
		print O "$line\n";
		print OUT "$line\n";
		}
	}
	else {
		if ($print eq "y") {
		
		print O "$line\n";
		print OUT "$line\n";
		}
	}
}


