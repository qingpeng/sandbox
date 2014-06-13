#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 一般截取序列，考虑方向
# bsan	749	886	-


if (@ARGV<2) {
	print  "programm pos_file fasta_file out_put_file\n";
	exit;
}
my ($pos_file,$fasta_file,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

open POS,"$pos_file" || die"$!";
# bsan	749	886	-

while (my $line = <POS>) {
	chomp $line;
	my @fields = split /\s/,$line;
	my $name = $fields[0];
	push @{$start{$name}},$fields[1];
	push @{$end{$name}},$fields[2];
	push @{$dir{$name}},$fields[3];
}
close POS;
print "@start";
open FASTA,"$fasta_file" || die"$!";
$/=">";
my $null = <FASTA>;
my %mark;

while (my $block = <FASTA>) {
	chomp $block;
	my @lines = split /\n/,$block;
	my $title = shift @lines;
	my @fields = split /\s+/,$title;
	my $id = $fields[0];
	if (exists $mark{$id}) { # modified :2004-3-2 15:29
		print  "$id\n";
	}
	else{
		#print "$id\n";
	
	if (defined $start{$id}) {
	print "$id\n";# tessteststests
	my $seq = join "",@lines;
	for (my $k = 0;$k<scalar @{$start{$id}};$k++) {


	my $start = ${$start{$id}}[$k];
	my $end = ${$end{$id}}[$k];
	my $dir = ${$dir{$id}}[$k];
	my $length = $end - $start +1;
	my $sub_seq = substr $seq,$start-1,$length;
	if ($dir eq "-") {
		$sub_seq = &dna_reverser($sub_seq);
	}
	print "$seb_seq\n";
	print OUT ">$id"."_$start"."_$end"."_$dir\n";
	$sub_seq =~ s/(.{50})/$1\n/ig;
	$length = length $sub_seq;
	$modulus = $length % 50;
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