#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# updated: add singlets length and use contig length with high coverage instead contig number 2004-3-10 21:14
# singlets num , N50 added
# 2004-4-7 21:35

# 2004-3-10 22:42

if (@ARGV<4) {
	print  "programm every_read_length all_reads_length dir_list info_out \n";
	exit;
}
($every_read_length,$all_reads_length,$dir_list,$file_out) =@ARGV;




open LENGTH,"$every_read_length" || die"$!";# 每一个read长度
while (<LENGTH>) {
	chomp;
	@s=split /\t/,$_;
	$length{$s[0]}=$s[1];
}

open OUT,">$file_out" || die"$!";

# dir.list 包括/
# bsbo0/
# rbsaa0/
# rbsac0/
# rbsae0/
# rbsag0/

open LIST,"$dir_list" || die"$!";
	print OUT "Reads_DB\tReads_num\tContigs_num\tContigs(>4_reads)\tContigs(>4_coverage)\tContigs_Length(>4_coverage)\treads_length_in_db\tAll_contigs|singlets_length\tCoverage\tSinglets_num\tN_50\n";

open LOG,"$all_reads_length" || die"$!";# 每一个库中reads总长
while (<LOG>) {
	chomp;
	@s=split /\t/,$_;
	$length{$s[0]}=$s[1];
}
$contig_length_high_coverage=0;
$kk=0;
while (my $dir = <LIST>) {
	chomp $dir;
	$file_in = $dir."phrap.out.list";
	#print  "===$file_in===\n";
	@s=split /\//,$dir;
	$dir_new = $s[0];
	$fasta_file =$dir.$dir_new.".fa";
	$read_count = `grep -c ">" $fasta_file`;# 计算库中reads个数
	$read_count=~s/\n//g;
	$db_id = $dir_new;
#	print  "$dir_new ______ $read_count\n";
		if ($db_id=~/^r(\w+)/) {
			$db_id=$1;
		}

	open IN,"$file_in" || die"$!";

	$start=1;

#print  "222222_____$file_in ________-2222\n";

	while (<IN>) {
		chomp;
#		print  "$_\n";
## Contig 2.  2 reads; 337 bp (untrimmed), 332 (trimmed).  Isolated contig.	
		if ($_=~/^Contig\s\d+\.\s+(\d+)\s+read\w*\;\s+(\d+)\s+bp/) {
			unless ($start==1) {
#				print  "11111contig_reads_length===$contig_reads_length\ncontig_length===$contig_length\n";

				if ($contig_reads_length/$contig_length>4) {
#					print  "!!!!======$contig_reads_length\t$contig_length\n";
				$kk++;	$contig_length_high_coverage=$contig_length_high_coverage+$contig_length;
				}
				$contig_reads_length=0;
				$contig_length=0;
			}
			$start=0;
#			print  "here!!\n";
			$reads_num = $1;
			$contig_length=$2;
			push @a_contig_length,$contig_length;
#			print  "contiglength===========$contig_length\n";
			$contig_all_length=$contig_all_length+$contig_length;
#			print  "alllength=====$contig_all_length\n";
			$contig_num++;# contig coutn 
			if ($reads_num>4) {
				$num_contig++;# coutig more than 4 reads count
			}
		}
#    -65   585 rbsaa0_000188.y1.scf  582 (  0)  0.17 0.00 0.00   66 ( 66)    0 (  0) 
		elsif ($_=/\s+(\S+\.scf)\s+\d+/) {
			$read_id=$1;
#			print  "there!==$read_id\n";
			$length=$length{$read_id};
#			print  "22222$read_id\t$length\n";
			$contig_reads_length=$contig_reads_length+$length;
#			print  "contig_reads_length==$contig_reads_length\n";
		}
	}
				if ($contig_reads_length/$contig_length>4) {
#					print  "!!!!======$contig_reads_length\t$contig_length\n";
				$kk++;	$contig_length_high_coverage=$contig_length_high_coverage+$contig_length;
				}
				$contig_reads_length=0;
				$contig_length=0;

$pure_contig_all_length = $contig_all_length;
############ 处理singletons ##########
	$singlets_file = $dir.$dir_new.".fa.singlets";
	$singlets_count =0;

	open SING,"$singlets_file" || die"$!";
while (<SING>) {
	chomp;
	if ($_=~/^>(\S+)\s+/) {
		$read_id = $1;
		$singlets_count++;
		$contig_all_length=$contig_all_length+$length{$read_id};# including singlets length

	}
}
close SING;

$N50_length = 0.5*$pure_contig_all_length;
$length_sum = 0;
@sort_contig_length = sort {$b <=> $a} @a_contig_length;
for (my $k = 0;$k<scalar @sort_contig_length;$k++) {
	$length_sum = $length_sum+$sort_contig_length[$k];
	print  "$length_sum\t$sort_contig_length[$k]\t$pure_contig_all_length\n";
	if ($length_sum>$N50_length) {
		$N50 = $sort_contig_length[$k];
		print  "BINGLE!!!\n";
		last;
	}
}


    $coverage=$length{$db_id}/$contig_all_length;
	$p_coverage=sprintf ("%.2f",$coverage);
#	print  "$kk\n";
	print OUT "$db_id\t$read_count\t$contig_num\t$num_contig\t$kk\t$contig_length_high_coverage\t$length{$db_id}\t$contig_all_length\t$p_coverage\t$singlets_count\t$N50\n";
	close IN;
	$read_count=0;
	$contig_num=0;
	$num_contig=0;
	$contig_all_length=0;
	$contig_length_high_coverage=0;
	$kk=0;
	$N50=0;
	$singlets_count = 0;
	@a_contig_length=();
}