#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# pick the alignment located in the region that BAC map to human genome and have repeat in the human sequence
# 2005-3-3116:50
# 
if (@ARGV<3) {
	print  "programm pos_file file_in file_out \n";
	exit;
}
($file_pos,$file_in,$file_out) =@ARGV;


open POS,"$file_pos" || die"$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


#bsaa	chr1	157595497	157645825
#bsab	chr3	12173310	12290136
#bsac	chr15	99182814	99274349
#bsae	chr16	12062198	12188295

while (<POS>) {
	chomp;
	@s = split /\t/,$_;
	$chro{$s[0]} = $s[1];
	$start{$s[0]} = $s[2];
	$end{$s[0]} = $s[3];
}




#a score=8551.0
#s hg17.chr9_random         2549 7 +   1312665 CTTCTCT
#s panTro1.chr11_random  4556929 7 -  53199993 CTTCTCT
#s mm5.chr2             27053539 7 + 181686250 CTTCTCC
#s rn3.chr3              5989113 7 + 170969371 CTTCTCC
#s canFam1.chr9         42486905 7 +  53642819 CTTCTTC
#s fr1.chrUn            61093446 7 + 349519338 CTCCTTT
#s danRer1.chr5          1300204 7 -  40038624 CTGTTCT
#
#a score=50277.0
#s hg17.chr9_random         2556 33 +   1312665 T--TCCCTAGGTGTGGAACCAGAACGGCAAAAGCC
#s panTro1.chr11_random  4556936 33 -  53199993 T--TCCCTAGGTGTGGAACCAGAACGGCAAAAGCC
#s mm5.chr2             27053546 33 + 181686250 T--TTCCCAGGTGTGGAACCAGAACGGCAAAAGCC
#s rn3.chr3              5989120 33 + 170969371 T--TTCCCAGGTGTGGAACCAGAACGGCAAAAGCC
#s canFam1.chr9         42486912 35 +  53642819 TCCTCCCCAGGTATGGAACCAGAACGGCAAAAGCC
#s galGal2.chr17         7204812 33 -  10632206 T--TTGCTAGGTCTGGAATCAAAATGGCAAAAATC
#s fr1.chrUn            61093459 33 + 349519338 T--CACACAGGTGTGGAACCAGAATGGACGTGCCC
#s danRer1.chr5          1300211 33 -  40038624 --CTCAAAAGGTCTGGAACCAGAATGGGCAAAATC


#a score=45657.0
#s hg17.chr1         1542 179 + 245522847 ctggagattctta---------------------------------------------ttagtgatttgggctgggg-cctggccatgtgtatttt------------------------------------ttta-aatttccactgatgattttgctgcatggc--cggtgttgagaatgactgCG-CAAATTTGCC-GGATTTCCTTTGCTGTTCCTGCATGTAGTTTAAACGAGATTGCCAGCACCGGGTATCATTCAC----------------------------------------------CAT

while (<IN>) {
	chomp;
	$line = $_;
#	print  "!!!!!!!!\t$_\n";
	if ($_ =~/^a/) {
		$score_line = $_;
		$mark = 0;
	}
	elsif ($_=/s\shg17\.(\S+)\s+(\d+)\s(\d+)\s\S\s+\d+\s(\S+)/) {
#	elsif ($_=/^s/) {
#		print  "here!!!\n";

		$chro = $1;
		$base_num = $3;
		$start = $2;
		$seq = $4;
#		print  "chro=$chro\tbase_num=$base_num\tstart=$start\nseq=$seq\n\n";
		foreach my $key (keys %chro) {
#			print  "$key\t$chro{$key}\tbac_start==$start{$key}\tstart==$start\tbac_end==$end{$key}\n";
			if ($chro{$key} eq $chro && $start{$key}-1000<=$start && $end{$key}+1000>=$start+$base_num-1 && $seq =~/a|c|t|g/) {
#				print  "kkkkkkkkkkkkk\n";
				print OUT "$score_line\n$line\n";
				$mark = 1;
			}
		}
	}
	else {
		if ($mark == 1) {
			print OUT "$line\n";
		}
	}
}

