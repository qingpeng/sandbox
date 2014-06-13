#!/usr/local/bin/perl
# programmer: ligq
# e-mail:ligq@genomics.org.cn

# 输入：blat结果
# 对于每个query取比上长度最长的record,并且query和subject必须一致 
# 生成用于做svg图的格式
# 2004-6-15 14:45
# 

#  psLayout version 3
#  
#  match	mis- 	rep. 	N's	Q gap	Q gap	T gap	T gap	strand	Q        	Q   	Q    	Q  	T        	T   	T    	T  	block	blockSizes 	qStarts	 tStarts
#       	match	match	   	count	bases	count	bases	      	name     	size	start	end	name     	size	start	end	count
#  ---------------------------------------------------------------------------------------------------------------------------------------------------------------
#  1590	0	0	0	0	0	9	40966	+	bsba-ENSG00000020577-human	1590	0	1590	bsba-ENSG00000020577-human	42739	0	42556	10	412,110,87,334,86,119,202,127,84,29,	0,412,522,609,943,1029,1148,1350,1477,1561,	0,5666,8302,13772,18066,23715,28545,30025,38148,42527,
#  1119	0	0	0	0	0	5	20754	-	bsba-ENSG000000131979(146)-human	2901	0	1119	bsba-ENSG000000131979(146)-human	21873	0	21873	6	345,85,32,56,110,491,	1782,2127,2212,2244,2300,2410,	0,1969,3300,9222,14388,21382,
#  175	14	0	0	2	77	3	77	+	bsba-ENSG00000180008-human	7010	5454	5720	bsba-ENSG000000131979(146)-human	21873	7838	8104	4	11,51,91,36,	5454,5484,5593,5684,	7838,7866,7976,8068,
#  7010	0	0	0	0	0	2	9294	+	bsba-ENSG00000180008-human	7010	0	7010	bsba-ENSG00000180008-human	16304	0	16304	3	346,129,6535,	0,346,475,	0,4737,9769,
#  48	1	0	0	1	201	1	34	+	bsba-ENSG00000180008-human	7010	5484	5734	bsba-ENSG00000180008-human	16304	7910	7993	2	11,38,	5484,5696,	7910,7955,
#  90	3	0	0	3	134	2	133	-	bsba-ENSG00000180008-human	7010	5452	5679	bsba-ENSG000000131979(146)-human	21873	1462	1688	4	30,46,4,13,	1331,1480,1527,1545,	1462,1612,1658,1675,
#  2026	0	0	18	0	0	0	0	+	bsba-Bos	2044	0	2044	bsba-Bos	2044	0	2044	1	2044,	0,	0,





if (@ARGV<1) {
	print  "programm psl_file_in\n";
	exit;
}
($file_in) =@ARGV;
open I,"$file_in" || die"$!";
print  "$file_in\n";
while (<I>) {
	chomp;
	if ($_=~/^\d/) {
		$line = $_;
		@s = split /\t/,$_;	
#		print  "s9==$s[9]\ns13==$s[13]\n";
		if ($s[9] eq $s[13]) {# query must be the same with the subject;
		
		$name=$s[9];
#		print  "$name\n";
		$length = $s[12]-$s[11];
		if ($s[12]<$s[11]) {
			$length = $s[11]-$s[12];
		}
		if (!exists $length{$name} || $length>$length{$name}) {
#			print  "here!\n";
			$length{$name} = $length;
			$line{$name} = $line;
		}

		}
	}
}

foreach my $key (keys %line) {
#	print  "$key\n";
	$line = $line{$key};

	@s = split /\t/,$line;
	$start = $s[20];
#	print  "start==$start\n";
	$long = $s[18];
	$name=$s[9];
	$direction = $s[8];
	@start = split ",",$start;
	@long = split ",",$long;
	$file_out = $name.".for_svg";
#	$file_out =~s/[\|\(\)\[\]\,]/__/g;
	open O,">$file_out" || die"$!";
	for ($k = 0;$k<scalar @start;$k++) {
		$start = $start[$k]+1;

		$end = $start[$k]+$long[$k];
#		print  "start==$start\tend==$end\n";
		$out= $start.":".$end.":".$direction."::".$name."\n";
		print O $out ;
	}
	close O;
}





