#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

($f_1,$f_2)=@ARGV;
open ORDER,"$f_1" || die"$!";
open PSL,"$f_2" || die"$!";

while (<PSL>) {
	chomp;
	@s =split /\t/,$_;
	$length{$s[13]} = $s[14];
}

#SuperScaffold000001.	82485
#	1	Scaffold000004. C	12139	Scaffold000004	U

while (<ORDER>) {
	chomp;
	if ($_=~/^Super/) {
		print  "$_\n";
	}
	else {
		@s = split /\t/,$_;
		@ss = split /\s/,$s[2];
		if ($s[-1] eq "U"||$s[-1] eq "C") {
			print  "here!!!!!!!!!!!!!!!1\n";
			print  "\t$s[1]\t$s[4]. $s[-1]\t$length{$s[4]}\n";
		}
		else {
			print  "\t$s[1]\t$s[4]. $ss[1]\t$length{$s[4]}\n";
		}

	}

}