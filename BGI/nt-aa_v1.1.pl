#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"i:s","o:s","s:s","e:s");
my $ver = "1.0";
my $usage=<<"USAGE";
	Program : translate NT sequence to AA sequence 
	Version : $ver
	Contact : zhangqp
	Usage : $0 [options]
		-i		file in 
		-o		file out
		-s		start position,optional
		-e		end position,optional
USAGE

die $usage unless $opts{"i"}and$opts{"o"};

my $file_in = $opts{"i"};
my $file_out = $opts{"o"};
my $start = $opts{"s"};
my $end = $opts{"e"};


open IN,"$file_in" || die"Can't open $file_in:$!";
open OUT,">$file_out" || die"Cant't open $file_out:$!";


my @in = <IN>;
chomp @in;
close IN;


my $c_exon_dna = join "",@in;
my $exon_protein;
if ($start >0 && $end>0) {
	 $exon_protein = translate_frame($c_exon_dna,$start,$end);
}
elsif ($start >0) {
	 $exon_protein = translate_frame($c_exon_dna,$start);
}
else {
	 $exon_protein = translate_frame($c_exon_dna);
}


print OUT "$exon_protein\n";
print  "aaa$exon_protein\n";











# codon2aa
#
# A subroutine to translate a DNA 3-character codon to an amino acid
#   Version 2

sub codon2aa {
    my($codon) = @_;
 
       if ( $codon =~ /GC./i)        { return 'A' }    # Alanine
    elsif ( $codon =~ /TG[TC]/i)     { return 'C' }    # Cysteine
    elsif ( $codon =~ /GA[TC]/i)     { return 'D' }    # Aspartic Acid
    elsif ( $codon =~ /GA[AG]/i)     { return 'E' }    # Glutamic Acid
    elsif ( $codon =~ /TT[TC]/i)     { return 'F' }    # Phenylalanine
    elsif ( $codon =~ /GG./i)        { return 'G' }    # Glycine
    elsif ( $codon =~ /CA[TC]/i)     { return 'H' }    # Histidine
    elsif ( $codon =~ /AT[TCA]/i)    { return 'I' }    # Isoleucine
    elsif ( $codon =~ /AA[AG]/i)     { return 'K' }    # Lysine
    elsif ( $codon =~ /TT[AG]|CT./i) { return 'L' }    # Leucine
    elsif ( $codon =~ /ATG/i)        { return 'M' }    # Methionine
    elsif ( $codon =~ /AA[TC]/i)     { return 'N' }    # Asparagine
    elsif ( $codon =~ /CC./i)        { return 'P' }    # Proline
    elsif ( $codon =~ /CA[AG]/i)     { return 'Q' }    # Glutamine
    elsif ( $codon =~ /CG.|AG[AG]/i) { return 'R' }    # Arginine
    elsif ( $codon =~ /TC.|AG[TC]/i) { return 'S' }    # Serine
    elsif ( $codon =~ /AC./i)        { return 'T' }    # Threonine
    elsif ( $codon =~ /GT./i)        { return 'V' }    # Valine
    elsif ( $codon =~ /TGG/i)        { return 'W' }    # Tryptophan
    elsif ( $codon =~ /TA[TC]/i)     { return 'Y' }    # Tyrosine
    elsif ( $codon =~ /TA[AG]|TGA/i) { return '_' }    # Stop
    else {
        print STDERR "Bad codon \"$codon\"!!\n";
    }
}


# dna2peptide 
#
# A subroutine to translate DNA sequence into a peptide

sub dna2peptide {

    my($dna) = @_;

    use strict;
    use warnings;

    # Initialize variables
    my $protein = '';

    # Translate each three-base codon to an amino acid, and append to a protein 
    for(my $i=0; $i < (length($dna) - 2) ; $i += 3) {
        $protein .= codon2aa( substr($dna,$i,3) );
    }

    return $protein;
}


# revcom 
#
# A subroutine to compute the reverse complement of DNA sequence

sub revcom {

    my($dna) = @_;

    # First reverse the sequence
    my $revcom = reverse($dna);

    # Next, complement the sequence, dealing with upper and lower case
    # A->T, T->A, C->G, G->C
    $revcom =~ tr/ACGTacgt/TGCAtgca/;

    return $revcom;
}


# translate_frame
#
# A subroutine to translate a frame of DNA

sub translate_frame {

    my($seq, $start, $end) = @_;

    my $protein;

    # To make the subroutine easier to use, you won't need to specify
    #  the end point--it will just go to the end of the sequence
    #  by default.
    unless($end) {
        $end = length($seq);
    }

    # Finally, calculate and return the translation
        return dna2peptide ( substr ( $seq, $start - 1, $end -$start + 1) );
}
