#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# blastn结果中输出连续比上的片断！
# 2004-8-28 17:05
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
$subject = "no";

while (<IN>) {
	chomp;
	#print  "$_\n";
# Query= NM_003166
	if ($_ =~/^Query= (\S+)/) {
		$query = $1;
#		print  "1\t$query\n";
	}
# >chr16_90041932_29850000
	elsif ($_ =~/^>(\S+)/) {
		$old_subject = $subject;
		$subject = $1;
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


	elsif ($_ =~/^Query: (\d+)\s+\w+ (\d+)/ && $c == 0) {
		$q_left = $1;
		$q_right= $2;
		$q = 1;
#		print  "3\t$q_left\t$q_right\n";
	}
	elsif ($_ =~/\s{11}(.*)/ && $q ==1 && $c == 0) {
		$match = $1;
#		print  "4\tmatch\t$match\n";
	}

	elsif ($_ =~/^Sbjct: (\d+)\s+\w+ (\d+)/ && $c == 0) {
		$s_left = $1;
		$s_right = $2;
		$c = 1;
		$q = 0;
#		print  "5\t$s_left\t$s_right\n";
	}
	elsif ($_ =~/^Query: (\d+)\s+\w+ (\d+)/ && $c == 1) {
		$q_right = $2;
		$q = 1;
#		print  "6\t$q_right\n";
	}
	elsif ($_ =~/\s{11}(.*)/ && $q ==1 && $c == 1) {
		$match = $match.$1;
#		print  "6\t$match\n";
	}
	elsif ($_ =~/^Sbjct: (\d+)\s+\w+ (\d+)/ && $c == 1) {
		$s_right = $2;
#		print  "7\t$s_right\n";
		$q = 0;
	}
#   Database:
	
	elsif (($_ =~/^\sScore = / && $old_subject ne "no")||$_ =~/^\s\sDatabase:/) {
	#	print  "$_\n";
		$c = 0;
#		print  "match==$match\n";
		@long_match = $match=~m/(\|{$base_num,})/g;
		$start = 0;
		for (my $k = 0;$k<scalar @long_match;$k++) {# 处理每一个片断
			$match_length = length $long_match[$k];
#			print  "$match_length\tlong_match==$long_match[$k]\n";
			$hit = "|"x$base_num;
#			print  "hit==$hit\n";
#			print  "start==$start\n";
			$match_start = index($match,$hit,$start);
			$start = $match_start + $match_length;
#			print  "MATCH_START==$match_start\nadd_start == $start\n";
			$new_q_left = $q_left+$match_start;
			$new_q_right = $new_q_left + $match_length-1;
			if ($s_left <$s_right) {
				$new_s_left = $s_left+$match_start;
				$new_s_right = $new_s_left + $match_length -1;
			}
			else {
				$new_s_left = $s_left - $match_start;
				$new_s_right = $new_s_left - $match_length + 1;
			}
			$length = $new_q_right - $new_q_left +1;
			print OUT "$query\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\t$length\n";
#			print  "OOOOO      $query\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\t$length\n";


		}




# 		if (@long_match >1) {
# 			print  "!!!!!!!!!!!query\t$old_subject\n";
# 		}
# 		if (@long_match == 1) {
# 			$match_length = length $long_match[0];
# 			$match_start = index($match,"|||||||||||||||||||||");
# 			print  "MATCH_START==$match_start\n";
# 			$new_q_left = $q_left+$match_start;
# 			$new_q_right = $new_q_left + $match_length-1;
# 			if ($s_left <$s_right) {
# 				$new_s_left = $s_left+$match_start;
# 				$new_s_right = $new_s_left + $match_length -1;
# 			}
# 			else {
# 				$new_s_left = $s_left - $match_start;
# 				$new_s_right = $new_s_left - $match_length + 1;
# 			}
# 			print OUT "$query\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\n";
# 			print  "OOOOO      $query\t$old_subject\t$new_q_left\t$new_q_right\t$new_s_left\t$new_s_right\n";
# 		}
	}
}