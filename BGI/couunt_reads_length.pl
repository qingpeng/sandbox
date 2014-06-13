#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<3) {
	print  "programm fasta_file every_reads_length all_reads_length_in_db \n";
	exit;
}
($file_in,$file_out,$db_reads_length) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";
open ALL,">$db_reads_length" || die"$!";

$/=">";
my $null=<IN>;
while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];

# bsaax0_000101.z1.scf
# rbsbh0_000183.y1.scf
	@ss = split "0_",$id;
	$db_id = $ss[0];
		if ($db_id=~/^r(\w+)/) {
			$db_id=$1;
		}
			if ($db_id =~/(\w\w\w\w)x/) {
				$db_id = $1;
			}

#		if ($db_id eq "") {
#			print  "TITLE===$title\nDB=$db\n";
#		}
	$seq = join "",@lines;
	$length=length $seq;
	$length_all{$db_id} = $length_all{$db_id}+$length;
	print OUT "$id\t$length\n";
}

foreach my $key (sort keys %length_all) {
#	print  "key===$key\n";
	print ALL "$key\t$length_all{$key}\n";
}