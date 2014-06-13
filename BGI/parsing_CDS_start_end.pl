#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn


# 提取出每一个 CDS 的起始与终止坐标 ，以及相应的gene /cds/transcript 名字 和所在 seq accession名
# 2004-6-25 15:17
# 
if (@ARGV<2) {
	print  "programm gbk_flat_file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

$cds_switch = "0";
$cds_num = 0;
$seq_num = 0;
while (my $line = <IN>) {
	chomp $line;
#		print  "line\n$line\n";
	if ($line=~/^ACCESSION\s\s\s(.*)/) {
		
		$seq_num++;
		$accession[$seq_num] = $1;
#		print  "accession===$accession[$seq_num]\n";
		$cds_num =0;
	}
	elsif ($line =~ /^\s{5}CDS/) {# meet the CDS position region start
		$cds_switch  = "1";# mark the CDS Position start
		 $cds_num++;
		$cds_lines[$seq_num][$cds_num] = $line;# read into the array
#		print  "cds_num==$cds_num\n";
#		print  "$cds_lines[$seq_num][$cds_num]\n";
	}
	elsif ($line =~/\/gene=\"(.*)\"/) {
		$gene[$seq_num][$cds_num] = $1;
#		print "22222222222222222222222222222222222\n$1\n";
#if ($gene[$seq_num][$cds_num] eq "ENSMUSG00000020704") {
#	print  "$cds_lines[$seq_num][$cds_num]\n======================\n";
#}
		$cds_switch ="0"; # Mark the CDS position region ends
	}
	elsif ($line =~/\/cds=\"(.*)\"/) {
		$cds[$seq_num][$cds_num] = $1;
#		print "22222222222222222222222222222222222\n$1\n";
		
	}
	elsif ($line =~/\/transcript=\"(.*)\"/) {
		$transcript[$seq_num][$cds_num] = $1;
#		print "22222222222222222222222222222222222\n$1\n";
		
	}

	elsif ($line =~ /^ORIGIN/) {# Mark the sequence region start
		$cds_switch = "0";# Mark the CDS position region ends 
	}
	else {
		if ($cds_switch eq "1") {
			$cds_lines[$seq_num][$cds_num] = $cds_lines[$seq_num][$cds_num].$line;# Join the CDS Position region
		}
	}
}


print OUT "GENE\tCDS\tTRANSCRIPT\tACCESSION\tCDS_START\tCDS_END\n";
for (my $k = 1;$k<$seq_num+1;$k++) { # for every sequence block
	if (defined $cds_lines[$k]) { # if there are CDS in this sequence block
		my $cds_whole_num = scalar @{$cds_lines[$k]};# the CDS number in this block
#				print  "$cds_whole_num\n";

		for (my $m = 1;$m<$cds_whole_num;$m++) { #$cds_whole_num here shouldn't + 1 2003-9-24 15:52
			my $cdsline = $cds_lines[$k][$m];
			my @pos;
			unless ($cdsline =~/:/) {
				@pos = $cdsline =~ /(\d+)\.\.(\d+)/g;
				my @pos_sorted = sort {$a<=>$b} @pos;
#				if ($gene[$k][$m] eq "ENSMUSG00000020704") {
#					print  "k==$k\npos== @pos\npos_sorted===@pos_sorted\n00000000000000000000000\n";
#				}
#				print "@pos_sorted\n";
				my $cds_start = $pos_sorted[0];# 
				my $cds_end = $pos_sorted[-1];
				print OUT "$gene[$k][$m]\t$cds[$k][$m]\t$transcript[$k][$m]\t$accession[$k]\t$cds_start\t$cds_end\n";
#				print OUT "$gene[$k][$m]\t$accession[$k]\t$cds_start\t$cds_end\n";
			}
		}
	}
}

