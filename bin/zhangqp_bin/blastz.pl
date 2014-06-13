#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# ./Blastz/ 目录下运行

use File::Glob;


if (@ARGV<2) {
	print  "programm list_file Contig/Scaffold_file \n";
	exit;
}
($list_file,$file_in) =@ARGV;

# list_file
# 8	144895317	145028132
# 
open LIST,"$list_file" || die"$!";
open IN,"$file_in" || die"$!";
#print  "C\n";

while (<LIST>) {
	chomp;
	@s = split /\t/,$_;
	$chr = $s[0];
	$start = $s[1]-50000;
	$end = $s[2]+50000;
	$db_seq = &extract($chr,$start,$end);
	$title = $chr."_".$start."_".$end;
	$db_file = $title.".fa";
	open DB,">$db_file" || die"$!";
	print DB ">$title\n$db_seq\n";
	close DB;
}
#print  "B\n";
@s_1 = split /\//,$file_in;
@s_2 = split /\./,$s_1[-1];
$dir_name = $s_2[0];
print  "BAC===$dir_name\n";
`perl /disk10/prj0326/zhangqp/bin/OneFastaOneFile.pl -i $file_in -od $dir_name`;

my @in_files = glob ("./$dir_name/*.fa");
#print  "A===========@in_files=============\n";
foreach my $file (@in_files) {
#	print  "$file\n";
  my $blastz_out = $file.".blastz";
 `/usr/local/genome/BLASTZ-2003-05-14-64bit/blastz  $file $db_file C=2 K=2200 >$blastz_out`;
  my $snap_out = $blastz_out.".snap";
 `perl /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/bin/snap.pl -j $blastz_out >$snap_out`;
}

`cat ./$dir_name/Sca*.snap >./$dir_name.blastz_human_genome.snap`;

print  "blastz.pl Over!\n";


sub extract {#*********************** get sequence from Human Genome ##################
	my ($chr_id,$start,$end) = @_;
	my $length = $end-$start+1;
#	open IN,"/disk10/prj0326/xujzh/est_map_desert/chr3/unmask_chr3_desert/$desert_name" || die"$!"; #### path need	modified!!!!
#open IN,"/disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Genome/Ensembl/$chr_id.masked.fa" || die"$!";
open IN,"/disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Genome/UCSC_Unmasked/$chr_id.fa" || die"$!";
	my $seq = "";
	while (<IN>) {
		chomp;
		unless ($_ =~/^>/) {
			$seq = $seq.$_;
#			print  "$seq";
		}
	}
	close IN;
#	print  "$seq\n";
	my $subseq = substr $seq,$start-1,$length;
	return $subseq;
}
