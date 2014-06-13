#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

##################################################################
if($ARGV[0] eq "1")
{
	#
	#2003-8-25

($type,$file_in) =@ARGV;

open IN,"$file_in" || die"$!";

$/=">";
my $null=<IN>;
while (<IN>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
#	print  "$title\n";
	@fields = split /\s+/,$title;
	$id = $fields[0];
#	print  "$id\n";
	$seq = join "",@lines;
	$length=length $seq;
	print "$id\t$length\n";
}


}
###################################################################
##################################################################
