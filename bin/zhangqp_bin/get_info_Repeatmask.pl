#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 对repeat mask结果进行统计
# 2004-3-10 11:35
# input : all.out all.masked
# output : repeat_reads.list repeat.info
# repeat 部分超过50% 标记为repeat序列

open IN,"seq.screen.high_qual.masked.out" || die"$!";

open READ,"seq.screen.high_qual.masked" || die"$!";

$/=">";
my $null = <READ>;
open LOG,">repeat_reads.list" || die"$!";
my %seq_length;
my %drop;
my %all;

while (<READ>) {
	chomp ;
	@lines = split /\n/,$_;
	$title = shift @lines;
	@fields = split /\s+/,$title;
	$id = $fields[0];
		@n = split /_/,$id;
		$database = $n[0];
		if ($database=~/^r(\w+)/) {
			$database=$1;
		}
		$seq = join "",@lines;
#		print  "SEQ$id==$seq\n";
		$n_num=$seq=~tr/N//;
		$all{$database}++;
		$read_length = length $seq;
		
#		print  "$id\t$n_num\t$read_length\n";
		if ($n_num/$read_length>0.5 ) {
			$drop{$database}++;
			print LOG "$id\n";
		}
		$seq_length{$database} = $seq_length{$database}+$read_length;
}

#open O,">db2.info" || die"$!";
#foreach my $key (sort keys %all) {
#	print O "$key\t$all{$key}\t$drop{$key}\n";
#}
#close O;

#exit;

$/="\n";

while (<IN>) {
	chomp;
	if ($_=~/\d+/) {
		@s= split /\s+/,$_;
		$read_name = $s[5];
		$repeat_start = $s[6];
		$repeat_end = $s[7];
		$repeat_length=$repeat_end-$repeat_start+1;
#		print "length====$repeat_length\n";

		$type = $s[11];

		$type{$type}=1;
		@t = split /_/,$read_name;
		$db = $t[0];
		if ($db=~/^r(\w+)/) {
			$db=$1;
		}

		${$type_num{$db}}{$type}=${$type_num{$db}}{$type}+$repeat_length;
		if ($type=~/DNA/) {
			${$type_num_2{$db}}{"DNA"}=${$type_num_2{$db}}{"DNA"}+$repeat_length;
		}
		elsif ($type=~/LINE/) {
			${$type_num_2{$db}}{"LINE"}=${$type_num_2{$db}}{"LINE"}+$repeat_length;
		}
		elsif ($type=~/SINE/) {
			${$type_num_2{$db}}{"SINE"}=${$type_num_2{$db}}{"SINE"}+$repeat_length;
		}
		elsif ($type=~/LTR/) {
			${$type_num_2{$db}}{"LTR"}=${$type_num_2{$db}}{"LTR"}+$repeat_length;
		}
	}
}
open O,">repeat.info2" || die"$!";
@type=("DNA","LINE","SINE","LTR");
print O "DB\tAll_reads_num\tRepeat_reads_num\t";
foreach my $type (sort @type) {

	$type2=$type." (%)";
	print O "$type2\t";
}
foreach my $type (sort keys %type) {
	$type2=$type." (%)";
	print O "$type2\t";
}
print O "\n";

foreach my $db (sort keys %seq_length) {
	my $all=$all{$db};
	my $drop=$drop{$db};
	print O "$db\t$all\t$drop\t";



foreach my $type (sort @type) {
	$type_percent=${$type_num_2{$db}}{$type}*100/$seq_length{$db};
		$printf =sprintf ("%.1f",$type_percent);
		print O "$printf\t";
}

	
	foreach my $type (sort keys %type) {
#		print  "$db ===$type ====type_num== ${$type_num{$db}}{$type}\t\tseq_length====$seq_length{$db}\n";
		$type_percent = ${$type_num{$db}}{$type}*100/$seq_length{$db};
		$printf =sprintf ("%.1f",$type_percent);
		print O "$printf\t";
	}
	print O "\n";
}

close O;

open LOG,">all_reads_length.log" || die"$!";
foreach my $key (sort keys %seq_length) {
	print LOG "$key\t$seq_length{$key}\n";
}