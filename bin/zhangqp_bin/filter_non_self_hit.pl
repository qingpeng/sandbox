#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 从 21文件中去除比到自己的hit
# 2004-12-7 10:35
# # 做 Mouse oligo and human oligo 用到
# 
if (@ARGV<3) {
	print  "programm exon_pos file_in file_out \n";
	exit;
}
($file_pos,$file_in,$file_out) =@ARGV;

open POS,"$file_pos" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



# chr1	-	45656374	45656702	NM_002574_exon_1
# chr1	-	45653703	45653819	NM_002574_exon_2
# chr1	-	45650419	45650572	NM_002574_exon_3
# chr1	-	45649638	45649760	NM_002574_exon_4
# chr1	-	45649272	45649402	NM_002574_exon_5
# chr1	-	45645801	45646179	NM_002574_exon_6
while (<POS>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[1] eq "+") {
		$first{$s[4]} = $s[2];
		$second{$s[4]} = $s[3];
	}
	else {
		$first{$s[4]} = $s[3];
		$second{$s[4]} = $s[2];
	}
	$chr{$s[4]} = $s[0];
	$exon{$s[4]} = "1";
}


# NM_004984_exon_1	chr1	125	147	222884645	222884623	23
# NM_004984_exon_12	chr10	31	52	43010421	43010400	22
# NM_004984_exon_16	chr10	90	110	134957880	134957860	21
# NM_004984_exon_11	chr11	69	89	65815092	65815072	21
# NM_004984_exon_1	chr12	1	337	56230114	56230450	337
# NM_004984_exon_10	chr12	1	149	56249306	56249454	149


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	if ($s[1] eq $chr{$s[0]} && $s[4] eq $first{$s[0]} && $s[5] eq $second{$s[0]}) {
		$mark{$s[0]} = "1";
	}
	else {
		print OUT "$_\n";
	}
}

foreach my $key (keys %exon) {
	unless (exists $mark{$key}) {
		print  "not_map: $key\n";
	}
}





