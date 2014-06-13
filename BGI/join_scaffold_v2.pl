#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 修改 重做时的scaffold_order.list 格式
# 2004-5-31 14:52
# 

if (@ARGV<4) {
	print  "programm list scaffold_dir file_out seq_title\n";
	exit;
}
($list,$in_dir,$file_out,$title) =@ARGV;

open LIST,"$list" || die"$!";
open OUT,">$file_out" || die"$!";
$seq = "";
$k = 0;

# +++	Scaffold000004	13090	-	11483	12291	809	46282	46938	657
# ++	Scaffold000002	15216	-	14579	14677	99	68620	68717	98
# ++	Scaffold000007	8328	-	6073	8303	2231	93187	95617	2431
# +++	Scaffold000003	14378	-	13278	14073	796	102052	102872	821


while ($line = <LIST>) {
	chomp $line;
	@s =split /\t/,$line;
	$name = $s[1];
	$direction = $s[3];

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