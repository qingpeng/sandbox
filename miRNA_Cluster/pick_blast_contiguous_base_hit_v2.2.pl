#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# blastn���������������ϵ�Ƭ�ϣ�
# 2004-8-28 17:05
# ��һ����11��ǰ���ո�Ҳ������"|"��ʼ
# ������������ 1.ǰ���ո� 2.�����е�"-"
# 2004-9-2 9:56
# ���� �����е�"-"Ӱ������������е�����
# 2004-9-2 15:18
# # �޸� ����ͬһ��query,ͬһ��subject ���scoreֵ Line112
# 2004-11-29 15:25 v2.1
# ������������� Line119
# 2004-11-29 18:23 v2.2
# 


if (@ARGV<3) {
	print  "programm min_contiguous_base_num file_in file_out \n";
	exit;
}
($base_num,$file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

$c = 0;# �Ƿ��п���
$q = 0;# ��� "|||"����
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
			$s_num = length $pre; # �ж�ǰ���ո�ĳ���
		}
#		print  "s_num == $s_num\n";
	}
	elsif ($_ =~/\s{$s_num}(.*)/ && $q ==1 && $c == 0) {  # ��һ��ʱ11����ǰ���ո񣡣�������Ҳ������"|"��ʼ
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
#	elsif ($_ =~/\s+(\|+.*)/ && $q ==1 && $c == 1) {# �޸�
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
	
	elsif (($_ =~/^\sScore = / )||$_ =~/^\s\sDatabase:/) {  # �޸� ����ͬһ��query,ͬһ��subject ���scoreֵ 2004-11-29 15:37
		if ($old_subject eq "no") {  # ��������������գ��� 2004-11-29 18:23
			$old_subject = $subject_name; # ����score�Ϳ�������� 2004-11-29 15:37
		}
		else { 
			#$old_subject = $subject_name; # ����score�Ϳ�������� 2004-11-29 15:37

#		print  "$_\n";
		$c = 0;
#		print  "match==$match\n";
		@long_match = $match=~m/(\|{$base_num,})/g;
		$start = 0;
		$start_search_q = 0;
		$start_search_s = 0;
		for (my $k = 0;$k<scalar @long_match;$k++) {# ����ÿһ��Ƭ��
			$match_length = length $long_match[$k];
#			print  "$match_length\tlong_match==$long_match[$k]\n";
			$hit = "|"x$base_num;
#			print  "hit==$hit\n";
#			print  "start==$start\n";
			$match_start = index($match,$hit,$start);#  ���м�һ���� match�ϵ�λ�ã�
			$start = $match_start + $match_length; # �м�һ������ ��ʼ����
#			print  "MATCH_start==$match_start\n";
			$match_seq =substr $query,$match_start,$match_length; # ��ԭʼquery�����н�ȡ���ϵĲ�������
			($pure_query = $query)=~s/\-//g; # ȥ�� "-"�ַ�
#			print  "query=$query\npure_query=$pure_query\n";
			($pure_subject = $subject) =~s/\-//g;
#			print  "$match_seq\tstart_search_q==$start_search_q\npure_query=$pure_query\n";
#			print  "$match_seq\tstart_search_s==$start_search_s\npure_subject=$pure_subject\n";
			$q_start = index($pure_query,$match_seq,$start_search_q);# �ڴ���query�����в��� ��ȷ�ȶԵ�����λ��
			$s_start = index($pure_subject,$match_seq,$start_search_s);# ��subject�����С�����
			$start_search_q = $q_start + $match_length; # ���� �������еĳ�ʼ����
			$start_search_s = $s_start + $match_length; # ͬ��
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