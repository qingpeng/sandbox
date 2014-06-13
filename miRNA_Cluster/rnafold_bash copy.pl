#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";


#>N_65 MI0000000 Homo sapiens N_65 stem-loop
#caggaggcggaggttgcagtaagctgagatcgcgccattgcactccagcc
#tgggcaatagagcaaaactccgtctcaaaaaaaaaaagactgggcatggt
#ggctcacacctgtaatcccagcactttgggaggccaaggcgggtggatca
#cgaggtcaggagttcaagaccagcctggccaagatggtgaaatcctgtct
#ctattaaaaatacaaaaattagccgggtatggtggcgggcacctgtaatc
#c
#>N_113 MI0000000 Homo sapiens N_113 stem-loop
#actgcactccagcctgagcgacagagcaagactccatctccaaaaaagaa
#aaaCCAGGCATggctgggcacagtagctaaggcctgtaatcccaacactt
#


#>1
#UGCAAUAAAUCUUGCUGCUGCUCACUCUUUGGGUCUGCACUGCCUUUAUGAGCUGUAACACUCACUGCAAAGGUCUGCAGCUUCACUCCUGAAGCCAGUGAGACCACGAACCCACCAGAAGGAAGAAACUCCAAACACAUCUGAACAUCAGAAGGAACAAACUCCGGACACACCAUCUUUAAGAACUGUAACACUCACUGCGAGGGUCUGCGGCUUCAUUCUUGAAGUCAGU
#.........((((.((.(((.......(((((((((.(((((.((((((((((((((((.((........)))).)))))).)))....))))).)))))))))).)))).....))).)).))))...(((.......((((.....)))).(((......))))))........((((((((((((((((.(((.....))).)).))))).....)))))))))..... (-59.20)


my $seq = "";
my $id;
while (<IN>) {
    chomp;
        if ($_=~/^>(\w+)\s/) {
                if ($seq ne "") {
                        print TMP "$seq\n";
                        `RNAfold.exe <tmp.fa >tmp.fa.RNAfold`;
                        open RESULT,"tmp.fa.RNAfold" or die "Can't open $id result file $!";;
                        while (<RESULT>) {
                            chomp;
                            unless ($_=~/^>/ || $_=~/A|C|T|G/) {
                                if ($_=~/.*\(.*?(\d+\.\d+)\)/) {
                                    my $score = $1;
                                    print OUT "$id\t$score\n";
                                }
                            }
                        }
                        `rm tmp.fa.RNAfold`;
                        $seq = "";
                }
                $id = $1;
                open TMP,">tmp.fa";
                print TMP ">1\n"; # Ö»ÓÃÒ»¸öÃû³Æ£¡~~~
        }
        else {
            $seq = $seq.$_;
        }
}



print OUT "$seq\n";
                        print TMP "$seq\n";
                        `RNAfold <tmp.fa >tmp.fa.RNAfold`;
                        open RESULT,"tmp.fa.RNAfold" or die "Can't open $id result file $!";;
                        while (<RESULT>) {
                            chomp;
                            unless ($_=~/^>/ || $_=~/A|C|T|G/) {
                                if ($_=~/.*\(.*?(\d+\.\d+)\)/) {
                                    my $score = $1;
                                    print OUT "$id\t$score\n";
                                }
                            }
                        }

