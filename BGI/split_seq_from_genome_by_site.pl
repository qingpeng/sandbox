#!/usr/bin/perl -w
#modify:2004-9-14: in order to exact sequence from solar.pl result; and add more detail annotation;

use Data::Dumper;
use strict;
use Getopt::Long;

my $Modify="2004-10-20";
my $Version="3.0";
my $Date="2004-9-9";
my $update="2004-10-20";
my $Author="Jiang Hui-feng";
my $function="pick out sequence from genome with given site";
my $Contact="jianghf\@genomics.org.cn";
my $Attention="first, chromosome name in genome must be consistent with that in alignment result;\n
		second, chromosome sequence must be fasta format\n";

my %opts;
GetOptions(\%opts,"i:s","o:s","d:s","f:s","help");

if ((!defined $opts{i})|| (!defined $opts{o})||(!defined $opts{d})) {
	Usage();
}

my @gene=();
my @site=();
my %hash_seq;

if (!defined $opts{f}) {
	$opts{f}="F";
}
open(OUT,">$opts{o}");print "Running.....\n";

@site=&exact_site($opts{i});#cite sub to exact gene alignment sites in genome;
&get_genome_seq;
@gene=&split_seq; #cut off sequence from genome according to above alignment sites

for (my $t=0;$t<@gene ;$t++) {
	print OUT "$gene[$t]";
}


sub get_genome_seq 
{
	open (Genome,"$opts{d}")||die "can't open genome sequence file\n";
	$/=">";
	while (<Genome>) {
		#Fasta format
		chomp;
		if ($_ ne '') {
			my @in=split(/\n/,$_,2);
			$in[0]=~s/\s+\S+//g;
			$in[0]=~s/\s+|\n//g;
			$in[1]=~s/\s+|\n//g;
			$in[1]=~s/ //g;
			$in[1]=uc($in[1]);
			#print "$in[0]+++++++\n$in[1]\n";
			$hash_seq{$in[0]}=$in[1];#get chromosome sequence;
		}
	}
	close Genome;
}

sub exact_site ()
{
	my ($file)=@_;
	open (Site,"$file")||die "open site error\n";
	my @out=();
	while (<Site>) {
		my $gene_name='';
		my $chr_name='';
		my $block_size=0;
		my $block_start=0;
		my $direction='';
		my $line='';

		my @info=split(/\s+/,$_);
		my $numb=scalar (@info);
		if ($opts{f} eq "F") {
			if ($numb==12) { #EblastN.pl result;
                if (($info[4]>$info[5]) || ($info[2]>$info[3])) {
                        $direction="-";
                }
                elsif ((($info[4]>$info[5]) && ($info[2]>$info[3]) ) || (($info[4]<$info[5]) && ($info[2]<$info[3]))) {
					$direction="+";
				}
                if ($info[4]>$info[5]) {
                        my $a=$info[4];
                        $info[4]=$info[5];
                        $info[5]=$a;
                }

				$block_size=$info[5]-$info[4]+1;
				$block_start=$info[4];
				$gene_name=$info[0]."_".$info[4]."_".$info[5];
				$chr_name=$info[11];
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}

			elsif($numb==21){ #blat result;
				$chr_name=$info[13];
				$gene_name=$info[9]."_".$info[15]."_".$info[16];
				$direction=$info[8];
				$block_size=$info[18];
				$block_start=$info[20];
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}

			elsif ($numb==14) { #solar.pl result;
				my $start=0;
				my $end=0;
				my $size=0;
				my @st=();
				my @size=();
				my @block_size=split (/\;/,$info[12]);
				for (my $b=0;$b<@block_size ;$b++) {
					if ($info[4] eq "+") {
						$start=(split(/\,/,$block_size[$b]))[0];
						$end=(split(/\,/,$block_size[$b]))[1];
						$size=$end-$start+1;
						push (@st,$start);
						push (@size,$size);
					}
					else {
						$start=(split(/\,/,$block_size[$b]))[1];
						$end=(split(/\,/,$block_size[$b]))[0];
						$size=$end-$start+1;
						push (@st,$start);
						push (@size,$size);
					}
				}
				if ($info[4] eq "-") {
					@st=reverse (@st);
				}
				$gene_name=$info[0]."_".$info[7]."_".$info[8];
				$chr_name=$info[5];
				$direction=$info[4];
				$block_size=join (",",@size);
				$block_start=join (",",@st);
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}
		}

		elsif ($opts{f} eq "T") {
			if ($numb==12) {
                if (($info[4]>$info[5]) || ($info[2]>$info[3])) {
                        $direction="-";
                }
                elsif ((($info[4]>$info[5]) && ($info[2]>$info[3]) ) || (($info[4]<$info[5]) && ($info[2]<$info[3]))) {
					$direction="+";
				}
                if ($info[4]>$info[5]) {
                        my $a=$info[4];
                        $info[4]=$info[5];
                        $info[5]=$a;
                }

				$block_size=$info[5]-$info[4]+1;
				$block_start=$info[4];
				$gene_name=$info[0]."_".$info[4]."_".$info[5];
				$chr_name=$info[11];
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}
			elsif($numb==21){
				$chr_name=$info[13];
				$gene_name=$info[9]."_".$info[15]."_".$info[16];
				$direction=$info[8];
				$block_size=$info[16]-$info[15]+1;
				$block_start=$info[15];
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}
			elsif ($numb==14) {
				$gene_name=$info[0]."_".$info[7]."_".$info[8];
				$chr_name=$info[5];
				$direction=$info[4];
				$block_size=$info[8]-$info[7]+1;
				$block_start=$info[7];
				$line="$gene_name\t$chr_name\t$block_size\t$block_start\t$direction\n";#exact information about :gene_name	chromosome_id	block_size	block_start_site_in_genome	alignment_direction;
			}
		}
		#print "$line";
		push(@out,$line);
	}
	return (@out);
}


sub split_seq ()
{
	my @temp=();
	for (my $i=0;$i<@site ;$i++) {
		my @info=split(/\s+/,$site[$i]);
		my $s='';
		foreach  (keys %hash_seq) {
			if ($_ eq $info[1]) {
				my @block=split(/\,/,$info[3]);#get block start site;
				my @lengh=split(/\,/,$info[2]);#get block length;
				for (my $k=0;$k<@block ;$k++) {
					$s.=substr($hash_seq{$_},$block[$k]-1,$lengh[$k]);
				}
				if ($info[4] eq "-") {
					$s=reverse ($s);
					$s=~tr/ATGC/TACG/;
				}
				my $line=">$info[0]\n$s\n";#output fasta format file: gene_name	gene_length	\n	sequence;
			#	print "$line";
				push (@temp,$line);
			}
		}
	}
	return (@temp);
}


sub Usage #help subprogram
{
    print << "    Usage";
  
	Modify   : $Modify
	Version  : $Version
	Date     : $Date
	Update   : $update
	Author   : $Author
	Contact  : $Contact
	Attention:
		$Attention
	
	Function description :
	
		$function

	Usage: $0 <options>

		-i             input gene site file , must be given (String)
		 
		-o             output , must be given (String)
		
		-f             F: exactly cut out each blocks; T: cut out a larger blocks including inter sequence  

		-d             database,must be given
		
		-help          Show help , have a choice

    Usage

	exit(0);
};		
