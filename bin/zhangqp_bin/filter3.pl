#!/usr/bin/perl
#筛选出四个物种都有的repeat；

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_list,$file_in,$file_out) =@ARGV;

#bsaj_muntjac	27872	28198	+	L1MB7	LINE/L1
#bsaj_muntjac	28366	28551	C	L1_Art	LINE/L1
#bsaj_muntjac	29540	29624	+	Bov-B	LINE/BovB
#bsaj_muntjac	29625	29690	+	Bov-tA3	SINE/BovA


open LIST,"$file_list" || die "$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<LIST>) {
	chomp;
	$name{$_}=1;
}
while (<IN>) {
	chomp;
	@s=split /\t+/,$_;
	if (exists $name{$s[4]}) {
		print OUT "$_\n";
	}

}