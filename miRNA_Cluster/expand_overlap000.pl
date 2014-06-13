#!/usr/bin/perl -w
use strict;
# 尽可能的延长覆盖
# 取最终的两端坐标
# 2007-9-20 13:01
# 


if (@ARGV < 2) {
    print "perl *.pl file_in file_out \n";
    exit;
}
my ($file_in,$file_out) = @ARGV;

open IN, "$file_in"     or die "Can't open $file_in $!";
open OUT,">$file_out";

#N_3286204       28.64060725681724741314676093392        N_3286204       chr13   -       66678419        66678442
#N_558118        28.64060725681724741314676093392        N_558118        chr13   -       66678419        66678441
#N_3595507       28.64060725681724741314676093392        N_3595507       chr13   -       66678419        66678443
#N_2975410       28.64060725681724741314676093392        N_2975410       chr13   -       66678419        66678444
#N_2058206       28.64060725681724741314676093392        N_2058206       chr1    -       2315591 2315613
#N_848478        28.64060725681724741314676093392        N_848478        chr13   -       66678419        66678447
#N_3431959       28.64060725681724741314676093392        N_3431959       chr13   -       66678419        66678445
#N_1328267       28.60942059589072000054680330252        N_1328267       chr10   +       49624080        49624108
#N_399879        28.57222837327005792619899177319        N_399879        chr15   +       62616430        62616453
#N_3286326       28.57222837327005792619899177319        N_3286326       chr15   +       62616431        62616453
#N_694485        28.57222837327005792619899177319        N_694485        chr15   +       62616423        62616445
#N_67874 28.57222837327005792619899177319        N_67874 chr15   +       62616424        62616452
#N_1625973       28.57222837327005792619899177319        N_1625973       chr15   +       62616430        62616452
#N_1837671       28.55634024174276086909460865369        N_1837671       chr10   -       27535562        27535587
#N_1095068       28.54910875059318541074998328679        N_1095068       chr1    +       64020980        64021008
#N_3604508       28.53353424980181370760023868052        N_3604508       chr3    -       17721853        17721878
#N_810296        28.51668441518129440095797509157        N_810296        chr5    -       64747571        64747594
#N_810295        28.51668441518129440095797509157        N_810295        chr5    -       64747425        64747446
#N_810380        28.51512097234566612188837864934        N_810380        chr8    +       56528014        56528037


open LOG,">test.log";
my $old_score = 0;
my @new_lines;
my @lines;

while (<IN>) {
    chomp;

    my @s =split /\s+/,$_;
    print  "$_\n";
    print  "$s[1]\n";
    if ($s[1] != $old_score) {
        if ($old_score !=0) {
#            foreach my $line (@lines) {
#                print LOG "$line\n";
#            }
            @new_lines = &get_pos(\@lines);
            foreach my $line (@new_lines) {
                print OUT "$line\n";
            }
        }
        @lines=();
        push @lines,$_;
        $old_score = $s[1];
    }
    else {
        push @lines,$_;
    }
}

                @new_lines = &get_pos(\@lines);
            foreach my $line (@new_lines) {
                print OUT "$line\n";
            }








sub get_pos {
    my ($ref_lines) = @_;
    my @lines = @{$ref_lines};
    my $ref_new_lines;

    my $overlap_mark = 1;
#        while ($overlap_mark==1) {
            ($ref_new_lines,$overlap_mark) = &get_pos2(\@lines);
#            @lines = @{$ref_new_lines};
           
#        }
        my @new_lines = @{$ref_new_lines};
        return @new_lines;

}


sub get_pos2 {
    my ($ref_lines) = @_;
    my @lines = @{$ref_lines};
            foreach my $line (@lines) {
                print LOG "aaa$line\n";
            }


    my @new_lines = ();
    push @new_lines,$lines[0];
    my $mark_overlap = 0;
    for (my $kk = 1;$kk<scalar @lines ;$kk++) {
        my $line = $lines[$kk];
        my $have_overlap = 0; # 判断是否与上面有overlap
        print LOG "oldline:$kk\n$lines[$kk]\n";
        my @s_line = split /\s+/,$line;
        for (my $k = 0;$k<scalar @new_lines ;$k++) {
            my @s_new_line = split /\s+/,$new_lines[$k];
            print LOG "line:$k\n$new_lines[$k]\n";
            
            if ($s_new_line[3] eq $s_line[3] && $s_new_line[4] eq $s_line[4] && $s_new_line[5]<$s_line[6] && $s_new_line[6]>$s_line[5]) {
                $mark_overlap = 1;
                $have_overlap = 1;
                print LOG "a$s_new_line[3]\t$s_line[3] $s_new_line[4]  $s_line[4]  $s_new_line[5]  $s_line[6]  $s_new_line[6]  $s_line[5]\n";
                my $new_start;
                my $new_end;
                my $new_line;
                if ($s_line[5]<$s_new_line[5]) {
                    $new_start = $s_line[5];
                }
                else {
                    $new_start = $s_new_line[5];
                }
                if ($s_line[6]>$s_new_line[6]) {
                    $new_end = $s_line[6];
                }
                else {
                    $new_end = $s_new_line[6];
                }
                $new_line = "NN\t$s_new_line[1]\tNN\t$s_new_line[3]\t$s_new_line[4]\t$new_start\t$new_end";
                print LOG "newline:$k\n$new_line\n";
                
                $new_lines[$k] = $new_line;
            }
            if ($have_overlap == 0) {
            }
                push @new_lines,$line;
        }
    }
                foreach my $line (@new_lines) {
                print LOG "bbb$line\n";
            }
    return (\@new_lines,$mark_overlap);
}









