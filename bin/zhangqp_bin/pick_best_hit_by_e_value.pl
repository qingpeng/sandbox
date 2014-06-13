#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 处理 eblastn格式 提取出对每一个query 比得做好的record e值最低  并且列出比上的最小的e值
# 2004-12-15 16:45
# 

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


# Query-name	Letter	QueryX	QueryY	SbjctX	SbjctY	Length	Score	E-value	Overlap/total	Identity	Sbject-Name
# gi|56202948|emb|CAI21907.1|	108	1	86	1	85	86	 137	1e-33	62/86	72	gi|13385090|ref|NP_079904.1|
# gi|56202948|emb|CAI21907.1|	108	12	86	14	87	88	75.1	6e-15	34/75	45	gi|34536834|ref|NP_899664.1|
# gi|56202948|emb|CAI21907.1|	108	12	86	14	87	88	75.1	6e-15	34/75	45	gi|34536823|ref|NP_899665.1|
# gi|56202948|emb|CAI21907.1|	108	19	51	97	129	180	32.3	0.043	14/33	42	gi|38089083|ref|XP_287764.2|
# gi|56202948|emb|CAI21907.1|	108	6	67	720	773	825	27.7	1.1	18/62	29	gi|38082943|ref|XP_128773.2|
# gi|56202948|emb|CAI21907.1|	108	42	80	367	405	843	27.3	1.4	12/39	30	gi|31981824|ref|NP_663586.2|
# gi|6560616|gb|AAF16687.1|AF111848_1	190	144	175	1218	1249	1338	27.7	4.2	9/32	28	gi|12963563|ref|NP_075679.1|
# gi|6560616|gb|AAF16687.1|AF111848_1	190	75	114	717	756	1084	26.6	9.3	15/42	35	gi|6753234|ref|NP_033914.1|
# gi|6560616|gb|AAF16687.1|AF111848_1	190	129	186	271	322	771	26.6	9.3	21/58	36	gi|38079892|ref|XP_356885.1|
# gi|6552328|ref|NP_015565.1|	278	1	278	24	301	301	 514	1e-146	240/278	86	gi|19745150|ref|NP_084063.1|
# gi|6552328|ref|NP_015565.1|	278	9	278	36	305	305	 374	1e-104	173/270	64	gi|21312524|ref|NP_082333.1|


while (<IN>) {
	chomp;
	unless ($_ =~/^Query/) {
		@s = split /\t/,$_;
		$q_name = $s[0];
		if ($q_name =~/gi\|\d+\|\w+\|(\w+)/) {
			$query = $1;
		}

		$e_value = $s[8];
		$s_name = $s[11];
		if ($s_name =~/gi\|\d+\|\w+\|(\w+)/) {
			$subject = $1;
		}

		if (exists $e{$query}) {
			if ($e_value < $e{$query}) {
				$e{$query} = $e_value;
				$subject{$query} = $subject;
			}
		}
		else {
			$e{$query} = $e_value;
			$subject{$query} = $subject;
		}
	}
}

foreach my $key (sort keys %e) {
	print OUT "$key\t$subject{$key}\t$e{$key}\n";
}



