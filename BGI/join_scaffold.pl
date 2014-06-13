#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<4) {
	print  "programm list scaffold_dir file_out seq_title\n";
	exit;
}
($list,$in_dir,$file_out,$title) =@ARGV;

open LIST,"$list" || die"$!";
open OUT,">$file_out" || die"$!";
$seq = "";
$k = 0;
# Scaffold000013	2344	-	89127	91668
# Scaffold000007	6229	+	91674	96765


while ($line = <LIST>) {
	chomp $line;
	@s =split /\t/,$line;
	$name = $s[0];
	$direction = $s[2];

	unless ($k == 0) {
		$seq = $seq."NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN";
	}
	$file_in = $in_dir.$name.".fa";
	$file_seq = "";
	open S,"$file_in" || die"$!";
	while (<S>) {
		chomp;
		unless ($_=~/^>/) {
			$file_seq = $file_seq.$_;
		}
	}
	close S;
	if ($direction eq "-") {
		$file_seq = &dna_reverser($file_seq);
	}
	$seq = $seq.$file_seq;

	$k=1;
}


$seq=~s/(.{50})/$1\n/ig;

print OUT ">$title\n$seq\n";


#-----------------------------------------------------
sub dna_reverser {
    my($Seq) = @_;
    $Rev_Seq = reverse($Seq);##
######
    $Rev_Seq =~ tr/[atgc]/[tacg]/;
    $Rev_Seq =~ tr/[ATGC]/[TACG]/;
    return($Rev_Seq);
}