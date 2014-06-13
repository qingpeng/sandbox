#!/usr/local/bin/perl

#Date:	   2003-04-23
#Author:   HongkunZheng
#Version:  2.0
#Modify:   2003-04-24 0:38 
#	   Change extend from 1000000 to 300000
#          Change every chromosome select 3 to 2
#          Add line cutoff 2000 match size cut 40
#Modify:   2003-04-24 2:00
#          Change the method to deal with overlap
## 注意query title必须是 \w，不能包含其他字符！！！！ 
# 			#>0610007F07 "0610007F07",1294,"","0.884793",92,748,""
# 见 line 275!!!! by zhangqp 2004-2-27 19:45
# refer line 42 2004-3-11 14:10


use strict;
use Getopt::Long;
use Data::Dumper;

my %opts;

GetOptions(\%opts,"i:s","q:s","o:s","help");


if(!defined($opts{i}) || !defined($opts{o}) || !defined($opts{q}) ||  defined($opts{help}) ){
	
	Usage();
	
}

my $start_time=time();
my $Time_Start = sub_format_datetime(localtime($start_time));
print "\nStart Time = $Time_Start\n\n";


my $blast=$opts{i};
my $output=$opts{o};
my $query_file=$opts{q};

###### initial variations ######
my $extend=1000; # modified extent length 2004-3-11 14:10
my $line_cut=2000;
my $best_cut=10;
my $block_cut=10;
my $sort_line_cut=1000;
my $cluster_num=5;
################################

my $i=0;
my $Qname='';
my $Cname='';
my $Cstart='';
my $temp_blast = (split(/\//,$blast))[-1];
my $tmp_out=$temp_blast.time().".zhenghk.mid.txt";


my @query=();
my @temp=();

my %select_block=();

open(IN,$blast)||die"can't open $blast\n";
open (TEMP,">$tmp_out")||die"can't create $tmp_out";
print "Write to temp file $tmp_out......\n";

while(my $line=<IN>){
	
	#chomp $line;
	
	if ($Qname ne '' && ($Qname ne (split(/\s+/,$line))[0] || $Cname ne (split(/\s+/,$line))[1]) ){
		
		
		ClusterBySeeds(\@query,\@temp);
		if (@temp>0){
			print TEMP ">$Qname\t$Cname\n";
			print TEMP @temp;
			print TEMP ":END\n";
		}
		
		@query=();
		@temp=();
		$i=0;
	}
	
	($Qname,$Cname,$Cstart)=(split(/\s+/,$line))[0,1,8];
	
	#push(@query,$line);
	if ($i>$line_cut){
		next;
	}
	$query[$i++]=$line;
	
}

ClusterBySeeds(\@query,\@temp);
		
if (@temp>0){
	print TEMP ">$Qname\t$Cname\n";
	print TEMP @temp;
	print TEMP ":END\n";
}

@query=();
@temp=();

close TEMP;

print "\nTemp file output complete!\n";
my $mid_time=time();
my $Time_Start = sub_format_datetime(localtime($mid_time)); #start time
my $total_time=sprintf("%02d",($mid_time-$start_time)/60);
print "Now = $Time_Start\n\n";
print "All Run Time $total_time\n";


my %query_len=();

ReadQueryLen($query_file,\%query_len);

#print Dumper(%query_len);


my @cluster=();
my $up_num='';
my $coverage='';
my $value='';
my %posi_hash=();
my $chr_posi='';
my $chr_posi_end='';
my $strand='';

open (TEMP,$tmp_out)||die"can't open $tmp_out\n";
while(<TEMP>){
	#print $_,"\n";
	if (/^\>/){
		chomp;
		my ($name)=$_=~s/^\>//;
	}
	elsif (/\:END/){
		#print "\n";
		#print @cluster;
		my ($Qname,$Cname,$posi,$posi_end)=(split(/\s+/,$cluster[0]))[1,2,9,10];
		$chr_posi=$posi-$extend;
		#### filter values smaller than 0 
		if ($chr_posi<0){
			$chr_posi=1;
		}
		$chr_posi_end=$posi+$extend;
		if ($posi>$posi_end){
			$strand='-';
		}
		else {
			$strand='+';
		}
		if (not exists $query_len{$Qname}) {
			print  "$Qname\n";
		}
		$coverage=Coverage(\@cluster,$query_len{$Qname});
		#$coverage=Coverage(\@cluster,"2000");
		$value=$Qname."\t".$Cname."\t".$strand."\t".$chr_posi."\t".$chr_posi_end."\t".$coverage."\n";
		push(@{$posi_hash{$Qname}},$value);
		@cluster=();
	}
	else {
		if ($up_num != (split(/\s+/,$_))[0] && @cluster > 0){
			#print "\n";
			#print @cluster;
			my ($Qname,$Cname,$posi,$posi_end)=(split(/\s+/,$cluster[0]))[1,2,9,10];
			$chr_posi=$posi-$extend;
			
			#### filter values smaller than 0 
			if ($chr_posi<0){
				$chr_posi=1;
			}
			
			$chr_posi_end=$posi+$extend;
			if ($posi>$posi_end){
				$strand='-';
			}
			else {
				$strand='+';
			}
			if (not exists $query_len{$Qname}) {
			print  "$Qname\n";
		}
			$coverage=Coverage(\@cluster,$query_len{$Qname});
			#$coverage=Coverage(\@cluster,"2000");
			$value=$Qname."\t".$Cname."\t".$strand."\t".$chr_posi."\t".$chr_posi_end."\t".$coverage."\n";
			push(@{$posi_hash{$Qname}},$value);
			
			@cluster=();
		
		}
		$up_num=(split(/\s+/,$_))[0];
		push(@cluster,$_);
	}
}
close TEMP;


#print Dumper(%posi_hash),"\n";
my $strand='';

open (O,">$output")||die"can't open output [$output]\n";
foreach (keys %posi_hash){
	#print $_,"\n";
	#print @{$posi_hash{$_}},"\n";
	my @sort_out=sort {(split(/\s+/,$b))[5]<=>(split(/\s+/,$a))[5]} (@{$posi_hash{$_}});
	for($i=0;$i<$best_cut;$i++){
		print O $sort_out[$i];
	}
}
close O;

BackDo($tmp_out);

my $done_time=time();
my $Time_Start = sub_format_datetime(localtime($done_time)); #start time
print "Done Time = $Time_Start\n\n";



sub ClusterBySeeds() {
	
	my ($r_query,$r_select)=@_;
	
	my $clock=0;
	my $i=0;
	my $j=0;
	
	my %count=();
	
	my @sort_Q_block=sort {(split(/\s+/,$b))[3] <=> (split(/\s+/,$a))[3]} (@{$r_query});
	
	for($i=0;$clock<$cluster_num;$i++){
		
		#print $sort_Q_block[$i],"\n";
		if (exists $count{$sort_Q_block[$i]}){
			next;
		}
		else {
			$clock++;
			my $seed_posi=(split(/\s+/,$sort_Q_block[$i]))[8];
			
			my $start=$seed_posi-$extend;
			my $stop=$seed_posi+$extend;
			
			for($j=$i;$j<@sort_Q_block;$j++){
				my ($len,$posi)=(split(/\s+/,$sort_Q_block[$j]))[3,8];
				
				if ($len<$block_cut || $i > $sort_line_cut){
					last;
				}
				
				if ( $posi>$start  && $posi<$stop ){
					
					my $add_num=$clock."\t".$sort_Q_block[$j];
					push(@{$r_select},$add_num);
					$count{$sort_Q_block[$j]}=1;
					
				}
			}
		}
		
	}
	
}

sub ReadQueryLen() {
	my ($query_file,$r_hash)=@_;
	
	open(IN,$query_file)||die"can't open query file [$query_file]\n";
	while(my $line=<IN>){
		if ($line=~/^\>/){
			#>0610007F07 "0610007F07",1294,"","0.884793",92,748,""
			my ($name,$len)=$line=~/^>(\w+)\s+\"\w+\"\,(\d+)\,/;
			$$r_hash{$name}=$len;
		}
	}
	close IN;
}


sub Coverage() {
	my ($r_array,$Qlen)=@_;
	
	#print $Qlen,"\n";
	#$Qlen=2000;
	my $i=0;
	my $rougth_len=0;
	
	my %hash=();
	my %assemble=();
	
	foreach (@{$r_array}){
		my ($start,$end)=(split(/\s+/,$_))[7,8];
		$hash{$start}=$end;
	}
	AssembleFragment(\%hash,\%assemble);
	
	foreach (keys %assemble){
		$rougth_len+=($assemble{$_}-$_+1);
	}
	
	#print "$rougth_len\n";
	
	my $coverage=sprintf("%.4f",($rougth_len/$Qlen*100));
	#print $coverage,"\n";
	return $coverage;
}

sub AssembleFragment {
	my ($r_hash,$r_return)=@_;
	
	my @key=sort {$a<=>$b} keys %$r_hash;
	#print @key;
	for(my $j=0;$j<@key;$j++){
		for (my $i=$j+1;$i<@key;$i++){
			if ($$r_hash{$key[$j]}>=($key[$i])){	#modify add '=';
				if ($$r_hash{$key[$i]}>$$r_hash{$key[$j]}){
					$$r_hash{$key[$j]}=$$r_hash{$key[$i]};
					$$r_hash{$key[$i]}=0;
				}
				else {
					$$r_hash{$key[$i]}=0;
				}
			}
		}
	}
	foreach (keys %$r_hash){
		if ($$r_hash{$_} ne 0){
			$$r_return{$_}=$$r_hash{$_};
		}
	}
}

sub BackDo() {
	my ($in)=@_;
	
	system("rm $in");
	
}

sub sub_format_datetime #datetime subprogram
{
    my($sec , $min , $hour , $day , $mon , $year , $wday , $yday , $isdst) = @_;

    sprintf("%4d-%02d-%02d %02d:%02d:%02d" , ($year + 1900) , $mon , $day , $hour , $min , $sec);
};

sub Usage #help subprogram
{
    print << "    Usage";

	Description :
	
		Cluster the blast result to map cDNA to Genome rougthly!

	Usage: $0 <options>

		-i             Path/input_file , must be given (String)

		-q	       Query file contain the query length , must be given (String)
		
		-o             Cutoff output , must be given (String)
		
		-help          Show help , have a choice

    Usage

	exit(0);
};		
