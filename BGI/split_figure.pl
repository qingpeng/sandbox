#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 切分 Fgenesh 目录下的结果
# 
if (@ARGV<1) {
	print  "programm file_in  \n";
	exit;
}
($file_in) =@ARGV;

open IN,"$file_in" || die"$!";
# 
# 11979:12257:-::bsaw_1
# 11314:11350:-::bsaw_1
# 8888:9104:-::bsaw_1
# 8648:8789:-::bsaw_1
# 7981:8072:-::bsaw_1
# 7797:7888:-::bsaw_1
# 6105:6374:-::bsaw_1
# 3940:4021:-::bsaw_1
# 3733:3771:-::bsaw_1

while (<IN>) {
	chomp;
	@s = split /:/,$_;
	$id = $s[-1];
	@s_2 = split /_/,$id;
	$bac = $s_2[0];
	$file_out = "../".$bac."/Fgenesh/".$bac.".fgensh.figure ";
	print  "$file_out\n";
	open OUT,">>$file_out" || die"$!";
	print OUT "$_\n";
	close OUT;
}

