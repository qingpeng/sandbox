#!/usr/bin/perl -w

use strict;

if (@ARGV < 2) {
	print "perl matrix.dat fasta_file\n";
	exit;
}
my ($file_matrix,$file_in) = @ARGV;

open MATRIX,"$file_matrix";

my $ac = "";
my $matrix_start = 0;
my $pos;
my $A_count;
my $C_count;
my $G_count;
my $T_count;
my $A_score;
my $C_score;
my $G_score;
my $T_score;
my %score;


while (<MATRIX>) { # outer loop through each tranfac ,and score the mirna seq using the tranfac score,each tranfac has a score output
    chomp;
    if ($_=~/^AC\s\s(.*)/) {
        $ac = $1;
        %score = ();
    }
    elsif ($_=~/^P0\s/) {
        $matrix_start = 1;
    }
    elsif ($_=~/^XX/) {
        $matrix_start = 0;
    }
    elsif ($matrix_start == 1 && $_=~/(\d\d)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/) {
        $pos = $1-1; # count from 0~ 
        $A_count = $2;
        $C_count = $3;
        $G_count = $4;
        $T_count = $5;
        $A_score = ($A_count*100)/($A_count+$C_count+$G_count+$T_count);
        $C_score = ($C_count*100)/($A_count+$C_count+$G_count+$T_count);
        $T_score = ($T_count*100)/($A_count+$C_count+$G_count+$T_count);
        $G_score = ($G_count*100)/($A_count+$C_count+$G_count+$T_count);
		if ($A_score == 0) {
			$A_score = -3000;
		}
		if ($C_score == 0) {
			$C_score = -3000;
		}
		if ($T_score == 0) {
			$T_score = -3000;
		}
		if ($G_score == 0) {
			$G_score = -3000;
		}
					
        $score{A}->[$pos] = $A_score;
        $score{C}->[$pos] = $C_score;
        $score{G}->[$pos] = $G_score;
        $score{T}->[$pos] = $T_score;
    }
    elsif ($ac ne "" && $_=~/^\/\//) { #  meet the end of block and calculate the score
        my $seq = "";
        my $sub_seq;
        my $score;
        my $miRNA_id;
        my $motif_length = scalar @{$score{A}};
        open IN,"$file_in" || die"can't open $file_in:$!\n";
        my $file_out = $ac.".score";
        open SCORE,">$file_out";
        
        while (<IN>) {
            chomp;
            if (/>(.+)/) {
                unless ($seq eq "") {
                    my $seq_length = length $seq;
                    #print SCORE ">$miRNA_id\n";
                    for (my $k = 0;$k<=$seq_length-$motif_length;$k++) {
                        $sub_seq = substr $seq,$k,$motif_length;
                        $score = &score($sub_seq,\%score);
						my $best_score = $motif_length*100;
						my $percent = int($score*10000/$best_score)/100;
						if ($score >0){
							print SCORE "$ac\t$miRNA_id\t$k\t$score\t$best_score\t$percent\n";
						}
                    }
                }
                $miRNA_id = $1;
                $seq = "";
            }
            else {
                $seq = $seq.$_;
            }
        }
        
        # last_block
        
                    my $seq_length = length $seq;
                    #print SCORE ">$miRNA_id\n";
                    for (my $k = 0;$k<=$seq_length-$motif_length;$k++) {
                        $sub_seq = substr $seq,$k,$motif_length;
                        $score = &score($sub_seq,\%score);
						my $best_score = $motif_length*100;
						my $percent = int($score*10000/$best_score)/100;
						if ($score >0) {
							print SCORE "$ac\t$miRNA_id\t$k\t$score\t$best_score\t$percent\n";
						}
                    }
                    close SCORE;
    }
    else {
    }
}
      
      
      

sub score{
    my ($seq,$ref_score) = @_;
    my %score_here = %$ref_score;
    
    my @s_seq = split //,$seq;
    #print "$s_seq[1]\n";
    #print "$score{a}->[1]\n";
    my $score_all = 0;
    my $seq_length_here = length $seq;
    for (my $k = 0;$k<$seq_length_here;$k++){
    #    print "$k\t$s_seq[$k]\t$score{$s_seq[$k]}->[$k]\n";
        if ($s_seq[$k] eq "A" || $s_seq[$k] eq "C" || $s_seq[$k] eq "G" || $s_seq[$k] eq "T"){
		$score_all = $score_all+$score_here{$s_seq[$k]}->[$k];
	}
	else{
		$score_all = $score_all-3000;
	}
	
    }
    return $score_all;
}



        
                    
                    
      
        
