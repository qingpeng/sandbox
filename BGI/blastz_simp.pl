#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<3) {
	print  "programm file_in db_file dir \n";
	exit;
}
($file_in,$db_file,$dir_name) =@ARGV;


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
