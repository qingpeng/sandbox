#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# join the scaffold to BAC with "N"
# 2005-3-14 15:03
# 
if (@ARGV<4) {
	print  "programm original_scaffold_file file_order BAC_name join_bac_file \n";
	exit;
}
($file_scaffold,$file_list,$bac_name,$file_out) =@ARGV;

open SCA,"$file_scaffold" || die"$!";
open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";



#>Scaffold000001 2004-04-29 BGI
#CTCGGTACCAGGAAATGTCTCTGCTCTCAGATACCTTATAATATAGCTAA
#ATTGTCTGATTATGGCAACTCAGGATAATTGTAAGCCAAGTCTAATATAG
#AACTGTGTCTTTAAAACAAAAGAGTGGTTAGTTTTGGATGTGTTTCATCT



$/=">";
my $null = <SCA>;# 要特殊处理第一行！ 
#my %seq_length;
#my %drop;
#my %all;

while (<SCA>) {
#	print  "ddd!\n";
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];
	$seq{$id} = join "",@lines;
#	print  "$id\n$seq{$id}\n";
}

#++	Scaffold000022	546	-	331	545	215	79890	80092	203
#+	Scaffold000020	787	+	2	786	785	80781	81558	778
#	Scaffold000007		+
#	Scaffold000017		+
#+	Scaffold000006	3453	+	1578	3453	1876	88303	90504	2202
#	Scaffold000019		+
#+	Scaffold000008	2334	-	233	1454	1222	93210	94461	1252
$seq = "";
$k = 0;
my %test;
$/="\n";
while (<LIST>) {
	chomp;
	unless ($_ eq "") {
	
	@s = split /\t/,$_;
	$name = $s[1];
	
	if (exists $test{$name}) {
		print  "Warning... $name has replication !";
	}
	$test{$name} = 1;
	$direction = $s[3];
	$file_seq = $seq{$name};
#	print  "$name\n$file_seq\n";
	unless ($k == 0) {
		$seq = $seq."NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN";
	}
	if ($direction eq "-") {
		$file_seq = &dna_reverser($file_seq);
	}
	$seq = $seq.$file_seq;
	$k=1;

	}
}


$seq=~s/(.{50})/$1\n/ig;

print  "=============== $bac_name =================\n";
print OUT ">$bac_name\n$seq\n";


#-----------------------------------------------------
sub dna_reverser {
    my($Seq) = @_;
    $Rev_Seq = reverse($Seq);##
######
    $Rev_Seq =~ tr/[atgc]/[tacg]/;
    $Rev_Seq =~ tr/[ATGC]/[TACG]/;
    return($Rev_Seq);
}
