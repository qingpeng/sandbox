#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# pick certain sequence by name in list
# 2004-3-10 20:51

# fasta file
# >NM_000942
# AACCGTGGG..
# >NM_0001
# CCCGGTAAG...

# list file
# NM_000942
# NM_000981
# NM_002348
# NM_002920
# NM_003099
# NM_003256
# NM_004859
# NM_006920
# 
# 2004-4-12 14:07

if (@ARGV<3) {
	print  "programm fasta_file list_file file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;


open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";


while (<LIST>) {
	chomp;
	$title = $_;
	$title=~s/\s//g;
	$mark{$title} = 5;
}

while (<IN>) {
	chomp ;
	if ($_ =~/>(\S+)\s*/) { # here ~~
		$title = $1;
		if ( $mark{$title}==5) {
			$get{$title} = 5;
			$yes = 1;
			print OUT "$_\n";
		}
		else {
			$yes = 0;
		}
	}
	else {
		if ($yes == 1) {
			print OUT "$_\n";
		}
	}
	
}

print  "items in list not picked!!\n";
foreach my $key (keys %mark) {
	unless ($get{$key}==5) {
		print  "$key\n";
	}
}