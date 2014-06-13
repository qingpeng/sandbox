#!/usr/local/bin/perl -w
# 
# Copyright (c) BGI 2003
# Author:         Liudy <liudy@genomics.org.cn>
# Program Date:   2003.09.25
# Modifier:       Liudy <liudy@genomics.org.cn>
# Last Modified:  2003.09.30
# 

use strict;
use Getopt::Long;
use Data::Dumper;
#########################################################################################
my %opts;

GetOptions(\%opts,"i=s","o=s","l=s","h","d","g=s" );

if(!defined($opts{i}) || !defined($opts{l}) || !defined($opts{o}) || defined($opts{h})){
	print <<"	Usage End.";
	Description:

		Creating scaffolds from a group list, and then output an endlove file.
		
		Input format:
		>group1
		contig1 contig2	U C n(正确的正反向个数) min_gap_size max_gap_size
		...
		
		Output format:
		Scaffold000001
			1	Contig065987. U	2035
		...

	Usage:

		-i    group file          must be given.

		-l    contig length list  must be given.

		-o    outfile endlove     must be given.

		-d    debug statement.

		-g    group name          debug by group.

		-h    this help document.

	Usage End.

	exit;
}
###############是否处于debug状态
my $Debug=0;
my $Debug_all=0;
if (defined $opts{d}) {
#	$|=1;
	$Debug=1;
	$Debug_all=1;
}
###############Time
my $in=$opts{i};
my $list=$opts{l};
my $out=$opts{o};
my $Time_Start;
$Time_Start = sub_format_datetime(localtime(time()));
print "\nStart Time :[$Time_Start]\n\n";

################Define main variables here:
my $ctg_name='';
my $ctg_length=0;
my $count=0;
################传递的变量
my %length=();
my %pos=();
my %limit=();
my %child=();
my @name=();
my $insert='';
my $pos_insert='';
################读入
open (LIST,"$list")||die"cannot open $list !\n";
while (<LIST>) {
	chomp;
	$ctg_name=(split(/\t/,$_))[0];
	$ctg_length=(split(/\t/,$_))[1];
	$ctg_name=~s/\.//;
	$length{"$ctg_name.U"}=$ctg_length;
	$length{"$ctg_name.C"}=$ctg_length;
}
close LIST;

################
open (IN,"$in")||die"Can't open $in\n";
open (OUT,">$out");
$/=">";
print "\n     0 scaffolds created.";

while (<IN>) {
	chomp;
	$Debug=$Debug_all;
	%pos=();
	%limit=();
	%child=();
	@name=();
	$insert='';
	$pos_insert='';

	my @group_pair_info=();
	my %hash_group_ctg_name=();
	my %hash_ctg_pair=();
	my %hash_pair_size=();
	my $x='';
	my $i=0;
	if ($_ ne "") {
		@group_pair_info=split(/\n/,(split(/\n/,$_,2))[1]);

		if (defined $opts{g}) {
			my $group_debug=$opts{g};
			my $group_name=(split(/\n/,$_,2))[0];
			if ($group_name=~/$group_debug$/) {
				print "\nDebug $group_debug\n\n";
				$Debug=1;
			}
		}
	}


	foreach $x (@group_pair_info) {
		my $ctg_pair=(split(/\t/,$x))[0];
		my $ctg_info=(split(/\t/,$x))[1];
		my $ctg1=(split(/\s+/,$x))[0];
		my $ctg2=(split(/\s+/,$x))[1];
		my @info=split(/\s+/,$ctg_info);

		my $pair_name="$ctg1.$info[0] $ctg2.$info[1]";
		my $rev_pair_name=&reverse_pair($pair_name);

		#生成contig对和组内contig的列表
		@{$hash_ctg_pair{$pair_name}}=($info[2],$info[3],$info[4]);
		@{$hash_ctg_pair{$rev_pair_name}}=($info[2],$info[3],$info[4]);#同时生成两种方向的pair，便于后面查找
		$hash_pair_size{$pair_name}=$length{"$ctg1.$info[0]"}+$length{"$ctg2.$info[1]"};
		$hash_pair_size{$rev_pair_name}=$length{"$ctg1.$info[0]"}+$length{"$ctg2.$info[1]"};

		my $ctg1a=(split(/\s+/,$pair_name))[0];
		my $ctg2a=(split(/\s+/,$pair_name))[1];
		my $ctg1b=(split(/\s+/,$rev_pair_name))[0];
		my $ctg2b=(split(/\s+/,$rev_pair_name))[1];

		$hash_group_ctg_name{$ctg1a}=0;
		$hash_group_ctg_name{$ctg2a}=0;
		$hash_group_ctg_name{$ctg1b}=0;
		$hash_group_ctg_name{$ctg2b}=0;

		$limit{$ctg1a."-".$ctg2a}=$info[3]."_".$info[4];#给出limit范围
		if (!exists $child{$ctg1a}) {
			$child{$ctg1a}=$ctg2a;
		}
		else {
			$child{$ctg1a}.="\t$ctg2a";
		}
		if (!exists $child{$ctg2a}) {
			$child{$ctg2a}=$ctg1a;
		}
		else {
			$child{$ctg2a}.="\t$ctg1a";
		}#构建child
		$limit{$ctg1b."-".$ctg2b}=$info[3]."_".$info[4];#给出limit范围
		if (!exists $child{$ctg1b}) {
			$child{$ctg1b}=$ctg2b;
		}
		else {
			$child{$ctg1b}.="\t$ctg2b";
		}
		if (!exists $child{$ctg2b}) {
			$child{$ctg2b}=$ctg1b;
		}
		else {
			$child{$ctg2b}.="\t$ctg1b";
		}#构建child
	}#得到循环前所需的信息
	print "limit:\n" if($Debug==1);
	print Dumper %limit if($Debug==1);
	

	#开始循环，先调一对种子组成链，然后选择与该链关系最强的加入，每次一个
	while (keys %hash_ctg_pair > 0) {
		my $best_pair='';
		my @scaffold_info=();
		my %hash_scaffold=();
		my $ctg1='';
		my $ctg2='';
		my $axis=1;

		$best_pair=(sort{$hash_ctg_pair{$b}[0]<=>$hash_ctg_pair{$a}[0] || $hash_pair_size{$b}<=>$hash_pair_size{$a}} keys %hash_ctg_pair)[0];

		if ($hash_ctg_pair{$best_pair}[0]>=2) {

			my $rev_best_pair=&reverse_pair($best_pair);
			$ctg1=(split(/\s+/,$best_pair))[0];
			$ctg2=(split(/\s+/,$best_pair))[1];

			push (@scaffold_info,$ctg1);
			$hash_scaffold{$ctg1}=$axis;
			$axis=$length{$ctg1}+int(($hash_ctg_pair{$best_pair}[2]-$hash_ctg_pair{$best_pair}[1])/2+1);
			push (@scaffold_info,$ctg2);
			$hash_scaffold{$ctg2}=$axis;

			delete $hash_ctg_pair{$best_pair};
			delete $hash_ctg_pair{$rev_best_pair};
			$ctg1=(split(/\./,$ctg1))[0];
			delete $hash_group_ctg_name{"$ctg1.U"};
			delete $hash_group_ctg_name{"$ctg1.C"};
			$ctg2=(split(/\./,$ctg2))[0];
			delete $hash_group_ctg_name{"$ctg2.U"};
			delete $hash_group_ctg_name{"$ctg2.C"};

			print "\nAT FIRST-------------------------------------------------------------\n" if($Debug==1);
			print "hash_group_ctg_name:\n" if($Debug==1);
			print Dumper %hash_group_ctg_name if($Debug==1);
			print "scaffold_info:\n" if($Debug==1);
			print Dumper @scaffold_info if($Debug==1);
			print "child:\n" if($Debug==1);
			print Dumper %child if($Debug==1);

			#以下应该建立group内剩余的contigs的插入位置列表
			my %hash_insert=();
			my %hash_insert_pair=();
			foreach $x (keys %hash_scaffold) {
				my @array_ins=split(/\t/,$child{$x});
				my $x_1='';
				foreach $x_1 (@array_ins) {
					if (!exists $hash_scaffold{$x_1} && exists $hash_ctg_pair{"$x_1 $x"}) {
						$hash_insert_pair{"$x_1 $x"}=$x_1;
						$hash_insert{$x_1}=0;
					}
					elsif (!exists $hash_scaffold{$x_1} && exists $hash_ctg_pair{"$x $x_1"}) {
						$hash_insert_pair{"$x $x_1"}=$x_1;
						$hash_insert{$x_1}=0;
					}
				}
			}#根据%child得到准备插入的初始contig集
			print "\ngenerate data to judge---------------------------------------\n" if($Debug==1);
			print "hash_scaffold:\n" if($Debug==1);
			print Dumper %hash_scaffold if($Debug==1);
			print "hash_insert_pair:\n" if($Debug==1);
			print Dumper %hash_insert_pair if($Debug==1);
			print "hash_insert:\n" if($Debug==1);
			print Dumper %hash_insert if($Debug==1);
			print "generate data to judge finish--------------------------------\n\n" if($Debug==1);

			#以下将判断插入contig 选最好的一个contig
			my $key=1;
			my %gap_length=();
			while (keys %hash_insert > 0 && keys %hash_group_ctg_name > 0) {
				my $x_1='';
				if ($key==1) {
					foreach $x_1 (keys %hash_insert_pair) {
						$hash_insert{$hash_insert_pair{$x_1}}+=$hash_ctg_pair{$x_1}[0];
					}

					my $end_position=@scaffold_info;
					for ($i=1;$i<@scaffold_info ;$i++) {
						$gap_length{$i}=$hash_scaffold{$scaffold_info[$i]}-$hash_scaffold{$scaffold_info[$i-1]}-$length{$scaffold_info[$i-1]};
					}
					$gap_length{0}=100000000;
					$gap_length{$end_position}=100000000;#记录gap的宽度

				}#如果key==1(hash_scaffold有变化)则重新建立hash_insert
				$key=0;

				my $best_insert=(sort{$hash_insert{$b}<=>$hash_insert{$a} || $length{$b}<=>$length{$a}} keys %hash_insert)[0];#选择最好的contig

				if ($hash_insert{$best_insert}>=2) {

					print "AAAAAAAAAAAt first best insert:  $best_insert    $hash_insert{$best_insert}\n" if($Debug==1);
					print "hash_insert_pair:\n" if($Debug==1);
					print Dumper %hash_insert_pair if($Debug==1);
					print "hash_insert:\n" if($Debug==1);
					print Dumper %hash_insert if($Debug==1);
					print "hash_group_ctg_name\n" if($Debug==1);
					print Dumper %hash_group_ctg_name if($Debug==1);
					#选择最好的位置准备插入
					my %insert_pos=();
					foreach $x_1 (keys %hash_insert_pair) {
						if ($x_1=~/$best_insert/) {
							print "best insert pair:  $x_1\n" if($Debug==1);
							print "best insert:  $best_insert\n" if($Debug==1);
							my $min=0;
							my $max=0;
							my $x_1_temp=$x_1;
							$x_1_temp=~s/\s/-/;
							my @limit_info=split(/\_/,$limit{$x_1_temp});
							print "LLLLLLLLLLLimit range : @limit_info  |   $x_1_temp   |   $limit{$x_1_temp}\n" if($Debug==1);
							if ($x_1=~/$best_insert$/) {#向右
								my $parent=(split(/\s/,$x_1))[0];
								print "Parent    $parent\n" if($Debug==1);
								$min=$hash_scaffold{$parent}+$length{$parent}+$limit_info[0]-1;
								$max=$hash_scaffold{$parent}+$length{$parent}+$limit_info[1]+$length{$best_insert}-1;
								for ($i=1;$i<@scaffold_info ;$i++) {
									if (($hash_scaffold{$scaffold_info[$i]} > $min && $hash_scaffold{$scaffold_info[$i-1]}+$length{$scaffold_info[$i-1]} < $max)) {
										$insert_pos{$i}+=$hash_ctg_pair{$x_1}[0] if(exists $insert_pos{$i});
										$insert_pos{$i}=$hash_ctg_pair{$x_1}[0] if(!exists $insert_pos{$i});
									}
								}
								if ($max > $hash_scaffold{$scaffold_info[-1]}+$length{$scaffold_info[-1]}) {
									my $end_position=@scaffold_info;
									$insert_pos{$end_position}+=$hash_ctg_pair{$x_1}[0] if(exists $insert_pos{$end_position});
									$insert_pos{$end_position}=$hash_ctg_pair{$x_1}[0] if(!exists $insert_pos{$end_position});
								}
								print "Right insert\n" if($Debug==1);
							}
							if ($x_1=~/^$best_insert/) {#向左
								my $parent=(split(/\s/,$x_1))[1];
								$min=$hash_scaffold{$parent}-$length{$best_insert}-$limit_info[1]+1;
								$max=$hash_scaffold{$parent}-$limit_info[0]+1;
								for ($i=1;$i<@scaffold_info ;$i++) {
									if (($hash_scaffold{$scaffold_info[$i]} > $min && $hash_scaffold{$scaffold_info[$i-1]}+$length{$scaffold_info[$i-1]} < $max)) {
										$insert_pos{$i}+=$hash_ctg_pair{$x_1}[0] if(exists $insert_pos{$i});
										$insert_pos{$i}=$hash_ctg_pair{$x_1}[0] if(!exists $insert_pos{$i});
									}
								}
								if ($min < $hash_scaffold{$scaffold_info[0]}) {
									$insert_pos{0}+=$hash_ctg_pair{$x_1}[0] if(exists $insert_pos{0});
									$insert_pos{0}=$hash_ctg_pair{$x_1}[0] if(!exists $insert_pos{0});
								}
								print "Left insert\n" if($Debug==1);
							}
						}
					}#得到插入位置的hash   %insert_pos

					#取一个最好的插入位置并看能否插入
					my @insert_pos_row=sort{$insert_pos{$b}<=>$insert_pos{$a} || $gap_length{$b}<=>$gap_length{$a}} keys %insert_pos;
					print "insert_pos\n" if($Debug==1);
					print Dumper %insert_pos if($Debug==1);
					print "insert_pos_row     @insert_pos_row\n" if($Debug==1);
					while (@insert_pos_row>0) {
						$pos_insert=shift(@insert_pos_row);
						$insert=$best_insert;
						%pos=%hash_scaffold;
						@name=@scaffold_info;

						print "\nInsert-------------------------------------------------------:\n" if($Debug==1);
						print "INSERT:  $insert    $pos_insert    pairnum: $insert_pos{$pos_insert}\n" if($Debug==1);
						print "Scaffold:\n" if($Debug==1);
						print Dumper @name if($Debug==1);
						print "pos:\n" if($Debug==1);
						print Dumper %pos if($Debug==1);

						&MOVE();

						print "pos after insert:\n" if($Debug==1);
						print Dumper %pos if($Debug==1);
						print "\nInsert complete-------------------------------------------------------:\n\n" if($Debug==1);

						if (keys %pos > keys %hash_scaffold) {
							%hash_scaffold=%pos;
							for ($i=@scaffold_info;$i>$pos_insert ;$i--) {
								$scaffold_info[$i]=$scaffold_info[$i-1];
							}
							$scaffold_info[$pos_insert]=$best_insert;
							@insert_pos_row=();
							$key=1;
							my $in_ctg_name=(split(/\./,$best_insert))[0];
						}
					}#插入

					if ($key==1) {
						print "###########inserted  renew  hash_insert    hash_insert_pair###########\n" if($Debug==1);
						%hash_insert=();
						%hash_insert_pair=();#清空重新生成
						foreach $x_1 (keys %hash_scaffold) {
							my @array_ins=split(/\t/,$child{$x_1});
							print "origin : $x_1     insert contigs : @array_ins\n" if($Debug==1);
							my $x_2='';
							foreach $x_2 (@array_ins) {
								my $x_2_temp=(split(/\./,$x_2))[0];
								if (!exists $hash_scaffold{"$x_2_temp.U"} && !exists $hash_scaffold{"$x_2_temp.C"} && exists $hash_ctg_pair{"$x_2 $x_1"}) {
									$hash_insert_pair{"$x_2 $x_1"}=$x_2;
									$hash_insert{$x_2}=0;
		#							print "$x_2 $x_1    xxxxx\n" if($Debug==1);
								}
								if (!exists $hash_scaffold{"$x_2_temp.U"} && !exists $hash_scaffold{"$x_2_temp.C"} && exists $hash_ctg_pair{"$x_1 $x_2"}) {
									$hash_insert_pair{"$x_1 $x_2"}=$x_2;
									$hash_insert{$x_2}=0;
		#							print "$x_1 $x_2    yyyyy\n" if($Debug==1);
								}#修正矛盾contig引起的重复调用
							}
						}#根据%child得到准备插入的下一个contig集
#						my $insert_temp=(split(/\./,$insert))[0];
#						delete $hash_group_ctg_name{"$insert_temp.U"};
#						delete $hash_group_ctg_name{"$insert_temp.C"};
					}
					else{
						print "!!!!!!!!!!!!!!!Didn't insert,delete insert contig relation!!!!!!!!!!!!\n" if($Debug==1);
						delete $hash_insert{$best_insert};
					}#更新主链
				}
				else {
					%hash_insert=();
				}#最好的插入contig与组内关系小于2则退出循环，对于这个scaffold的插入结束

				print "hash_insert:\n" if($Debug==1);
				print Dumper %hash_insert if($Debug==1);
				print "hash_insert_pair:\n" if($Debug==1);
				print Dumper %hash_insert_pair if($Debug==1);
			}

			#没有合适的关系的时候输出一个scaffold并更新%hash_scaffold
			$count++;
			my $sca_length=0;
			foreach $x (keys %hash_scaffold) {
				$sca_length+=$length{$x};
			}
			printf OUT ("Scaffold%06d\t$sca_length\n",$count);
			print "Complete scaffold,next............................\n\n" if($Debug==1);
#			foreach $x (sort {$hash_scaffold{$a}<=>$hash_scaffold{$b}} keys %hash_scaffold) {
#				my @output=();
#				@output=split(/\./,$x);
#				print OUT "\t",$hash_scaffold{$x},"\t",$output[0],". ",$output[1],"\t",$length{$x},"\n";
#
#				$x=(split(/\./,$x))[0];
#				delete $hash_group_ctg_name{"$x.U"};
#				delete $hash_group_ctg_name{"$x.C"};
#			}
			foreach $x (@scaffold_info) {
				my @x_temp=split(/\./,$x);
				print OUT "\t$hash_scaffold{$x}\t$x_temp[0]. $x_temp[1]\t$length{$x}\n";

				delete $hash_group_ctg_name{"$x_temp[0].U"};
				delete $hash_group_ctg_name{"$x_temp[0].C"};
			}
			print "HASH_group_ctg_name juset after delete\n" if($Debug==1);
			print Dumper %hash_group_ctg_name if($Debug==1);
			#更新%hash_ctg_pair
			foreach $x (keys %hash_ctg_pair) {
				$ctg1=(split(/\s/,$x))[0];
				$ctg2=(split(/\s/,$x))[1];
				if (!exists $hash_group_ctg_name{$ctg1} || !exists $hash_group_ctg_name{$ctg2}) {
					my $rev_x=&reverse_pair($x);
					delete $hash_ctg_pair{$x};
					delete $hash_ctg_pair{$rev_x};
				}
			}
			printf ("\r%6d scaffolds created.",$count);
		}
		else{
			%hash_ctg_pair=();
		}#如果找不到合适的种子（关系大于2）就退出循环，不进行连接
	}

#	#输出单个的contig为scaffold
#	foreach $x (keys %hash_group_ctg_name) {
#		my @output=split(/\./,$x);
#		if ($output[1] eq "U") {
#			$count++;
#			printf OUT ("Scaffold%06d\t$length{$x}\n",$count);
#			print OUT "\t1\t",$output[0],". U\t",$length{$x},"\n";
#			printf ("\r%6d scaffolds created.",$count);
#		}
#	}
}
printf ("\r%6d scaffolds created.\n",$count);
print "Finished!\n";
close IN;
close OUT;

###############Time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";



###############Subs
sub sub_format_datetime {#Time calculation subroutine
    my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $day, $hour, $min, $sec);
}


sub reverse_pair(){
	my ($pair)=@_;
	my @pair_info=split(/[\.\s]/,$pair);
	$pair_info[1]=~tr/UC/CU/;
	$pair_info[3]=~tr/UC/CU/;
	$pair="$pair_info[2].$pair_info[3] $pair_info[0].$pair_info[1]";
	return $pair;
}


sub MOVE()#author: xujzh   data:2003-09-30
{
	my($used,$a,$b,$c,$d,$e,$in,$gap,$change,$final,@max,@site,$block,$min_pos,$min_distance,$end_pos,$free,$debug_key);
	my %relation=();
	my $contig=$insert;
	my $position=$pos_insert;
	my @try_sca=@name;
	my $long=@try_sca;
	my $judge=1;
	my $judge_end=0;
	my $judge_free=2;			#判断是否在关系外部有限制，该关系是否还能延长
	foreach $debug_key(keys(%pos))
	{
		if($pos{$debug_key} <0)
		{
			print"$debug_key\t\$pos{\$debug_key}=$pos{$debug_key}\n";
			die"pos error!";
		}
	}
	if($position==$long)			#如果加入尾部
	{
		$judge=0;
		$try_sca[$long++]=$contig;
		for($a=0;$a<$position;$a++)
		{
			if(($used=$limit{"$try_sca[$a]\-$contig"}) or($used=$limit{"$contig\-$try_sca[$a]"}))	#寻找所有跨过插入点的关系
			{
				@max=split/\_/,$used;
#				$relation{"$a\-$position"}=$max[1];
				$block=$max[1];
				if($position-$a>1)
				{
					for($b=$a;$b<$position;$b++)
					{
						$block-=$length{$try_sca[$b]};
					}
				}
				if ($block>=0)
				{
					$end_pos="$a\-$position" ;
					$judge_end=1;
				}
			}
		}
	}
	elsif($position==0)			#如果加入头部
	{
		$judge=0;
		unshift @try_sca,$contig;
		$long++;
		for($a=$long-1;$a>0;$a--)
		{
			if(($used=$limit{"$try_sca[$a]\-$contig"}) or($used=$limit{"$contig\-$try_sca[$a]"}))	#寻找所有跨过插入点的关系
			{
				@max=split/\_/,$used;
#				$relation{"0\-$a"}=$max[1];
				$block=$max[1];
				if($a>1)
				{
					for($b=1;$b<$a;$b++)
					{
						$block-=$length{$try_sca[$b]};
					}
				}
				if ($block>=0)
				{
					$end_pos="0\-$a";
					$judge_end=1;
				}	
			}
		}
	}
	else					#如果加入点不是头尾
	{
		for($a=0;$a<$position;$a++)	#寻找所有跨过插入点的关系
		{
			for($b=$position;$b<@try_sca;$b++)
			{
				if(($used=$limit{"$try_sca[$a]\-$try_sca[$b]"})or($used=$limit{"try_sca[$b]\-$try_sca[$a]"}))
				{
					@max=split/\_/,$used;
					$relation{"$a\-$b"}=$max[1];
				}
			}
		}
	}

	if($Debug==1)
	{
		print"Debug\n";
		print"Not\n\%relation" if (!%relation);
		foreach $debug_key(keys(%relation))
		{
			print"$debug_key\t$relation{$debug_key}\n";
		}
		print"$end_pos\t$max[1]\n" if ($end_pos);
	}

	if(($position!=0)and($judge)and(%relation))	#对于非加入头尾的contig计算能否插入（寻找最小插入距离）
	{
		
		$min_distance=$max[1];
		foreach (keys(%relation))		
		{
			@site=split/\-/,$_;
			$block=$relation{$_};
			if(($site[1]-$site[0])>1)
			{
				for($a=$site[0]+1;$a<$site[1];$a++)
				{
					$block-=$length{$try_sca[$a]};
				}
			}
			if(($site[0]>0) and ($site[1]<($long-1)))
			{
				$a=$site[0]-1;
				$b=$site[1]+1;
				$c=$pos{$try_sca[$b]}-$pos{$try_sca[$a]}-$length{$try_sca[$a]};
				for($d=$site[0];$d<($site[1]+1);$d++)
				{
					$c-=$length{$try_sca[$d]};
				}
			}
			
			print"$block\n" if ($Debug);
			if(defined($c))
			{
				$block=$c if ($c<$block);
			}
			
			if($block-$length{$contig}<0)
			{
				$judge=0;
				last;
			}
			elsif($block<=$min_distance)	#获得最小距离和最小位置
			{
				$min_pos=$_;
				$min_distance=$block;
			}
			
		}
	}
	if($Debug==1)
	{
		print"$judge\n";
		print"$min_pos\n" if ($min_pos);
		print"$block\n";
	}

		
	if($judge_end)				#如果加入点是头或者尾并且可以移动，从新将所有contig定位
	{
		@site=split/\-/,$end_pos;
		$a=$try_sca[$site[0]];
		$b=$try_sca[$site[1]];
		@max=split/\_/,$used if($used=$limit{"$a\-$b"})or($used=$limit{"$b\-$a"});
		$gap=int(($max[1]+$max[0])/2);
		
		if(($site[1]-$site[0])==1) 	#如果最近的一对关系就是与挨着的contig的
		{
			if($position==($long-1))
			{
				$pos{$b}=$pos{$a}+$length{$a}+$gap;
			}
			else
			{
				$pos{$a}=1;
				for($c=1;$c<$long;$c++)
				{
					$b=$try_sca[$c];
					$pos{$b}+=$length{$a}+$gap+1;
				}
			}
		}
		else
		{
			if($position==0)		#在头部加入
			{
				$pos{$a}=1;
				if($gap>$pos{$b})
				{
					$change=$length{$a}+$gap-$pos{$b};
					$d=1;
				}
				elsif($max[1]>=$pos{$b})
				{
					$change=$length{$a};
					$d=1;
				}
				else
				{
					$c=1;
					$d=$pos{$try_sca[$c]}+$length{$try_sca[$c]};
					$pos{$try_sca[$c]}=$length{$a}+1;
					while(($pos{$try_sca[$c+1]}-$d)<($pos{$b}-$max[1]))
					{
						$d+=$length{$try_sca[$c+1]};
						$c++;
						$pos{$try_sca[$c]}=$pos{$try_sca[$c-1]}+$length{$try_sca[$c-1]}+1;
						last if($c==($long-1));
					}
					$change=$length{$a}+$max[1]-$pos{$b};
					$d=$c+1;
				}
				for($c=$d;$c<$long;$c++)
				{
					$b=$try_sca[$c];
					$pos{$b}+=$change;
				}
			}
			else				#在尾部加入
			{
				if(($gap+$pos{$a}+$length{$a})>($pos{$try_sca[$position-1]}+$length{$try_sca[$position-1]}))
				{
					$pos{$b}=$gap+$pos{$a}+$length{$a};
				}
				elsif(($max[1]+$pos{$a}+$length{$a})>=($pos{$try_sca[$position-1]}+$length{$try_sca[$position-1]}))
				{
					$pos{$b}=$pos{$try_sca[$position-1]}+$length{$try_sca[$position-1]};
				}
				else
				{
					$pos{$b}=($max[1]+$pos{$a}+$length{$a});
					$e=$pos{$try_sca[$position-1]}+$length{$try_sca[$position-1]}-($max[1]+$pos{$a}+$length{$a});
					$c=$position-1;
					$d=$pos{$try_sca[$c]}-$length{$try_sca[$c-1]};
					$pos{$try_sca[$c]}=$pos{$b}-$length{$try_sca[$c]};
					while($d-$pos{$try_sca[$c-1]}<$e)
					{
						$c--;						#注意，先c自减
						$pos{$try_sca[$c]}=$pos{$try_sca[$c+1]}-$length{$try_sca[$c]};
						last if($c==0);
						$d-=$length{$try_sca[$c-1]};
					}
				}
			}
		}
	}
	
	
	if(($judge)and(%relation))			#如果插入点非头非尾，并且可以插入
	{
		$c=0;
		$in=0;
		@site=split/\-/,$min_pos;
		my $con1=$try_sca[$site[0]];
		my $con2=$try_sca[$site[1]];
		@max=split/\_/,$used if (($used=$limit{"$con1\-$con2"})or($used=$limit{"$con2\-$con1"}));
		$a=$position-1;
		for($b=$position;$b<=$site[1];$b++)	#向后推
		{
			print"\$length{$try_sca[$b-1]}=$length{$try_sca[$b-1]}\t$c\n" if $Debug;
			$c+=$length{$try_sca[$b-1]};
			if(($pos{$try_sca[$b]}-$pos{$try_sca[$a]}-$c)>=$length{$contig})
			{
				$change=$pos{$try_sca[$b]}-$pos{$try_sca[$a]}-$c-$length{$contig};
				$d=$b;
				$in=1;
				last;
			}
		}
		
		if(!$in)		#需要推动$site[1]位置的箱子了
		{
			$b=$site[1];
			$e=$site[0];
			print"111\t$pos{$try_sca[$b]}\t$pos{$try_sca[$a]}\t$c\t$site[0]\t$site[1]\n"if $Debug;
			$block=$pos{$try_sca[$b]}-$pos{$try_sca[$a]}-$c;
			print"222\t$max[1]\t$pos{$try_sca[$e]}\t$length{$try_sca[$e]}\n" if $Debug;
			$free=$max[1]-($pos{$try_sca[$b]}-$pos{$try_sca[$e]}-$length{$try_sca[$e]});
			print "333\t$length{$contig}\t$free\t$block\n" if $Debug;
			if((($block+$free)>=$length{$contig})and($free>0))
			{
				if($site[1]==($long-1))
				{
					$in=1;
					$d=$b+1;		#注意，$d=$long了
				}
				elsif(($pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]})>=$free)
				{
					$in=1;
					$d=$b+1;
				}
				elsif(($pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]}+$block)>=$length{$contig})
				{
					$in=1;
					$d=$b+1;
					print"???\n" if $Debug;
				}
			}

			
			if(!$in)				#开始向前推
			{
				if($free<=0)
				{
					$judge_free=0;
				}
				else
				{
					if($b==$long-1)
					{
						$block+=$free;
						$judge_free=0;
					}
					else
					{
						if(($pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]})>=$free)
						{
							$block+=$free;
							$judge_free=0;
						}
						else
						{
							$block+=$pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]};
							$free-=$pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]};
							$judge_free=1;
						}
					}
				}
				if(($a>0)and(($a-1)>=$site[0]))
				{
					$c=$pos{$try_sca[$a]};
					print"\$c=$c\t\$a=$a\t\$length{$try_sca[$a-1]}=$length{$try_sca[$a-1]}\t\$pos{$try_sca[$a]}=$pos{$try_sca[$a]}\n" if $Debug;
					for($b=$a-1;$b>=$site[0];$b--)
					{
						$c-=$length{$try_sca[$b]};
						$e=$c-$pos{$try_sca[$b]};
						if(($c+$block)>=$length{$contig})
						{
							$change=$e+$block-$length{$contig};	#坐标变换
							$in=1;
							$d=$b;				#坐标变更起点
							print"\$change=$change\t$c\t$block\t$length{$contig}\n"if $Debug;
							last;
						}
					}
				}
				else
				{
					$c=0;
					$b=$a-1;
				}
				
				if(!$in)
				{
					#$b=$site[1];
					if($site[0]>0)
					{
						$in=1;
						$d=$b;
						$change=$c+$block+$pos{$try_sca[$b+1]}-$pos{$try_sca[$b]}-$length{$try_sca[$b]}-$length{$contig};
						print"\$c=$c\t\$block=$block\t$pos{$try_sca[$b+1]}\t$pos{$try_sca[$b]}\t$length{$try_sca[$b]}\t$length{$contig}\$change=$change\n" if $Debug;
					}
					elsif(($site[0]==0)and($judge_free==1))		#关系一头在起点
					{
						$in=1;
						$d=$b;					#注意此时$d是-1
						$change=$length{$contig}-$c-$block;
						print"$length{$contig}\t$c\t$block\t\$change=$change\n" if $Debug;
					}
				}
			}
		}
		
		if($in)
		{
			if($d<$a)
			{
				print"\$d=$d\n" if $Debug;
				if($d==-1)
				{
					$pos{$try_sca[$d+1]}=1;
				}
				else
				{
					$pos{$try_sca[$d+1]}=$pos{$try_sca[$d]}+$length{$try_sca[$d]}+$change;
				}
				
				if(($Debug==1)and($d!=-1))
				{
					print"\$change=$change\n";
					print"$pos{$try_sca[$d]}\n";
					print"$length{$try_sca[$d]}\n";
				}
				
				for($b=$d+2;$b<$position;$b++)
				{
					$pos{$try_sca[$b]}=$pos{$try_sca[$b-1]}+$length{$try_sca[$b-1]};
				}
				$pos{$contig}=$pos{$try_sca[$a]}+$length{$try_sca[$a]};
				$pos{$try_sca[$position]}=$pos{$contig}+$length{$contig};
				for($b=$position+1;$b<=$site[1];$b++)
				{
					$pos{$try_sca[$b]}=$pos{$try_sca[$b-1]}+$length{$try_sca[$b-1]};
				}
				if($d==-1)
				{
					for($b=$site[1]+1;$b<$long;$b++)
					{
						$pos{$try_sca[$b]}+=$change;
					}
				}
			}
			elsif($d==$position)
			{
				$pos{$contig}=int($change/2)+$pos{$try_sca[$d-1]}+$length{$try_sca[$d-1]};
			}
			elsif(($long>=$d) and ($d>$position))
			{
				$pos{$contig}=$pos{$try_sca[$a]}+$length{$try_sca[$a]};
				$pos{$try_sca[$position]}=$pos{$contig}+$length{$contig};
				for($b=$position+1;$b<$d;$b++)
				{
					$pos{$try_sca[$b]}=$pos{$try_sca[$b-1]}+$length{$try_sca[$b-1]};
				}
			}
		}
	}
	print "Succesful insert\n" if((($judge)or($judge_end))and($Debug));
}

