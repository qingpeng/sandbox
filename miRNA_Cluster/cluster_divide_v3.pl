#!/usr/bin/perl -w
use strict;
# ??cluster,?????cluster?????????
# 2005-08-11 10:57
# 直接生成noa格式文件
# 提供 cluster第一个和最后一个gene信息 2005-11-10 13:52
# 


my $file_eda = "HsNetwork_brainAging.eda";
my $file_cdt = "HsNetwork_brainAging_PCC0.4.cdt";
my $file_gtr = "HsNetwork_brainAging_PCC0.4.gtr";

my $file_noa = "HsNetwork_brainAging_PCC0.4.noa";
my $file_noa2 = ""; # gene number 
my $file_log = "cluster_log.txt";

my $cutoff = "0.01";# ($neg/$all     0<=cutoff<1)
#
#if (@ARGV < 5) {
#        print "perl file_eda(protein) file_cdt(symbol) file_gtr(tree) file_log file_noa \n";
#        exit;
#}
#my ($file_eda,$file_cdt,$file_atr,$file_out,$file_out2) = @ARGV;
#

# deal with eda file ,mark the direction
# eda
#G3BP (pp) RASA1 = .421106683224055
#G3BP (pp) USP10 = .593587962199842
#CEBPZ (pp) TP53 = -.402397208859846
#TRIM28 (pp) CBX1 = .722448616026243
#TRIM28 (pp) SETDB1 = .444501321932038
#WASF2 (pp) BAIAP2 = -.411778705654106
#WASF2 (pp) GRB2 = .521116997043155
open EDA,"$file_eda";

my %neg; # negetive direction
my %interaction;

<EDA>;
while (<EDA>){
    chomp;
    my @s1 = split /\s=\s/,$_;
        my @s2 = split /\s\(pp\)\s/,$s1[0];
        my $n1 = $s2[0]."-".$s2[1];
        my $n2 = $s2[1]."-".$s2[0];

    if ($s1[1] =~/-/){
        $neg{$n1} = 1;
        $neg{$n2} = 1;
        $interaction{$n1} = 1;
        $interaction{$n2} = 1;
    }
    else {
        $interaction{$n1} = 1;
        $interaction{$n2} = 1;
    }
}




# deal with cdt file ,just pick the genename--genesymbol relation
#GENE249X        2138        EYA1        1.000000        0.001215...
#GENE868X        6495        SIX1        1.000000        0.026978...

open CDT,"$file_cdt";
my %name;
my %gene_number;
my %order;
my $order = 1; # 顺序
while (<CDT>){
    chomp;
    if ($_=~/^GENE/){
        $order++;
        my @s =split /\t/,$_;
        $name{$s[0]} = $s[2];
        $gene_number{$s[0]} = $s[1];
        $order{$s[0]} = $order;
    }
}





open ATR,"$file_gtr";

#NODE5X        GENE161X        NODE3X        0.922378
#NODE6X        GENE903X        GENE1222X        0.920849
#NODE7X        GENE610X        GENE1129X        0.919668
#NODE8X        GENE443X        GENE976X        0.919312
#NODE9X        GENE429X        GENE634X        0.917709
#NODE10X        GENE372X        GENE722X        0.912280
#NODE11X        GENE506X        NODE2X        0.900166
#NODE12X        NODE11X        GENE708X        0.900166
#NODE13X        GENE820X        GENE1149X        0.899474
#NODE14X        GENE381X        GENE1234X        0.894773
#NODE15X        GENE297X        GENE460X        0.894396
#NODE16X        GENE254X        GENE639X        0.890947


my @hub=();
my %array;
my @node;


while (<ATR>) {
        chomp;
        my @s = split /\t/,$_;
        push @hub,$s[0];

        if ($s[1] =~/GENE/) {
                push @node,$s[1];
                push @{$array{$s[0]}},$s[1];
        }
        else {
                push @{$array{$s[0]}},@{$array{$s[1]}};
        }

        if ($s[2] =~/GENE/) {
                push @node,$s[2];
                push @{$array{$s[0]}},$s[2];
        }
        else {
                push @{$array{$s[0]}},@{$array{$s[2]}};
        }
}

my @final_cluster;
my @cluster;
my $m = 0;
my %mark;
my @score;
my @neg;
my @all;
my @hub_name;
for (my $k=scalar @hub-1;$k>=0 ;$k--) { # 从 大cluster开始分离
        @cluster = @{$array{$hub[$k]}};
        #print "$k -- @cluster\n";

        my $switch =1;
        foreach my $point (@cluster) { # 看是不是上一级cluster已经符合要求了？？
                if (exists $mark{$point}) {
                        $switch = 0;

                }
        }

        if ($switch == 1) {
        my @ss =&score(\@cluster,\%name,\%interaction,\%neg);
        #print "cluster==@cluster\nscore==$score\n";
        if ($ss[0] < $cutoff || $ss[0] ==2) { # 没有相互关系或者附相互关系为0 符合条件
                $m++;
                @{$final_cluster[$m]} = @cluster;
                $score[$m] = $ss[0];
                $neg[$m] = $ss[1];
                $all[$m] = $ss[2];
                $hub_name[$m] = $hub[$k];
                foreach my $point (@cluster) {
                        $mark{$point} = 1;
                }
        }

        }
}


for (my $k = 0;$k<scalar @node ;$k++) {
        unless (exists $mark{$node[$k]}) { #一些独立的node ,分到最后还剩一个，无法合并~ 保证夫调控为0~~
                $m++;
                @{$final_cluster[$m]} = ($node[$k]);
                $score[$m]= "single";
                $all[$m] = "single";
                $neg[$m] = "single";
                $hub_name[$m] = "s";

        }
}

open OUT,">$file_log";
open OUT2,">$file_noa";
open OUT3,">$file_noa2";
for (my $k=1;$k<$m+1 ;$k++) {
    my @print_cluster = @{$final_cluster[$k]};

    my @sort_cluster = sort {$order{$a} <=> $order{$b}} @print_cluster;
        my $count = scalar @print_cluster;
    print OUT "Cluster_$k\t$hub_name[$k]\t$score[$k]\t$all[$k]\t$neg[$k]\t$count\t$name{$sort_cluster[0]}\t$name{$sort_cluster[-1]}\n";
    for (my $p=0;$p<scalar @print_cluster;$p++){
        print OUT2 "$name{$print_cluster[$p]} = Cluster_$k\n";
        print OUT3 "$gene_number{$print_cluster[$p]} = Cluster_$k\n";
        
    }
    #print OUT "\n";
#        print OUT "$k\t$score[$k]\t@{$final_cluster[$k]}\n";
}




sub score {
        my ($ref_cluster,$ref_name,$ref_interaction,$ref_neg) = @_;
        my @s = @{$ref_cluster};
        my %name = %{$ref_name};
        my %interaction = %{$ref_interaction};
        my %neg = %{$ref_neg};
        my $score;
        my $all=0;
        my $neg=0;
        for (my $k = 0;$k<scalar @s;$k++){
            for (my $kk = $k+1;$kk<scalar @s;$kk++){
                #print "sk== $s[$k] s_kk == $s[$kk]\n";
                my $interaction = $name{$s[$k]}."-".$name{$s[$kk]};
                #print "interaction == $interaction\n";
                if (exists $interaction{$interaction}){
                    $all++;

                }
                if (exists $neg{$interaction}){
                    $neg++;
                }
                #print "all=$all neg=$neg\n";
            }
        }
        if ($all == 0){ # 没有相互关系！
            $score = 2;
        }
        else {
            $score = $neg/$all;
        }
        my @ss = ($score,$neg,$all);
        return @ss;
        #return $score;

}
