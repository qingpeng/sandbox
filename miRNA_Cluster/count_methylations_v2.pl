if (@ARGV < 3) {
    print "perl *.pl pos_file graph_file file_out \n";
    exit;
}


my ($file_pos,$file_est,$file_out) = @ARGV;


open OUT,">$file_out";
# count methelations 
# 2007-6-14 14:05

my %query;
my %est_count;
open(QUERY, shift);
my $tmp = <QUERY>;

open QUERY,"$file_pos";
#aaahsa-mir-197 chr1    +       109942763       109942837
#bbbhsa-mir-197 chr1    +       109943313       109943387
#aaahsa-mir-554 chr1    +       149784600       149784695
#bbbhsa-mir-554 chr1    +       149785192       149785287
#aaahsa-mir-92b chr1    +       153431296       153431391


for(<QUERY>) {
        chomp $_;
        my @tmp = split("\t",$_);
        push(@{$query{$tmp[1]}}, {'name'=>$tmp[0],'start'=>$tmp[3],'end'=>$tmp[4],'strand'=>$tmp[2]});
        $est_count{$tmp[0]} = 0;
        $est_count_sum{$tmp[0]} = 0;
}



#chr1    4800    5199    1
#chr1    62800   63199   1
#chr1    70000   70399   1
#chr1    81200   81599   7
#chr1    122800  123199  1


open EST,"$file_est";
$tmp = <EST>;
for(<EST>) {
        chomp $_;
    my @s = split /\t/,$_;

                foreach my $target (@{$query{$s[0]}}) {
                       if ($target->{'start'} >=$s[1]  && $target->{'end'} <= $s[2] ) {
                            $est_count{$target->{'name'}} =$s[3];
                            $est_count_sum{$target->{'name'}} = $est_count_sum{$target->{'name'}} +$s[3];
                       }
                }

}



print OUT "$_\t$est_count{$_}\t$est_count_sum{$_}\n" for (keys(%est_count));
