#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# blastn结果中输出连续比上的片断！
# 2004-8-28 17:05
# 不一定是11个前导空格，也不是以"|"开始
# 修正两个问题 1.前导空格 2.序列中的"-"
# 2004-9-2 9:56
# 修正 序列中的"-"影响比上连续序列的坐标
# 2004-9-2 15:18
# # 修改 处理同一个query,同一个subject 多个score值 Line112
# 2004-11-29 15:25 v2.1
# 无论怎样都清空 Line119
# 2004-11-29 18:23 v2.2
# 


if (@ARGV<3) {
	print  "programm min_contiguous_base_num file_in file_out \n";
	exit;
}
($base_num,$file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

$c = 0;# 是否换行开关
$q = 0;# 输出 "|||"开关
$subject_name = "no";

while (<IN>) {
	chomp;
#	print  "$_\n";
# Query= NM_003166
	if ($_ =~ /^Query= (\S+)/) {
		$query_name = $1;
#		print  "1\t$query\n";
	}
# >chr16_90041932_29850000
	elsif ($_ =~/^>(\S+)/) {
		#$old_subject = $subject_name;
		$subject_name = $1;
#		print  "2\t$subject\n";
	}
#                                                                           
# Query: 1      caggaggttgtggatacagtgagttatgacatgcccattcactacagcctggatgacaag 60
#               ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# Sbjct: 401787 caggaggttgtggatacagtgagttatgacatgcccattcactacagcctggatgacaag 401846
# 
#                        
# Query: 61     caagaccct 69
#               |||||||||
# Sbjct: 401847 caagaccct 401855


#  Score = 34.2 bits (17), Expect = 7.9
#  Identities = 20/21 (95%)
#  Strand = Plus / Plus
# 
#                                     
# Query: 3       ggaggttgtggatacagtgag 23
#                |||||||| ||||||||||||
# Sbjct: 1581349 ggaggttgaggatacagtgag 1581369


	elsif ($_ =~/^Query: (\d+)\s+(\S+) (\d+)/ && $c == 0) {
		$q_left = $1;
		$query = $2;
		$q_right= $3;
		$q = 1;
#		print  "3\t$q_left\t$q_right\n";
#		print  "q==$q\tc==$c\n";
		if ($_ =~/^(Query: \d+\s+)\S+ \d+/) {
			$pre = $1;
			$s_num = length $pre; # 判断前导空格的长度
		}
#		print  "s_num == $s_num\n";
	}
	elsif ($_ =~/\s{$s_num}(.*)/ && $q ==1 && $c == 0) {  # 不一定时11个！前导空格！！！！！也不是以"|"开始
		$match = $1;
#		print  "4\tmatch\t$match\n";
	}

	elsif ($_ =~/^Sbjct: (\d+)\s+(\S+) (\d+)/ && $c == 0) {
		$s_left = $1;
		$subject = $2;
		$s_right = $3;
		$c = 1;
		$q = 0;
#		print  "5\t$s_left\t$s_right\n";
	}
# Query: 3       ggaggttgtggatacagtgag 23

	elsif ($_ =~/^Query: (\d+)\s+(\S+) (\d+)/ && $c == 1) {
		$q_right = $3;
		$query = $query.$2;
		$q = 1;
#		print  "6\t$q_right\n";
		if ($_ =~/^(Query: \d+\s+)\S+ \d+/) {
			$pre = $1;
			$s_num = length $pre;
		}
#		print  "s_num == $s_num\n";
	}
#	elsif ($_ =~/\s+(\|+.*)/ && $q ==1 && $c == 1) {# 修改
	elsif ($_ =~/\s{$s_num}(.*)/ && $q ==1 && $c == 1) { 
		$match = $match.$1;
#		print  "7\t$match\n";
	}
	elsif ($_ =~/^Sbjct: (\d+)\s+(\S+) (\d+)/ && $c == 1) {
		$s_right = $3;
		$subject = $subject.$2;
#		print  "8\t$s_right\n";
		$q = 0;
	}
#   Database:
	
	elsif (($_ =~/^\sScore = / )||$_ =~/^\s\sDatabase:/) {  # 修改 处理同一个query,同一个subject 多个score值 2004-11-29 15:37
		if ($old_subject eq "no") {  # 无论怎样，都清空！！ 2004-11-29 18:23
			$old_subject = $subject_name; # 遇到score就可以清空了 2004-11-29 15:37
		}
		else { 
			#$old_subject = $subject_name; # 遇到score就可以清空了 2004-11-29 15:37

#		print  "$_\n";
		$c = 0;
#		print  "match==$match\n";
		@long_match = $match=~m/(\|{$base_num,})/g;
		$start = 0;
		$start_search_q = 0;
		$start_search_s = 0;
		for (my $k = 0;$k<scalar @long_match;$k++) {# 处理每一个片断
			$match_length = length $long_match[$k];
#			print  "$match_length\tlong_match==$long_match[$k]\n";
			$hit = "|"x$base_num;
#			print  "hit==$hit\n";
#			print  "start==$start\n";
			$match_start = index($match,$hit,$start);#  在中间一行上 match上的位置！
			$start = $match_start + $match_length; # 中间一行搜索 起始增加
#			print  "MATCH_start==$match_start\n";
			$match_seq =substr $query,$match_start,$match_length; # 从原始query序列中截取比上的部分序列
			($pure_query = $query)=~s/\-//g; # 去掉 "-"字符
#			print  "query=$query\npure_query=$pure_query\n";
			($pure_subject = $subject) =~s/\-//g;
#			print  "$match_seq\tstart_search_q==$start_search_q\npure_query=$pure_query\n";
#			print  "$match_seq\tstart_search_s==$start_search_s\npure_subject=$pure_subject\n";
			$q_start = index($pure_query,$match_seq,$start_search_q);# 在纯的query序列中查找 精确比对的序列位置
			$s_start = index($pure_subject,$match_seq,$start_search_s);# 在subject序列中。。。
			$start_search_q = $q_start + $match_length; # 增加 查找序列的初始坐标
			$start_search_s = $s_start + $match_length; # 同上
#			print  "q_start == $q_start\ns_start == $s_start\n";
			$new_q_left = $q_left + $q_start;
			$new_q_right = $new_q_left + $match_length -1;
			
			if ($s_left <$s_right) {
				$new_s_left = $s_left+$s_start;
				$new_s_right = $new_s_left + $match_length -1;
			}
			else {
				$new_s_left = $s_left - $s_start;
				$new_s_right = $new_s_left - $match_length + 1;
			}
			$length = $new_q_right - $new_q_left +1;
			print OUT "$query_name\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\t$length\n";
#			print  "OOOOO      $query\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\t$length\n";


		}
		$old_subject = $subject_name;

		}

	}
	else {
		
	}
}