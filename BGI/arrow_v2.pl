#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# ??Ìí¼Ó¼ýÍ· ¡£¡£¡£¡£

# original file
#16125:16145:+::cluster12571_-2_Step1
#25932:25972:+::cluster1466_7_Step1
#25419:25473:+::cluster1466_1_Step1
#25532:25558:+::cluster1466_1_Step1
#25932:25972:+::cluster1466_1_Step1
#25532:25558:+::cluster1466_-8_Step1



if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

$sort_file = $file_in.".sort";
`sort -t: -k5,5 -k1,1n $file_in >$sort_file`;


open IN,"$sort_file" || die"$!";

my $a = "1::";
my $b = "::";
my @read;
my @start;
my @end;
my @sign;


	my @lines = <IN>;
	chomp @lines;
	close IN;
for (my $kk = 0;$kk< scalar @lines;$kk++) {
	my @fields = split ":",$lines[$kk];
	$read[$kk] = $fields[4];
	$start[$kk] = $fields[0];
	$end[$kk] = $fields[1];
	if ($fields[0]>$fields[1]) {
		$start[$kk] = $fields[1];
		$end[$kk] = $fields[0];
	}
	$sign[$kk] = $fields[2];
}
################# line 0 ###########################333
if ($sign[0] eq "-") {
	print OUT "$start[0]:$end[0]:$sign[0]$a$read[0]\n";
}
else {
			if ($read[0] ne $read[1]) {
			print OUT "$start[0]:$end[0]:$sign[0]$a$read[0]\n";
		}
		else {
			print OUT "$start[0]:$end[0]:$sign[0]$b$read[0]\n";
			
		}

}

############### line middle ##########################3
for (my $k = 1;$k<scalar @lines-1;$k++) {
	if ($sign[$k] eq "-") {
		if ($read[$k] ne $read[$k-1]) {
			print OUT "$start[$k]:$end[$k]:$sign[$k]$a$read[$k]\n";
		}
		else {
			print OUT "$start[$k]:$end[$k]:$sign[$k]$b$read[$k]\n";
		}
	}else {
		if ($read[$k] ne $read[$k+1]) {
			print OUT "$start[$k]:$end[$k]:$sign[$k]$a$read[$k]\n";
		}
		else {
			print OUT "$start[$k]:$end[$k]:$sign[$k]$b$read[$k]\n";
			
		}
	}
}
############## last line ###############################
my $num = scalar @lines -1;
if ($sign[$num] eq "+") {
	print OUT "$start[$num]:$end[$num]:$sign[$num]$a$read[$num]\n";
}
else {
			if ($read[$num] ne $read[$num-1]) {
			print OUT "$start[$num]:$end[$num]:$sign[$num]$a$read[$num]\n";
		}
		else {
			print OUT "$start[$num]:$end[$num]:$sign[$num]$b$read[$num]\n";
			
		}

}

close OUT;


`rm $sort_file`;



