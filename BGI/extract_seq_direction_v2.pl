#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 一般截取序列，考虑方向
# 带有名字在最后一列！
# 2004-11-24 21:46
# v2
# 2004-12-2 14:53 修改两个bug!
# 


if (@ARGV<2) {
	print  "programm pos_file fasta_file out_put_file\n";
	exit;
}
my ($pos_file,$fasta_file,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

open POS,"$pos_file" || die"$!";
# bsan	749	886	-

# chr10	-	27407456	27407542	NM_139312_exon_19
# chr10	-	27403391	27405055	NM_139312_exon_20
# chr10	+	121075469	121075954	NM_004281_exon_1
# chr10	+	121093950	121094276	NM_004281_exon_2
# chr10	+	121096354	121096755	NM_004281_exon_3
# chr10	+	121100563	121101914	NM_004281_exon_4
# 

while (my $line = <POS>) {
	chomp $line;
	my @fields = split /\t/,$line;
	my $name = $fields[0];
	push @{$start{$name}},$fields[2];
	push @{$end{$name}},$fields[3];
	push @{$dir{$name}},$fields[1]; # bug 2 2004-12-2 14:53
	push @{$seq_name{$name}},$fields[4];
}
close POS;

open FASTA,"$fasta_file" || die"$!";
$/=">";
my $null = <FASTA>;
my %mark;

while (my $block = <FASTA>) {
	chomp $block;
	my @lines = split /\n/,$block;
	my $title = shift @lines;
#	print  "title==$title\n";
	my @fields = split /\s+/,$title;
	my $id = $fields[0];
	if (exists $mark{$id}) { # modified :2004-3-2 15:29
		print  "$id\n";
	}
	else{
	
	if (defined $start{$id}) {
	
	my $seq = join "",@lines;
	for (my $k = 0;$k<scalar @{$start{$id}};$k++) {


	my $start = ${$start{$id}}[$k];
	my $end = ${$end{$id}}[$k];
	my $dir = ${$dir{$id}}[$k];
	my $seq_name =${$seq_name{$id}}[$k]; 
	my $length = $end - $start +1;
	my $sub_seq = substr $seq,$start-1,$length;
#	print  "dir==$dir\n";
	if ($dir eq "-") {
		$sub_seq = &dna_reverser($sub_seq);
	}
	print OUT ">$seq_name   $id"."_$start"."_$end"."_$dir\n";
	$length = length $sub_seq;   ## bug 1 2004-12-2 14:53
	$modulus = $length % 50;
	$sub_seq =~ s/(.{50})/$1\n/ig;
#	print  "modulus == $modulus\n";
				if ($modulus ==0) {
					print OUT "$sub_seq";
				}
				else {
					print OUT "$sub_seq\n";
				}

	}

	}
	
	$mark{$id} = 1;
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