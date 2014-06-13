#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<5) {
	print  "programm fasta_A fasta_B A_direction B_direction primer_out \n";
	exit;
}
($file_A,$file_B,$dire_A,$dire_B,$primer_out) =@ARGV;

open A,"$file_A" || die"$!";
open B,"$file_B" || die"$!";

open OUT,">$primer_out" || die"$!";

$seq_A = "";
while (<A>) {
	chomp;
	unless ($_ =~/^>/) {
		$seq_A = $seq_A.$_;
	}
}
if ($dire_A eq "C") {
	$seq_A = &dna_reverser($seq_A);
}

$seq_B = "";
while (<B>) {
	chomp;
	unless ($_ =~/^>/) {
		$seq_B = $seq_B.$_;
	}
}

if ($dire_B eq "C") {
	$seq_B = &dna_reverser($seq_B);
}

$length_A = length $seq_A;
$length_B = length $seq_B;
print "length_A <300bp!"if ($length_A <300);
print "length_B <300bp!"if ($length_B <300);

$cut_seq_A = substr $seq_A,$length_A-300,300;
$cut_seq_B = substr $seq_B,0,300;

$seq = $cut_seq_A.$cut_seq_B;

$config{TARGET}="150,300";

$dat_file_name = $primer_out.".in";
			open IN,">$dat_file_name" || die"$!";
			&put_primer_head;
			close IN;

			$out_file_name = $dat_file_name.".out";
			`primer3_core <$dat_file_name >$out_file_name `; 

			open IN,"$out_file_name" || die"$!";
			%info = ();
			while (my $line = <IN>) {
#				print $line;
				chomp $line;
				unless ($line eq "=") {

				my @fields = split "=",$line;
				$info{$fields[0]} = $fields[1];
#				print  "$fields[0]===$fields[1]\n";

				}
			}
			close IN;


	print OUT "$info{PRIMER_LEFT_SEQUENCE}\t$info{PRIMER_LEFT}\t$info{PRIMER_LEFT_GC_PERCENT}\t$info{PRIMER_LEFT_TM}\t$info{PRIMER_LEFT_PENALTY}\t";
	print OUT "$info{PRIMER_RIGHT_SEQUENCE}\t$info{PRIMER_RIGHT}\t$info{PRIMER_RIGHT_GC_PERCENT}\t$info{PRIMER_RIGHT_TM}\t$info{PRIMER_RIGHT_PENALTY}\n";

	foreach my $key (sort keys %info) {
		print "$key\n";
		if ($key =~/PRIMER_LEFT_(\d+)_SEQUENCE/) {
			$num = $1;
			$count[$num]=5;
		}
	}

$count = scalar @count -1;

for (my $k = 1;$k<$count+1 ;$k++) {
	$l_1 = "PRIMER_LEFT_$k"."_SEQUENCE";
	$l_2 = "PRIMER_LEFT_$k";
	$l_3 = "PRIMER_LEFT_$k"."_GC_PERCENT";
	$l_4 = "PRIMER_LEFT_$k"."_TM";
	$l_5 = "PRIMER_LEFT_$k"."_PENALTY";
	$r_1 = "PRIMER_RIGHT_$k"."_SEQUENCE";
	$r_2 = "PRIMER_RIGHT_$k";
	$r_3 = "PRIMER_RIGHT_$k"."_GC_PERCENT";
	$r_4 = "PRIMER_RIGHT_$k"."_TM";
	$r_5 = "PRIMER_RIGHT_$k"."_PENALTY";

	print OUT "$info{$l_1}\t$info{$l_2}\t$info{$l_3}\t$info{$l_4}\t$info{$l_5}\t";
	print OUT "$info{$r_1}\t$info{$r_2}\t$info{$r_3}\t$info{$r_4}\t$info{$r_5}\n";

}














sub put_primer_head{
print IN <<"map";
PRIMER_SEQUENCE_ID=$primer_out
SEQUENCE=$seq
PRIMER_OPT_SIZE=20
PRIMER_MAX_SIZE=23
PRIMER_MIN_SIZE=18
PRIMER_NUM_RETURN=1000
PRIMER_OPT_TM=59
PRIMER_MAX_TM=60
PRIMER_MIN_TM=58
TARGET=$config{TARGET}
PRIMER_PRODUCT_SIZE_RANGE="50-1000"
PRIMER_PRODUCT_OPT_SIZE=300
PRIMER_PAIR_WT_PRODUCT_SIZE_LT=.10
PRIMER_PAIR_WT_PRODUCT_SIZE_GT=.30
PRIMER_MIN_GC=20
PRIMER_MAX_GC=60
PRIMER_SALT_CONC=50
PRIMER_SELF_ANY=8
PRIMER_SELF_END=3
PRIMER_DNA_CONC=40
PRIMER_MAX_END_STABILITY=8
PRIMER_EXPLAIN_FLAG=1
=
map
}  



sub dna_reverser {
    my($Seq) = @_;
    $Rev_Seq = reverse($Seq);##
######
    $Rev_Seq =~ tr/[atgc]/[tacg]/;
    $Rev_Seq =~ tr/[ATGC]/[TACG]/;
    return($Rev_Seq);
}