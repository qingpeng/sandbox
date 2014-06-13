#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# human_nm-->human_pep-->mouse_pep-->mouse_nm
# build the relations!
# 
if (@ARGV<4) {
	print  "programm file_human_nm2pep(203pep.gp.link) file_human2mouse_pep(all.blastp.eblastn.best) file_mouse_pep_nm(refLink.txt) file_out \n";
	exit;
}
($file_1,$file_2,$file_3,$file_out) =@ARGV;

open ONE,"$file_1" || die"$!";
open TWO,"$file_2" || die"$!";
open THREE,"$file_3" || die"$!";

open OUT,">$file_out" || die"$!";

# NM_033664	NP_387513
# BC014469	AAH14469
# NM_002607	NP_002598
# BC012142	AAH12142
# NM_033194	NP_149971
# AF395440	AAK73122

# human_in-->human_pep
while (<ONE>) {
	chomp;
	@s = split /\t/,$_;
	$human_pep{$s[0]} = $s[1];
}


# AAC25085	NP_032693	0.0
# AAC28912	NP_034836	2e-16
# AAC28913	NP_032017	1e-137
# AAC28914	NP_034222	0.0

# human_pep -->mouse_pep
while (<TWO>) {
	chomp;
	@s =split/\t/,$_;
	$mouse_pep{$s[0]} = $s[1];
}

# Tbp	TATA box binding protein	NM_013684	NP_038712	8627	41736	21374	0
# Tcap	titin-cap	NM_011540	NP_035670	83222	154571	21393	0
# Ssbp2	single-stranded DNA binding protein 2	NM_024272	NP_077234	77762	143747	66970	0
# Tbc1d12	TBC1D12: TBC1 domain family, member 12	NM_145952	NP_666064	107329	143880	209478	0
# mouse_pep -->mouse_nm
while (<THREE>) {
	chomp;
	@s = split /\t/,$_;
	$mouse_nm{$s[3]} = $s[2];
}


foreach my $key (sort keys %human_pep) {
	print OUT "$key\t$human_pep{$key}\t$mouse_pep{$human_pep{$key}}\t$mouse_nm{$mouse_pep{$human_pep{$key}}}\n";
}



