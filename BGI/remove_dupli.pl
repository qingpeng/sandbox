#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# BAc位置相同的保留 距离最近的一个Multi坐标
# 2005-4-6 15:54
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#chr10	77556146	chr4-29468088	chr14-18947482	bsaf-2267	339
#chr10	77557620	chr4-29470298	chr14-18948829	bsaf-3390	45
#chr10	77559050	chr4-29471768	chr14-18949935	bsaf-5460	990
#chr10	77561782	chr4-29474180	chr14-18953377	bsaf-6951	442
#chr10	77562898	chr4-29474959	chr14-18954468	bsaf-7271	8
#chr10	77563669	chr4-29475744	chr14-18955214	bsaf-7429	609
#chr10	77567614	chr4-29480075	chr14-18959041	bsaf-9425	732
#chr10	77567679	chr4-29480126	chr14-18959430	bsaf-9425	667
#chr10	77569311	chr4-29481660	chr14-18961054	bsaf-9425	965
#chr10	77571079	chr4-29482241	chr14-18963010	bsaf-10497	795


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	if (exists $min{$s[4]}) {
		if ($s[-1]<$min{$s[4]}) {
			$min{$s[4]} = $s[-1];
			$min_line{$s[4]} = $_;
		}
	}
	else {
		$min_line{$s[4]} = $_;
		$min{$s[4]} = $s[-1];
	}
}

close IN;
open IN,"$file_in" || die"$!";

while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	if (!exists $mark{$s[4]}) {
		print OUT "$min_line{$s[4]}\n";
		$mark{$s[4]} = 1;
	}
}

