#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn 
# blast 结果中坐标从1 数起
#  m8 为 比上的非unique区域，本程序，截出没有比上的 unique区域，截取出来

## >60!!
# comment added
# 2004-5-25 11:56
# 2004-6-25 11:09 check
# 注意mask两端分别往里面靠了10bp
#　2004-8-29 10:32
# modified from from_m8_to_unique_pos_v2.pl 
# 修改了输出文件格式
# 
# 空30 就是用参数30 间隔30的就不合并 
# 两段延伸20bp
# 2004-11-13 18:23
# v2

if (@ARGV<2) {
	print  " Programme   filter_Global_v2.pl_out unique_pos \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# m8:
# cluster1000_12_Step1_65_114（必须包括最后两个坐标信息）	cluster1000_-16_Step1_82_131	100.00	50	0	0	1	50	1	50	4.6e-22	99.61
# cluster1000_12_Step1_65_114	cluster1000_12_Step1_65_114	100.00	50	0	0	1	50	1	50	4.6e-22	99.61

# new_input_format
# cluster10013_1_Step1_444_644    cluster20805_2_Step1    1       201     482     282     201
# cluster10013_1_Step1_444_644    cluster20805_3_Step1    1       201     449     249     201
# cluster10013_1_Step1_444_644    cluster91_12_Step3      1       159     159     1       159
# cluster10013_1_Step1_444_644    cluster20805_-5_Step1   1       147     147     1       147
# cluster10013_1_Step1_444_644    cluster91_4_Step3       1       136     136     1       136

# Output:
# bdd_20650.z1.abd_180_698	280	382
# cluster306977_-2_Step1_3_188	1	101
# cluster306977_-2_Step1_3_188	103	186
# rbyf_18277.y1.abd_58_190	1	109
# rdpcxa0_101414.y1.scf_5_407	38	113
# rdpcxa0_101414.y1.scf_5_407	184	328



while (my $line = <IN>) {  # 读取比上区域的坐标 
	chomp $line;
	my @fields = split /\t/,$line;
	my $name = $fields[0];
	my $start = $fields[2];
	my $end = $fields[3];
	my @split_fields_1 = split "_",$fields[0];
	my $length = $split_fields_1[-1]-$split_fields_1[-2]+1;
	push @{$pos{$name}},$start;
	push @{$pos{$name}},$end;
	$length{$name} = $length;
}

foreach my $name (keys %pos) {
#	print  "$name\n";
	my @pos = @{$pos{$name}};
#	print  "pos==@pos\n";
	my @region = &cat(30,@pos); #合并碎小的比上区域（non-unique区域）（因为non-unique间隔中如果<30bp,不可能有70bp的unique区域已设计oligo!!!
#1,50,70,100,160,200
#print  "region==@region\n";
	if ($region[0]>50) {
		$end = $region[0]-1+20;
		print OUT "$name\t1\t$end\n";
	}
	for (my $k = 1;$k<scalar @region-2;$k=$k+2) {
		$start = $region[$k]+1-20;
		$end = $region[$k+1]-1+20;
		print OUT "$name\t$start\t$end\n";
	}
	$last_pos = scalar @region -1;

	$last_start = $region[$last_pos]+1-20;
#	print  "$last_start=====$length{$name}\n";
	if ($length{$name}- $last_start+1>=70) {
		print OUT "$name\t$last_start\t$length{$name}\n";
	}
}






######################################################################33333
###################################################################

	sub cat
	#function:quit redundance
	#input:($para,@array), para is the merge length 
	#output:(@array), 
	#for example (0,1,3,4,7,5,8)->(1,3,4,8) (1,1,3,4,7,5,8)->(1,8)
	{
		my($merge,@input) = @_;
		my $i = 0;
		my @output = ();
		my %hash = ();
		my $each = 0;
		my $begin = "";
		my $end = 0;


		for ($i=0;$i<@input;$i+=2) 
		{
			$Qb = $input[$i];
			$Qe = $input[$i+1];

			if($Qb > $Qe) { next; }
			if(defined($hash{$Qb}))	{ if($hash{$Qb} < $Qe) { $hash{$Qb} = $Qe; } }
			else { $hash{$Qb} = $Qe; }
			$Qb = 0;
		}

		foreach $each (sort {$a <=> $b} keys %hash) 
		{
			if($begin eq "")
			{
				$begin = $each;
				$end = $hash{$each};
			}
			else
			{
				if($hash{$each} > $end) 
				{
					if($each > $end + $merge) 
					{ 
						push(@output,$begin);
						push(@output,$end);
						$begin = $each; 
						$end = $hash{$each};
					}
					else { $end = $hash{$each}; }
				}
			}
		}
		if(%hash > 0)
		{
			push(@output,$begin);
			push(@output,$end);
		}

		%hash = ();

		return(@output);
	}



