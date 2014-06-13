#!/usr/local/bin/perl
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# updated: add singlets length and use contig length with high coverage instead contig number 2004-3-10 21:14

# 2004-3-10 22:42


open LENGTH,"seq_from_lanfd.fa.Picked.length" || die"$!";# 每一个read长度
while (<LENGTH>) {
	chomp;
	@s=split /\t/,$_;
	$length{$s[0]}=$s[1];
}

open OUT,">phrap.info.pro" || die"$!";
open LIST,"dir.list" || die"$!";
	print OUT "Reads_DB\tReads_num\tContigs_num\tContigs(>4_reads)\tContigs(>4_coverage)\tContigs_Length(>4_coverage)\treads_length_in_db\tAll_contigs|singlets_length\tCoverage\n";

open LOG,"all_reads_length.log" || die"$!";# 每一个库中reads总长
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
#	print  "$dir_new ______ $read_count\n";
		if ($dir_new=~/^r(\w+)/) {
			$db_id=$1;
		}

	open IN,"$file_in" || die"$!";

	$start=1;

#print  "222222_____$file_in ________-2222\n";

	while (<IN>) {
		chomp;
		print  "$_\n";
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

############ 处理singletons ##########
	$singlets_file = $dir.$dir_new.".fa.singlets";
	open SING,"$singlets_file" || die"$!";
while (<SING>) {
	chomp;
	if ($_=~/^>(\S+)\s+/) {
		$read_id = $1;
		$contig_all_length=$contig_all_length+$length{$read_id};# including singlets length
	}
}
close SING;


    $coverage=$length{$db_id}/$contig_all_length;
	$p_coverage=sprintf ("%.1f",$coverage);
	print  "$kk\n";
	print OUT "$db_id\t$read_count\t$contig_num\t$num_contig\t$kk\t$contig_length_high_coverage\t$length{$db_id}\t$contig_all_length\t$p_coverage\n";
	close IN;
	$read_count=0;
	$contig_num=0;
	$num_contig=0;
	$contig_all_length=0;
	$contig_length_high_coverage=0;
	$kk=0;
}