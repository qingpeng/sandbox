#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


# ������est/reads���бȶԣ�
# 2004-5-25 13:29 ����ע��

# ��� Global!
#2004-6-25 10:45 ��飡
# �������� ���Ǳȵ�ͬһ��������ȥ�� hit ��ʹ���б�
# 2004-8-29 9:57
# ��� ge21����б�
# v2 


# file in:
# cluster10013_1_Step1_444_644	rlin36_f13.y1.abd	1	201	361	561	201
# cluster10013_1_Step1_444_644	cluster20805_2_Step1	1	201	482	282	201
# cluster10013_1_Step1_444_644	cluster20805_3_Step1	1	201	449	249	201
# 



# gene_est_reads.list
#ENSG00000000003	rbyb_65626.y1.abd rbde_95219.y1.abd byd_6547.z1.abd cluster379_2_Step2 cluster379_-5_Step2 cluster379_-8_Step2 cluster379_-6_Step2
#ENSG00000000005	rbla_76619.y1.abd cluster72948_1_Step1 rcpg0_046994.y1.abd

if (@ARGV<2) {
	print  "programm file_in gene2est/read.list out_file\n";
	exit;
}
($file_in,$list_in,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

open IN,"$file_in" || die"$!";
open LIST,"$list_in" || die"$!";
while (my $line = <LIST>) { # �����б���Щreads���ڱȶ�����ͬһ������
	chomp $line;
	my @fields = split /\t/,$line;
	if ($fields[1] ne "") {
	
	my @fields2 = split /\s+/,$fields[1];
	foreach my $est (@fields2) {
		if (exists $gene{$est}) {
			#print  "$est\n";
		}
		$gene{$est} = $fields[0];
	}
	}
}

while (my $line = <IN>) {
	chomp $line;


# cluster10013_1_Step1_444_644	rlin36_f13.y1.abd	1	201	361	561	201
# cluster10013_1_Step1_444_644	cluster20805_2_Step1	1	201	482	282	201
# cluster10013_1_Step1_444_644	cluster20805_3_Step1	1	201	449	249	201
# 



	my @fields = split /\t/,$line;
			@split_1 = split "_",$fields[0];
			pop @split_1;
			pop @split_1;
			$split_1 = join "_",@split_1;
			$split_2 = $fields[1]; # ��ȫ��est/reads���бȶ� 
			unless ($gene{$split_1} eq $gene{$split_2}) { #������ͬһ��gene 
				print OUT "$line\n";
			}
}

	



