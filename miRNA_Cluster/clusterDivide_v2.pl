#!/usr/bin/perl -w
use strict;

if (@ARGV < 2) {
	print "perl *.pl file_in cutoff \n";
	exit;
}

my ($file_in,$cutoff) = @ARGV;

open LOGNOW,">LOGNOW.LOG";
&clusterDivide($file_in,$cutoff);








#############################################################################################################################
sub clusterDivide {


# 对cluster看它的两个subcluster的各个sample的平均表达量 算rank correlation ，大于cutoff 不再细分
# 2006-10-17 23:31
# 

  my ($file,$cutoff)=@_;

my $file_eda = $file.".eda";
my $file_cdt = $file.".cdt";
print  "$file_cdt\n";
my $file_gtr = $file.".gtr";

my $file_noa = $file.".noa";
my $file_noa2=$file."geneid.noa";

my $file_log = "cluster_log.txt";

my $file_log_p = "cluster_log_p.txt";
open LOG_P,">$file_log_p";
#
#if (@ARGV < 5) {
#        print "perl file_eda(protein) file_cdt(symbol) file_gtr(tree) file_log file_noa \n";
#        exit;
#}
#my ($file_eda,$file_cdt,$file_atr,$file_out,$file_out2) = @ARGV;
#




# deal with cdt file ,just pick the genename--genesymbol relation
# GID	GID	NAME	GWEIGHT	HF7	HF7	HF7	HF7	HF18	HF18	HF18	HF23	HF23	HF18	HF23	HF23	HF28	HF28	HF47	B3	B3	HF18	HF42	HF28	HF7	HF23	HF28	HF28	HF42	HF42	HF47	HF42	HF42	HF47	HF42	HF47	HF47	HF47
# AID				ARRY2X	ARRY3X	ARRY4X	ARRY5X	ARRY9X	ARRY10X	ARRY7X	ARRY12X	ARRY14X	ARRY8X	ARRY13X	ARRY15X	ARRY17X	ARRY18X	ARRY28X	ARRY0X	ARRY1X	ARRY11X	ARRY23X	ARRY19X	ARRY6X	ARRY16X	ARRY21X	ARRY20X	ARRY26X	ARRY25X	ARRY31X	ARRY22X	ARRY27X	ARRY32X	ARRY24X	ARRY30X	ARRY29X	ARRY33X
# EWEIGHT				1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000	1.000000
# GENE218X	CG12708	CG12708	1.000000	0.008624	0.016827	0.019922	0.016717	-0.011727	-0.006227	0.020184	0.013617	-0.023875	0.025309	0.004285	-0.019323	-0.002788	-0.045763	-0.018039	-0.018421	-0.028839	0.051478	0.000574	0.047409	0.036763	0.005139	-0.019106	-0.016183	-0.041074	0.001707	-0.038959	0.048148	-0.035127	-0.000679	-0.026679	-0.027330	0.008056	0.017550

open CDT,"$file_cdt";

my %gene_name;
my %order;
my $order = 1; # 顺序
my %value;
my $seg_num;

while (<CDT>){
    chomp;
    if ($_=~/^GENE/){
        $order++;
        my @s =split /\t/,$_;
        $seg_num = scalar @s;
        $gene_name{$s[0]} = $s[1];
        $order{$s[0]} = $order;
		for (my $k=4;$k<$seg_num ;$k++) {
			${$value{$s[0]}}[$k]= $s[$k];
		}
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

# 子cluster
my %sub_node_a;
my %sub_node_b;



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

			$sub_node_a{$s[0]} = $s[1];
			$sub_node_b{$s[0]} = $s[2];

}

my @final_cluster;
my @cluster;
my $m = 0;
my %mark;
my @p_value;
my @hub_name;
for (my $k=scalar @hub-1;$k>=0 ;$k--) { # 从 大cluster开始分离
        @cluster = @{$array{$hub[$k]}};
        #print "$k -- @cluster\n";

        # 主要看sub clusters

		my $sub_node_a = $sub_node_a{$hub[$k]};
        my $sub_node_b = $sub_node_b{$hub[$k]};

        my @sub_cluster_a;
        my @sub_cluster_b;


        if ($sub_node_a =~/NODE/) {
            @sub_cluster_a = @{$array{$sub_node_a}};
        }
        else {
            @sub_cluster_a = ($sub_node_a);
        }
        if ($sub_node_b =~/NODE/) {
            @sub_cluster_b = @{$array{$sub_node_b}};
        }
        else {
            @sub_cluster_b = ($sub_node_b);
        }



        my $switch =1;
        foreach my $point (@cluster) { # 看是不是上一级cluster已经符合要求了？？
                if (exists $mark{$point}) {
                        $switch = 0;

                }
        }

        if ($switch == 1) {
        my $p_value =&score(\@sub_cluster_a,\@sub_cluster_b,\%value,$seg_num);# 两个sub cluster的node 

        print LOG_P "$hub[$k]\t$sub_node_a\t$sub_node_b\t$p_value\n";

#exit;
#print "cluster==@cluster\nscore==$score\n";
        if ($p_value > $cutoff || $p_value ==2) { # 
                $m++;
                @{$final_cluster[$m]} = @cluster;
                $p_value[$m] = $p_value;

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
                $p_value[$m]= "single";
                $hub_name[$m] = "s";

        }
}

open OUT,">$file_log";
open OUT2,">$file_noa";
open OUT3,">$file_noa2";
print OUT "cluster\tnode_name\tsub_nodes\tp_value\tgene_number\tstart_gene\tend_gene\n";
my %clusterid2geneids;
my %clusterid2count;
for (my $k=1;$k<$m+1 ;$k++) {
    my @print_cluster = @{$final_cluster[$k]};
    my @sort_cluster = sort {$order{$a} <=> $order{$b}} @print_cluster;
    my $count = scalar @print_cluster;
    print OUT "Cluster_$k\t$hub_name[$k]\t$sub_node_a{$hub_name[$k]} & $sub_node_b{$hub_name[$k]}\t$p_value[$k]\t$count\t$gene_name{$sort_cluster[0]}\t$gene_name{$sort_cluster[-1]}\n";
    for (my $p=0;$p<scalar @print_cluster;$p++){
		my $genename=$gene_name{$print_cluster[$p]};
#		my $geneid=$gene_name{$print_cluster[$p]}; ### 以后再说~~~
        print OUT2 "$genename = Cluster_$k\n";
#        print OUT3 "$geneid = Cluster_$k\n";
#		push @{$clusterid2geneids{$k}},$geneid;
    }
#	$clusterid2count{$k}=$count;
}

 close ATR;
 close CDT;
 print OUT "\n\n";
 close OUT;
 close OUT2;
 close OUT3;
# return(\%clusterid2geneids,\%clusterid2count);

}

sub score { # 计算 rank correlation 
        my ($ref_sub_cluster_a,$ref_sub_cluster_b,$ref_value,$seg_num) = @_;
        my @sub_cluster_a = @{$ref_sub_cluster_a};
        my @sub_cluster_b = @{$ref_sub_cluster_b};
		my %value = %{$ref_value};
        my $score;

        my $sample_num = $seg_num - 4;
        my %average_value_a;
        my %average_value_b;

        for (my $k = 4;$k<$seg_num ;$k++) {
            my $sum_value_a = 0;
            my $count_a = 0;
            my $sum_value_b = 0;
            my $count_b = 0;

            foreach my $key (@sub_cluster_a) {
                $sum_value_a = $sum_value_a + ${$value{$key}}[$k];
                $count_a++;
            }
            my $pos = $k-4;
            $average_value_a{$pos} = $sum_value_a/$count_a;

            foreach my $key (@sub_cluster_b) {
                $sum_value_b = $sum_value_b + ${$value{$key}}[$k];
                $count_b++;
            }
            $average_value_b{$pos} = $sum_value_b/$count_b;

            
        }

# 必须先排序 不能直接把平均值放进来
            my @sample_ID = keys %average_value_a;
            my @sort_sample_ID_a  = sort {$average_value_a{$b} <=> $average_value_a{$a} } @sample_ID;
            my @sort_sample_ID_b = sort {$average_value_b{$b} <=> $average_value_b{$a} } @sample_ID;
        
        
        
# 各个sample按照平均表达量大小排序
        my $r = &Spearman(\@sort_sample_ID_a,\@sort_sample_ID_b);
print LOGNOW "$r\n@sort_sample_ID_a\n@sort_sample_ID_b\n";
        return $r;
}


sub Spearman{
	my ($ref_array1,$ref_array2) = @_;
	my @array1 = @$ref_array1;
	my @array2 = @$ref_array2;
	my $sample_size = scalar @array1;
    my $sample_size2 = scalar @array2;
    print LOGNOW "$sample_size\t$sample_size2\n";
	my %rank1;
	my %rank2;

	for (my $k=0;$k<$sample_size ;$k++) {
		$rank1{$array1[$k]} = $k+1;
		$rank2{$array2[$k]} = $k+1;
	}

	my $sumSqr = 0;
	foreach my $expt_id (keys %rank1) {
		$sumSqr =$sumSqr+ ($rank1{$expt_id}-$rank2{$expt_id})*($rank1{$expt_id}-$rank2{$expt_id});
	}
    print LOGNOW "SUMSQR = $sumSqr\n";
	my $result = 1-( 6*$sumSqr / (( ($sample_size*$sample_size)-1) *$sample_size) );
	return $result;
}




#end divide the clusters
