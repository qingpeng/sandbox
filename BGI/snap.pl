#! /usr/local/bin/perl -w

use Getopt::Std;

# declaration variables
our ($seqfile, $format, $com, $nosnap, $snap_bin, $optional);
my ($FileIn, $FileOut);

# initialization
&detect_snap;
&init;
open(FILEIN, $seqfile);
$FileIn = \*FILEIN;
if ($nosnap == 0) {
	open(FILEOUT, $com);
	$FileOut = \*FILEOUT;
} else {
	$FileOut = \*STDOUT;
}

# automatically detect input format
if ($format =~ /auto/) {
	$_ = <$FileIn>;
	if (/FASTA|SSEARCH/) {
		$format = "fasta";
	} elsif (/BLAST/) {
		$format = "blast";
	} elsif (/\S+\s\S+\s[\d.]+\s(\d+\s){7}\S+\s\S+$/) {
		$format = "m8";
	} elsif (/\d+\s+([\d.]+\s){3}\s*\S+\s+\d+\s+\d+\s+\(\d+\)/) { # extracted cross_match
		$format = "cross";
	} elsif (/cross_match/) {
		$format = "cross";
	} elsif (/^>\s\S+/) {
		$format = "mummer";
	} elsif (/#:lav/) {
		$format = "lav";
	} elsif (/^(FF|RF)/) {
		$format = "ssaha";
	} else {
		die("Fail to detect the input format automatically.\n");
	}
	seek($FileIn, 0, 0);
}

# parse
if ($format =~ /lav/) {
	&elav($FileIn, $FileOut);
} elsif ($format =~ /blast/) {
	&eblast($FileIn, $FileOut);
} elsif ($format =~ /m8/) {
	&eblastm8($FileIn, $FileOut);
} elsif ($format =~ /cross/) {
	&ecrossmatch($FileIn, $FileOut);
} elsif ($format =~ /fasta|ssearch/) {
	&efasta($FileIn, $FileOut);
} elsif ($format =~ /mummer/) {
	&emummer($FileIn, $FileOut);
} elsif ($format =~ /ssaha/) {
	&essaha($FileIn, $FileOut);
} else {
	die("Unrecognized format $format\n");
}

close FILEIN;
close FILEOUT;
#end of the main function

# subroutines

# detect the executable snap
sub detect_snap {
	my $tmp = `dirname $0`;
	$nosnap = 0;
	chop($tmp);

	if (-f "./snap") {
		$snap_bin = "./snap";
	} elsif (-f "$tmp/snap") {
		$snap_bin = "$tmp/snap";
	} elsif (!system("which snap 2>&1 > /dev/null")) {
		$snap_bin = "snap";
	} else { $nosnap = 1; };
}

# print usage
sub usage {
	my $program = `basename $0`;
	chop($program);
	print "
Program : $program (Perl interface for snap)
Version : 0.1.16, on September 26, 2003
Contact : liheng\@genomics.org.cn

Usage   : $program [options] alignment

Options : -f STR    format of input file. Accepted format: (default is auto)
                    auto, blast, m8, lav, cross_match, fasta, ssearch, mummer, ssaha
          -j        just convert the format but do not run snap
          -z        optional score rather than the default one:
                    lav     optional: matched bases     default: lav score
                    m8      optional: bit score         default: matched bases
                    blastn  optional: bit score         default: matched bases
                    blastp  optional: matched a.a.      default: bit score
          -h        help
";
	if ($nosnap == 0) {
		open HELP, "$snap_bin -h 2>&1 |";
		while (<HELP>) {
			if (/^Program/ || /^Version/ || /^Usage/ || /^$/ || /^Contact/ || /-h/) {
				next;
			} elsif (/^Options/) {
				$_ =~ s/Options :/         /;
			} elsif (/^Advanced/) {
				print "\n";
			} elsif (/^Comment/) {
				last;
			}
			print;
		}
		close HELP;
	}
	print "
Comment : Recommanded options for BLAST:
          Deal with contig-like sequences alignment without recombination (same spiece):
              snap.pl -n 4096 blastn_input > snap_output
          Map cDNA to genome by blastn:
              snap.pl -p 0.02 -n max_intron_size blastn_input > snap_output
          Align protein with genome by tblastn:
              snap.pl -p 0.02 -d -1 -Cn max_intron_size tblastn_input > snap_output
          Deal with protein or EST to protein alignment:
              snap.pl -d -1 blast_input > snap_output
          Align two baterial genomes with recombination:
              snap.pl -n 1024 -cs 100000000 blastn_input > snap_output
          Deal with cross-spiece sequences alignment at nucleotide level:
              snap.pl -n max_gap_size -cs max_cluster_gap input > snap_output

          For other alignment programs such as BLASTZ, cross_match, FASTA, SSEARCH,
          SSAHA and MUMmer, the options are similar to those used for BLAST.

          Note:
            1. For protein alignment, \"-d -1\" should be flagged to disable automatical
               repeat masking.
            2. For large-scale alignment results, \"-m 100\" may effectively reduce
               the running time by discarding small chains.
            3. Smaller cluster gap (-s) may accelerate the speed and make it possible to
               detect segmental duplication.
          
          Output format: (default)
            Q   Qname Qlen
            R   #repeats Rstart,Rstop;...;
            S   Sname Slen
            C#  Qstart Qstop * Sstart Sstop #blocks total_score
            A   Qstart Qstop strand Sstart Sstop #blocks total_score \\
                Qstart,Qstop;...; Sstart,Sstop;...; score;...;
            T   #alignments total_score
            F   #remained Qstart,Qstop;...; Sstart,Sstop;...; score;...;

          where Q stands for Query, R for Repeat, S Subject, C Cluster,
          A Alignment, T Total and F for Fragment.

"
}

# parse the command-line optins and initialize
sub init {
	our ($opt_h, $opt_j, $opt_c, $opt_v, $opt_b, $opt_C, $opt_z, $opt_t);
	$optional = 0;
	if ($nosnap) { # there is no excutable snap can be found.
		print STDERR "Cannot find snap in \$PATH, -j is flagged automaticaly.\n";
	}
	if (@ARGV < 1) { &usage; exit 1; }

	getopts('f:zjn:s:m:cChp:g:u:d:r:l:bvt');
	if ($opt_h) { &usage; exit; }
	if ($opt_z) { $optional = 1; }
	if ($opt_j) { $nosnap = 1; }
	if (defined $opt_f) { # format
		$format = $opt_f;
	} else {
		$format = 'auto';
	}
	$com = "| $snap_bin";
	if (defined $opt_n) { $com .= " -n $opt_n"; }
	if (defined $opt_d) { $com .= " -d $opt_d"; }
	if (defined $opt_p) { $com .= " -p $opt_p"; }
	if (defined $opt_g) { $com .= " -g $opt_g"; }
	if (defined $opt_u) { $com .= " -u $opt_u"; }
	if (defined $opt_r) { $com .= " -r $opt_r"; }
	if (defined $opt_l) { $com .= " -l $opt_l"; }
	if (defined $opt_s) { $com .= " -s $opt_s"; }
	if (defined $opt_m) { $com .= " -m $opt_m"; }
	if ($opt_c) { $com .= " -c"; }
	if ($opt_C) { $com .= " -C"; }
	if ($opt_v) { $com .= " -v"; }
	if ($opt_b) { $com .= " -b"; }
	if ($opt_t) { $com .= " -t"; }
#	$seqfile = ($ARGV[0]) ? $ARGV[0] : "-";
	$seqfile = $ARGV[0]; # seek() is used. so <STDIN> is not available
}

# extract blast format 8
sub eblastm8 {
	my ($FileIn, $FileOut) = @_;
	while (<$FileIn>) {
		my @t = split;
		print $FileOut $t[0],"\t0\t",$t[1],"\t0\t",$t[6],"\t",$t[7],"\t",$t[8],"\t",$t[9],"\t";
		if ($optional) {
			print $FileOut int($t[11] + 0.5),"\t",$t[10],"\n";
		} else {
			print $FileOut int($t[3] * ($t[2] / 100.0) + 0.5),"\t",$t[10],"\n";
		}
	}
}

# This function is adapted from EblastN.pl (version 3.0), written by Ni Peixiang, nipx@genomics.org.cn
sub eblast {
	my ($FileIn, $FileOut) = @_;
	my ($i, $type, $query, $letter, $name, $length, $qbegin, $qend, $sbegin, $send, $idnty, $expect);
	
	$i = 0;
	$type = 0; $qbegin = 0; $sbegin = 0;
	while (<$FileIn>) {
		if (/^BLASTN/) {
			$type = 1; # use identities as score
		} elsif (/^TBLASTN/ || /^TBLASTX/ || /^BLASTX/ || /^BLASTP/) {
			$type = 0; # use bits as score
		} elsif (/Query= (\S+)/) {
			if($i == 1) {
				print $FileOut "$query\t$letter\t$name\t$length\t$qbegin\t$qend\t$sbegin\t$send\t";
				if ($type == 1) {
					print $FileOut "$idnty\t$expect\n";
				} else {
					print $FileOut "$score\t$expect\n";
				}
				$i = 0; $qbegin = 0; $sbegin = 0;
			}
			$query = $1;
		} elsif (/\((\S+)\s+letters\)/) {
			$letter = $1; $letter =~ s/,//g;
		} elsif (/^>(\S*)/) {
			if($i == 1) {
				print $FileOut "$query\t$letter\t$name\t$length\t$qbegin\t$qend\t$sbegin\t$send\t";
				if ($type != $optional) {
					print $FileOut "$idnty\t$expect\n";
				} else {
					print $FileOut "$score\t$expect\n";
				}
				$i = 0; $qbegin = 0; $sbegin = 0;
			}
			$name = $1;
		} elsif (/Length = (\d+)/) {
			$length = $1;
		} elsif (/Score =\s+(\S+) bits.+Expect(\(\d+\))? = (\S+)/) { # original regex is not suiltable
			if($i == 1) {
				print $FileOut "$query\t$letter\t$name\t$length\t$qbegin\t$qend\t$sbegin\t$send\t";
				if ($type != $optional) {
					print $FileOut "$idnty\t$expect\n";
				} else {
					print $FileOut "$score\t$expect\n";
				}
				$i = 0;	$qbegin = 0; $sbegin = 0;
			}
			$score = int($1 + 0.5);
			$expect = $3;
			$expect =~ s/^e/1e/;
		} elsif (/Identities = (\d+)/) {
			$idnty = $1;
		} elsif (/Query\:\s(\d+)\s*\S+\s(\d+)/) { # original regex may cause errors at least for TBLASTN
			if($qbegin == 0) {
				$qbegin = $1;
			}
			$qend = $2;
		} elsif (/Sbjct\:\s(\d+)\s*\S+\s(\d+)/) { # revised for the same reason
			if($sbegin == 0) {
				$sbegin = $1;
			}
			$send = $2;
			$i = 1;
		}
	}	
	if ($i == 1) {
		print $FileOut "$query\t$letter\t$name\t$length\t$qbegin\t$qend\t$sbegin\t$send\t";
		if ($type != $optional) {
			print $FileOut "$idnty\t$expect\n";
		} else {
			print $FileOut "$score\t$expect\n";
		}
	}
}

# extracct cross_match
sub ecrossmatch {
	my ($FileIn, $FileOut) = @_;
	my ($qname, $qlen, $sname, $slen, $qt, $qp, $st, $sp, $score, $tmp);
	
	while (<$FileIn>) {
		if (/(\d+)\s+[\d\.]+\s[\d\.]+\s[\d\.]+\s+(\S+)\s+(\d+)\s+(\d+)\s\((\d+)\)\s+C?\s(\S+)\s+(.*)/) {
			$score = $1; $qname = $2; $qt = $3; $qp = $4; $qlen = $4+$5; $sname = $6; $tmp = $7;
			if ($tmp =~ /\((\d+)\)\s+(\d+)\s+(\d+)/) {
				$slen = $1+$2; $st = $2; $sp = $3;
			} elsif ($tmp =~ /(\d+)\s+(\d+)\s+\((\d+)\)/) {
				$slen = $2+$3; $st = $1; $sp = $2;
			}
			print $FileOut "$qname\t$qlen\t$sname\t$slen\t$qt\t$qp\t$st\t$sp\t$score\t0\n";
		}
	}
}

# extract FASTA
sub efasta {
	my ($FileIn, $FileOut) = @_;
	my ($qname, $qlen, $sname, $slen, $e);
	my (%tmp, $num);
	$num = 0;

	while (<$FileIn>) {
		if (/>>>(\S+).*-\s(\d+)\s(\S\S)$/) {
			if ($num > 0) {
				# FASTA do not sort the result according to sname, so I have to do it myself.
				foreach $i (sort keys %tmp) {
					print $FileOut $tmp{$i};
				}
				$num = 0;
				%tmp = ();
			}
			$qname = $1; $qlen = $2;
			
		} elsif (/>>(\S+)?.*\((\d+)\s(\S\S)\)$/) {
			if (length($1)) {
				$sname = $1;
			} else { $sname = "NONAME"; } # FASTA may fail to give correct subject name sometimes
			$slen = $2;
		} elsif (/E\(\):\s(.*)$/) {
			$e = $1;
		} elsif (/([\d.]+)%\sidentity\s\(.*\)\sin\s(\d+).*\((\d+)-(\d+):(\d+)-(\d+)\)$/) {
			$score = int($1*$2/100.0+0.5);
			++$num;
			$tmp{$sname,$num} = "$qname\t$qlen\t$sname\t$slen\t";
			if ($3 < $4) {
				$tmp{$sname,$num} .= "$3\t$4\t$5\t$6\t$score\t$e\n";
			} else {
				$tmp{$sname,$num} .= "$4\t$3\t$6\t$5\t$score\t$e\n";
			}
		}
	}
	if ($num > 0) { # output the final block
		foreach $i (sort keys %tmp) {
			print $FileOut $tmp{$i};
		}
	}
}

# extract mummer
sub emummer {
	my ($FileIn, $FileOut) = @_;
	my ($qname, $dir, @t, $qstart, $qend, $sstart, $send);

	while (<$FileIn>) {
		if (/^>\s(\S+)$/) {
			$qname = $1; $dir = 1; # forward
		} elsif (/^>\s(\S+)\sReverse$/) {
			$qname = $1; $dir = 0; # reverse
		} else {
			@t = split;
			if ($dir == 1) {
				$sstart = $t[0]; $send = $t[0]+$t[2]-1;
			} else {
				$send = $t[0]; $sstart = $t[0]+$t[2]-1;
			}
			$qstart = $t[1]; $qend = $t[1]+$t[2]-1;
			print $FileOut "SUBJECT\t0\t$qname\t0\t$qstart\t$qend\t$sstart\t$send\t$t[2]\t0\n";
		}
	}
}

# extract lav
sub elav {
	my ($FileIn, $FileOut) = @_;
	
	while (<$FileIn>) {
		if (/^s/) {
			<$FileIn> =~ /\"[^"]+" (\d+) (\d+) (\d+) (\d+)/; $qlen = $2; $qstrand = $3;
			<$FileIn> =~ /\"[^"]+" (\d+) (\d+) (\d+) (\d+)/; $slen = $2; $sstrand = $3;
			<$FileIn>;
		} elsif (/^h/) {
			<$FileIn> =~ /\">(\S+).*\"/; $qname = $1;
			<$FileIn> =~ /\">(\S+).*\"/; $sname = $1;
			<$FileIn>;
		} elsif (/^a/) {
			<$FileIn> =~ /s (\d+)/; $score = $1;
			<$FileIn> =~ /b (\d+) (\d+)/; $qstart = $1; $sstart = $2;
			<$FileIn> =~ /e (\d+) (\d+)/; $qend = $1; $send = $2;
			if ($optional) {
				$score = 0;
				while (<$FileIn>) {
					if (/l (\d+) (\d+) (\d+) (\d+) (\d+)/) {
						$score += int(($3-$1+1) * ($5/100.0) + 0.5);
					} elsif (/^}/) { last; }
				}
			} else {
				while (!(<$FileIn> =~ /^}/)) {}
			}
			print $FileOut "$qname\t$qlen\t$sname\t$slen\t$qstart\t$qend\t";
			if ($qstrand != $sstrand) {
				$sstart = $slen + 1 - $sstart;
				$send = $slen + 1 - $send;
			}
			print $FileOut "$sstart\t$send\t$score\t0\n";
		} 
	}
}

# extract ssaha
sub essaha {
	my ($FileIn, $FileOut) = @_;

	while (<$FileIn>) {
		if (/^(R|F)F\s(\S+)\s(\d+)\s(\d+)\s(\S+)\s(\d+)\s(\d+)\s(\d+)\s(\d+\.\d+)/) {
			print $FileOut "$2\t0\t$5\t0\t$3\t$4\t";
			$score = int($8*($9/100.0)+0.5);
			if ($1 eq "F") {
				print $FileOut "$6\t$7\t$score\t0\n";
			} else {
				print $FileOut "$7\t$6\t$score\t0\n";
			}
		}
	}
}
