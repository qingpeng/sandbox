#!/usr/bin/perl -w
# 2005-6-7 14:47
use strict;
use Bio::SeqIO;

if (@ARGV < 3) {
	print "perl id_list seq_file file_selected \n";
	exit;
}
my ($file_list,$file_in,$file_out) = @ARGV;

open LIST,"$file_list";

my %hash;

while (<LIST>) {
	chomp;
	print "$_ 000\n";
	$hash{$_} = "yes";
}

my $in  = Bio::SeqIO->new('-file' => $file_in ,'-format' => 'Fasta');
my $out = Bio::SeqIO->new('-file' => ">>$file_out" , '-format' => 'Fasta');
    while ( my $seq = $in->next_seq() ) {
		my $display_id = $seq->display_id(  );
		#print "$display_id\n";
		if ( exists $hash{$display_id}) {
			print "HIT----------\n";
	        $out->write_seq($seq);
		}
    }
