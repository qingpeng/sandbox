#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# v2 mark added 2004-2-9 11:26
# v3 reverse the sequence if the map direction and the gene direction are not the same..   2004-2-10 13:58
# pos is the actural position!count from 1 
# 
# v3_for_blastx_data2.pl
# 先取反再截取序列，针对data2,data3 blastx table 仅仅对于blastx结果的
#　
# !! 考虑fasta有重复 2004-3-5 13:39 extract_seq_v3.pl 仍需要修改~

# 2004-7-18 15:44 修改
# extract_seq_v4.pl  
# 先截取序列再取反！ Data13不再是blastx的Table 
# 与 v3_for_blastx_data2.pl 的区别仅仅是先取序列再取反！
# 

if (@ARGV<2) {
	print  "programm pos_file fasta_file > out_file\n";
	exit;
}
my ($pos_file,$fasta_file) =@ARGV;

open POS,"$pos_file" || die"$!";
while (my $line = <POS>) {
	chomp $line;

# dpbxa0_098952.z1.scf    81      275     +       -1
# rcpg0_141475.y1.abd     461     633     +       -1
# rdpcxa0_043560.y1.scf   373     463     -       -1
# dpcxa0_090276.z1.scf    3       82      +       -1
# cpg0_128938.z1.abd      387     566     +       -1
# rdpdxb0_001487.y1.scf   130     302     -       -1
# dpaxb0_021460.z1.scf    15      186     -       -1
# rcpg0_096453.y1.abd     343     539     +       -1

	my @fields = split /\t/,$line;
	my $name = $fields[0];
			if ($name =~/singleton_(.*)/) {
				$name = $1;
			}  # 2004-3-1 19:34 modified

	push @{$start{$name}},$fields[1];
	push @{$end{$name}},$fields[2];
	push @{$mark{$name}},$fields[3];
	push @{$gene_direction{$name}},$fields[4];


}
close POS;

open FASTA,"$fasta_file" || die"$!";
$/=">";
my $null = <FASTA>;
my %mark2;

while (my $block = <FASTA>) {
	chomp $block;
	my @lines = split /\n/,$block;
	my $title = shift @lines;
	my @fields = split /\s+/,$title;
	my $id = $fields[0];
	if (exists $start{$id}) {
		if (exists $mark2{$id}) {# modified 2004-3-5 13:35 fasta 中有重复 
			print  "$id\n";
		}
		else {
			
		
	
	my $seq = join "",@lines;
	for (my $k = 0;$k<scalar @{$start{$id}};$k++) {


	my $start = ${$start{$id}}[$k];
	my $end = ${$end{$id}}[$k];
	my $mark = ${$mark{$id}}[$k];
	my $gene_direction = ${$gene_direction{$id}}[$k];

	if ($gene_direction eq "1") {
		$gene_dire = "+";
	}
	else {
		$gene_dire = "-";
	}


	my $length = $end - $start +1;
	my $sub_seq = substr $seq,$start-1,$length;
	
	if ($mark ne $gene_dire) {#　先 截取序列再取反！！ 
		$final_seq = &dna_reverser($sub_seq);
	}
	else {
		$final_seq = $sub_seq;
	}
	
#	if (($mark eq "+" && $gene_direction eq "1")||($mark eq "-" && $gene_direction eq "-1") ) {
#	}
	print  ">$id"."_$start"."_$end $mark $gene_direction\n";
	$final_seq =~ s/(.{50})/$1\n/ig;
	print  "$final_seq\n";

	}
	$mark2{$id} = 1;

	}
	}
}

sub dna_reverser {
    my($Seq) = @_;
    $Rev_Seq = reverse($Seq);##
######
    $Rev_Seq =~ tr/[atgc]/[tacg]/;
    $Rev_Seq =~ tr/[ATGC]/[TACG]/;
    return($Rev_Seq);
}