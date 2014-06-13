#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

##################################################################
if($ARGV[0] eq "1")
{
	# 计算fa文件中seq 的长度
	#2004-6-7 16:54
($type,$file_in) =@ARGV;

open IN,"$file_in" || die"$!";

$/=">";
my $null=<IN>;
while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];
	$seq = join "",@lines;
	$length=length $seq;
	print "$id\t$length\n";
}


}
###################################################################
##################################################################

if($ARGV[0] eq "2")
{
	#
	# input:
	# 2
	# 4
	# 2
	# 6
	# 7
	# output:
	# 0:0
	# 1:0
	# 2:2
	# 3:2
	# 4:6
	# 5:6
	# 6:12
	# 7:19
	# 比横坐标小的累积
	# 2004-6-7 16:53

($type,$file_in) =@ARGV;

open IN,"$file_in" || die"$!";

$max = 0;
while (<IN>) {
	chomp;
	$length{$_} = $length{$_}+$_;
	if ($_ >$max) {
		$max = $_;
	}
}

for (my $k = 0;$k<$max+1;$k++) {
	$length = 0;
	for (my $kk = 0;$kk<$k+1;$kk++) {
		$length = $length+$length{$kk};
	}
	print  "$k:$length\n";
}


}

