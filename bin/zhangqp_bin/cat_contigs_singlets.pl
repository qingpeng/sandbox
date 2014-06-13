#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# unction:cat *.contigs/singlets for blastx nr \n 
if (@ARGV<1) {
	print  "programm list\n";
	exit;
}
($file_list) =@ARGV;

open LIST,"$file_list" || die"$!";

# bsaa/
# bsab/
# bsac/
# bsae/
# bsaf/

while ($line = <LIST>) {
	chomp $line;
	@s = split /\//,$line;
	$line = $s[0];
	print  "cat $line/$line.fa.contigs $line/$line.fa.singlets  >../Blastx_Nr/$line.fa.contigs_singlets\n";
}

