#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 提取repeat位置信息
# 两个物种以上中存在的提取出来
# 2005-4-7 19:22
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";



#a score=22650.0
#s mouse 13268 165 + 68301 ---------------------------CCTTTACCCAGCCCCATAGTAACAAAGCTGTTTGAATCTTCAAACAGAAAGACCCTGAATGATG-TCTTGGAAGATGAATCAGATGACCTTGCCAGACCCAGCTCATTCACCACATCAATCTTTTAACTAAGCCATAGATCAcccttaa-------TTTTGCAAACTGTTCT
#s human 12816 169 + 84897 ---------------------------TTTTCAGCCAGCCCCACAGTAACAGAGCTGTTAGAAAATTTAAAAAGAAAAATCCTGAATGATGCTGTTAGTAGATAAATTAAGTGATCTTGCAAGACCCTTCTCATTTATTATATTAATACTTCAACTACATCATATTTAGTTAAaaa----cttTTGCATATTATCCTAC
#s dog   13338 198 + 70444 ctttctttcttttcttttttctttttttttttGGCCAGCCCCACAGTAACAGAGCTGTTTGAAAATGTAAGAAGAAAAATCCTGAAAGATGTCCTTAGATGATGAATCAAATGATCTTACAAGGCCCATCTCATTTATCATACTAATATCTCAGCTA--TCATATTTAGTAAAAAAAATTGTTTTAGCATATTGCTCTAC
#
#a score=0.0
#s dog 13536 3 + 70444 TAG
#
#a score=960.0
#s mouse 13433 31 + 68301 CTTTTAGCCTTTTGGGTG----------CACAATTGTCTTC
#s human 12985 41 + 84897 AATTTAACCTGTTTAGTAATTTTTTTTTCACAAACCCCTTT
#s dog   13539 34 + 70444 TATTTAACTTATTTATTT-------TTTTACAAACCCTGTT



while (<IN>) {
	chomp;
#	print "---$_\n";
	if ($_=~/^a/) {
		$score_line = $_;
#		print "\n\n$score_line\n";
		@specie=();
	}
# s bsba_human   5216 2164 + 112123 GGAAGCCTGTGGCTTAAAAAGGGCTGAATAACGACTGATATTCTCT-TCCTTCTCTCTTGGCTCTCACAGTCGAGGCTTTGGGCAATCCAACTCCCTCCCGACGGCT
# s bsba_mouse      7 1985 +  84395 GGCAGCCTGGG--CTATGTAGGGCTGGA----GCCAGAACCTCTGG-ATCTCTTCTCTTTGCTCTCACAGTCGTGGCTTTGGGCAGTCCAACTCCCTCCCAACAGCC
# s bsba_muntjac 5379 2216 +  91849 -----------GGCTGGGAAGGGCCGGG-GGTGACTGATGACCTCTGTTCTTCTCTATTGCCTCCCACAGCCGCGGCTTTGGGCAGTCCAACTCCCTCCCGACAGCC
# s bsba_dog       18 2274 +  85220 -----------GTTTGGGAAGGGCTGTG-GGTGACTGACAGGGTTT-CACTTGTCCATTCCCTCTCACAGCCGCGGCTTTGGGCAGTCCAACTCCCTCCCGACAGCC

	elsif ($_ =~/^s\s+(\w+)\s+(\d+)\s+\d+\s+\S\s+\d+\s+(.*)/) {
#		print "8888888888\n";
		$specie = $1;
#		print "speciefull  ==$specie\n";
		@s_specie = split "_",$specie;
		$specie = $s_specie[1];
		push @specie,$specie;#物种数计数
#		print  "aaaaaaaaaaaaaa $specie\n";
		$start = $2+1;# 以1开始计数
		$seq = $3;
		$seq{$specie} = $seq;
		if ($seq=~/a|c|t|g/) {
			@bases = split //,$seq;
			$base_pos = $start-1;#下面要累加
				$st=0;

			for (my $k=0;$k<@bases;$k++) {
#				print  "-";
				if ($bases[$k] ne "-") {
					$base_pos ++;
					#print  "|$base_pos|";
				}
				if ($bases[$k] =~/a|c|t|g/) {
					
					#print  "1\n";
					if ($st==0) {
#						print  "a$base_pos";
						push @{$starts{$specie}},$base_pos;
						$st =1;
					}
				}
				else {
					if ($bases[$k] ne "-" && $st==1) {
#						print  "A$base_pos";
						push @{$ends{$specie}},$base_pos-1;
						$st = 0;
					}
				}
			}
			if ($st==1) {
#						print  "A$base_pos";
						push @{$ends{$specie}},$base_pos;
						$st = 0;
			}
		}
#		print  "\n";
	}
	elsif ($_ eq "") {
	
	$count=0;
	if (scalar @specie ==4) {
	
	if (exists $starts{"mouse"}) {
		$count ++;
#		print  "1\n";
	}
	if (exists $starts{"human"}) {
		$count++;
#		print  "2\n";
	}
	if (exists $starts{"dog"}) {
		$count++;
#		print  "3\n";
	}
	if (exists $starts{"muntjac"}) {
		$count++;
#		print  "4\n";
	}
	if ($count>=2) {
#		print  "here~~\n";
		print OUT "$score_line\n";
		foreach my $key (keys %starts) {
#			print  "$key\n";
			if (exists $starts{$key}) {
				print OUT "$key\n";
				print OUT "$seq{$key}\n";
			
			for (my $k=0;$k<scalar @{$starts{$key}};$k++) {
				print OUT "${$starts{$key}}[$k]\t${$ends{$key}}[$k]\n";
			}

			}
		}
		print OUT "\n";
	}
	}
	%starts=();
	%ends=();
	%seq =();
	}
#	}
}

# 最后一行
# 
	$count=0;
	if (scalar @specie ==4) {

	if (exists $starts{"mouse"}) {
		$count ++;
#		print  "1\n";
	}
	if (exists $starts{"human"}) {
		$count++;
#		print  "2\n";
	}
	if (exists $starts{"dog"}) {
		$count++;
#		print  "3\n";
	}
	if (exists $starts{"muntjac"}) {
		$count++;
#		print  "4\n";
	}
	if ($count>=2) {
#		print  "here~~\n";
		print OUT "$score_line\n";
		foreach my $key (keys %starts) {
#			print  "$key\n";
			if (exists $starts{$key}) {

				print OUT "$key\n";
				print OUT "$seq{$key}\n";
			
			for (my $k=0;$k<scalar @{$starts{$key}};$k++) {
				print OUT "${$starts{$key}}[$k]\t${$ends{$key}}[$k]\n";
			}

			}
		}
		print OUT "\n";

	}
	}

