#change D-processor result to psl file.
#/usr/local/bin/perl 

open(FD,$ARGV[0])||die " can not open$!";
while(<FD>)
{
		
	if(/^>\"([^\"]*)\"\,(\d+)/)
        {
        	$count++;	
        	
        	#----------------------------
        	@lengsize=split(/,/,$leng);
        	foreach $word(@lengsize)
        	{
        		$sum+=$word;
        	}
        	@querysize=split(/,/,$query_start);
        	$query_num=@querysize;
        	$query_begin=$querysize[0];
        	$query_end=$querysize[$query_num-1]+$lengsize[$query_num-1];
        	@targetsize=split(/,/,$target_start);
        	$tar_num=@targetsize;
        	$tar_begin=$targetsize[0];
        	$tar_end=$targetsize[$tar_num-1]+$lengsize[$tar_num-1];
        	if($strand eq "-"){
        		$temp1=$query_begin;
        		$query_begin=$query_leng-$query_end;
        		$query_end=$query_leng-$temp1;
        	}
        	if($count>1){print "$sum\t0\t0\t0\t0\t0\t0\t0\t$strand\t$query_name\t$query_leng\t$query_begin\t$query_end\t$Scaffold_Name\t$Scaffold_Leng\t$tar_begin\t$tar_end\t$query_num\t$leng\t$query_start\t$target_start\n";}
        	$query_start="";
        	$leng="";
        	$sum=0;
        	$target_start="";
        	$strand="";
        	#-----------------------------
        	$Scaffold_Name = $1;
        	$Scaffold_Leng = $2;
        } 
        elsif(/^\<\"([^\"]*)\"\,\"[^\"]*\"\,(\d+)/)
	{
		$q_name=$1;
		$q_leng=$2;
	}
        elsif(/^E/)
        {
        	$query_name=$q_name;
        	$query_leng=$q_leng;
        	@temp=split(/,/,$_);
        	#print "$temp[1]\n";
        	if($temp[1] eq "F"){
        		#print 1;
        		$strand="+";
        		$query_start.=($temp[2]-1).",";
        		$target_start.=($temp[4]-1).",";
        		$leng.=$temp[6].",";
        	}
        	if($temp[1] eq "R"){
        		#print 2;
        		$strand="-";
        		$query_start=($query_leng-$temp[3]).",".$query_start;
        		$target_start=($temp[5]-1).",".$target_start;
        		$leng=$temp[6].",".$leng;
        	}
        }	

}
@lengsize=split(/,/,$leng);
        	foreach $word(@lengsize)
        	{
        		$sum+=$word;
        	}
        	@querysize=split(/,/,$query_start);
        	$query_num=@querysize;
        	$query_begin=$querysize[0];
        	$query_end=$querysize[$query_num-1]+$lengsize[$query_num-1];
        	@targetsize=split(/,/,$target_start);
        	$tar_num=@targetsize;
        	$tar_begin=$targetsize[0];
        	$tar_end=$targetsize[$tar_num-1]+$lengsize[$tar_num-1];
        	if($strand eq "-"){
        		$temp1=$query_begin;
        		$query_begin=$query_leng-$query_end;
        		$query_end=$query_leng-$temp1;
        	}
        	print "$sum\t0\t0\t0\t0\t0\t0\t0\t$strand\t$query_name\t$query_leng\t$query_begin\t$query_end\t$Scaffold_Name\t$Scaffold_Leng\t$tar_begin\t$tar_end\t$query_num\t$leng\t$query_start\t$target_start\n";
        	
close(FD);
