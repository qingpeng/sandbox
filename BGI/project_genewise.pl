#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "1")
{
	#remove vector sequence: XXXXXXXXXX for EST submit
	#create 2003-11-7
	
	($type,$F_reads) = @ARGV;

	$P_MinSize = 30;

	open(E,$F_reads);
	while(<E>)
	{
		if(/^\>(\S+)/)
		{
			$name = $1;
		}
		elsif(/>/) { die"$_"; }
		else { chomp; $seq{$name} .= $_; }
	}
	close(E);

	open(Problem,">$F_reads.problem");
	foreach $name (keys %seq)
	{
		$seq = $seq{$name}; #print "$seq\n"; 
		$seq =~ tr/\r//d;
		@temp = split(/[Xx]+/,$seq);
		@temp = sort { length($b) <=> length($a) } @temp;
		$seq = $temp[0]; #print "$seq\n"; 

		if(length($seq)>$P_MinSize) 
		{
			$length = length($seq);
			print ">$name $length\n";
			while(length($seq) > 50)
			{
				$temp = substr($seq,0,50);
				substr($seq,0,50) = "";
				print "$temp\n";					
			}
			if(length($seq) > 0)
			{
				print "$seq\n";
			}
		}
		if($seq{$name} =~ /[^Xx]+[Xx]+[^Xx]+/)
		{
			$seq = $seq{$name};
			$length = length($seq);
			print Problem ">$name $length\n";
			while(length($seq) > 50)
			{
				$temp = substr($seq,0,50);
				substr($seq,0,50) = "";
				print Problem "$temp\n";					
			}
			if(length($seq) > 0)
			{
				print Problem "$seq\n";
			}
		}
	}
	close(Problem);

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "splitone")
{
	#2004-5-1
	#split to one

	($type,$F_in) = @ARGV;

	$i = 0;
	open(F,$F_in);
	while(<F>)
	{
		chomp;
		if(/^>(\S+)/)
		{
			$i++;
			$out = "$i.aaa";
			close(O);
			open(O,">$out");
		}
		print O "$_\n";
	}
	close(F);

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "catgenewise")
{
	#2004-5-1
	#cat genewise

	($type) = @ARGV;

	$num = `ls -l *.genewise|wc -l`;

	system"rm genewise.all";
	for($i=1;$i<=$num/2;$i++)
	{
		$p = `wc -l p.$i.genewise`;
		$n = `wc -l n.$i.genewise`;
		if($p>$n) { $out = "p.$i.genewise"; } else { $out = "n.$i.genewise"; }

		print "$out\n";
		system"cat $out >> genewise.all";
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "genewise")
{
	#2004-5-1
	#get aa and na sequence from genewise.

	($type,$F_genewise,$F_seq) = @ARGV;

	open(F,$F_seq);
	while(<F>)
	{
		chomp;
		if(/^>(\S+)/)
		{
			$name = $1;
		}
		else { $seq{$name} .= $_; }
	}
	close(F);
$aa_file = $F_genewise.".aa";
$na_file = $F_genewise.".na";
	open(AA,">$aa_file");
	open(NA,">$na_file");

	$a = 0;
	$gene_na = "";
	open(F,$F_genewise);
	while(<F>)
	{
		chomp;
		if(/^Query protein:\s+(\S+)/) { $query = $1; $a++; $b = 0;} 
		if(/^Target Sequence\s+(\S+)/) { $target = $1;}
		if((/^Gene/ || /^\/\//) && $gene_na ne "") 
		{
			$gene_aa = &dna2peptide($gene_na);

			$seq = $gene_na;
			print NA ">$target\_gw$a\_$b $query $strand $target:$pos\n";
			while(length($seq) > 100)
			{
				$temp = substr($seq,0,100);
				substr($seq,0,100) = "";
				print NA "$temp\n";
			}
			if(length($seq) > 0)
			{
				print NA "$seq\n";
			}

			$seq = $gene_aa;
			print AA ">$target\_gw$a\_$b $query $strand $target:$pos\n";
			while(length($seq) > 100)
			{
				$temp = substr($seq,0,100);
				substr($seq,0,100) = "";
				print AA "$temp\n";
			}
			if(length($seq) > 0)
			{
				print AA "$seq\n";
			}

			$gene_na = ""; $pos = "";
		}
		if(/^Gene\s+(\d+)$/) { $b = $1; }
		if(/^\s*Exon\s+(\d+)\s+(\d+)/) 
		{
			$s = $1;
			$e = $2;
			$pos .= "$s,$e;";

			if($s < $e) 
			{
				$strand = "+"; $start = $s-1; $length = $e - $s + 1; 
				$gene_na .= substr($seq{$target},$start,$length);
			}
			else
			{
				$strand = "-"; $start = $e-1; $length = $s - $e + 1; 
				$temp = substr($seq{$target},$start,$length);
				$gene_na .= &complement($temp);
			}
			$svg .= "$s:$e:$strand\:\:$target\_gw$a\_$b\n";
		}
		
	}
	close(F);

	close(AA);
	close(NA);

	open(FG,">svg.position");
	print FG $svg;
	close(FG);

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "maplength")
{
	#2004-5-2
	#coumput maplength

	($type,$F_list) = @ARGV;

	open(I,$F_list);
	while(<I>)
	{
		chomp;
		if(/^(\S+)/)
		{
			$bac = $1;
			$length = 0;
			$file = "$bac/assemble/$bac.join.bac";
			if(-e $file)
			{
				open(B,$file);
				$seq = "";
				while($sss = <B>)
				{
					chomp($sss);
					unless(/^\>/) { $seq .= $sss; }
				}
				close(B);
				$seq =~ tr/Nn//d;
				$length = length($seq);
			}

			print "$bac	$length\n";
		}
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] eq "nreblastn")
{
	#2004-5-2
	#remove redundance for eblastn

	($type,$F_eblastn) = @ARGV;

	#bsaa/bsaa.fa.Contig4    2790    2520    2245    152     242     654      122    3e-26   62/92   67      ref|NP_002339.1|     lymphocyte antigen 9; T-lymphocyte surface antigen Ly-9; cell-surface molecule Ly-9 [Homo sapiens] gb|AAG14995.1| cell-surface molecule Ly-9 [Homo sapiens]

	$cutoff = 30;

	open(I,$F_eblastn);
	@temp = (<I>);
	chomp(@temp);
	close(I);
	if($temp[0] =~ /^Query-name/) { shift(@temp); }

	$i = 0;
	foreach $each (@temp)
	{
		@temp1 = split(/\t/,$each);
		if(!defined($e{$temp1[11]}) || $e{$temp1[11]} > $temp1[8]) { $e{$temp1[11]} = $temp1[8]; }
		$transcription{$temp1[11]} = $temp1[12];
		$query[$i] = $temp1[0];
		if($temp1[2] < $temp1[3]) { $start[$i] = $temp1[2]; $end[$i] = $temp1[3]; } else { $start[$i] = $temp1[3]; $end[$i] = $temp1[2]; }
		$sbjct[$i] = $temp1[11];
		$i++;
	}

	for($j=0;$j<$i;$j++)
	{
		for($k=$j+1;$k<$i;$k++)
		{
			if($query[$j] eq $query[$k] && $sbjct[$j] ne $sbjct[$k]) 
			{
				if($start[$j] < $start[$k]) { $start = $start[$k] } else { $start = $start[$j]; }
				if($end[$j] > $end[$k]) { $end = $end[$k] } else { $end = $end[$j]; }
				$out = $end - $start;
				if($out > $cutoff)
				{
					if($e{$sbjct[$j]} < $e{$sbjct[$k]}) { $del{$sbjct[$k]}++; } elsif($e{$sbjct[$j]} > $e{$sbjct[$k]}) {$del{$sbjct[$j]}++; }
					elsif($sbjct[$j] gt $sbjct[$k]) { { $del{$sbjct[$k]}++; } } else { { $del{$sbjct[$j]}++; } }
				}
			}
		}
	}
	
	foreach $each (keys %transcription) 
	{
		if(!defined($del{$each})) { print "$each	$e{$each}	$transcription{$each}\n"; }
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
######################################################################33333
sub codon2aa 
{
    my($codon) = @_;
 
       if ( $codon =~ /GC./i)        { return 'A' }    # Alanine
    elsif ( $codon =~ /TG[TC]/i)     { return 'C' }    # Cysteine
    elsif ( $codon =~ /GA[TC]/i)     { return 'D' }    # Aspartic Acid
    elsif ( $codon =~ /GA[AG]/i)     { return 'E' }    # Glutamic Acid
    elsif ( $codon =~ /TT[TC]/i)     { return 'F' }    # Phenylalanine
    elsif ( $codon =~ /GG./i)        { return 'G' }    # Glycine
    elsif ( $codon =~ /CA[TC]/i)     { return 'H' }    # Histidine
    elsif ( $codon =~ /AT[TCA]/i)    { return 'I' }    # Isoleucine
    elsif ( $codon =~ /AA[AG]/i)     { return 'K' }    # Lysine
    elsif ( $codon =~ /TT[AG]|CT./i) { return 'L' }    # Leucine
    elsif ( $codon =~ /ATG/i)        { return 'M' }    # Methionine
    elsif ( $codon =~ /AA[TC]/i)     { return 'N' }    # Asparagine
    elsif ( $codon =~ /CC./i)        { return 'P' }    # Proline
    elsif ( $codon =~ /CA[AG]/i)     { return 'Q' }    # Glutamine
    elsif ( $codon =~ /CG.|AG[AG]/i) { return 'R' }    # Arginine
    elsif ( $codon =~ /TC.|AG[TC]/i) { return 'S' }    # Serine
    elsif ( $codon =~ /AC./i)        { return 'T' }    # Threonine
    elsif ( $codon =~ /GT./i)        { return 'V' }    # Valine
    elsif ( $codon =~ /TGG/i)        { return 'W' }    # Tryptophan
    elsif ( $codon =~ /TA[TC]/i)     { return 'Y' }    # Tyrosine
    elsif ( $codon =~ /TA[AG]|TGA/i) { return '' }    # Stop
    else { print STDERR "Bad codon \"$codon\"!!\n"; }
}
######################################################################33333
sub dna2peptide 
{

    my($dna) = @_;

    my $protein = "";
	my $i=0;

	$dna =~ tr/nN/cC/;
    for($i=0; $i < (length($dna) - 2) ; $i += 3) 
	{
        $protein .= &codon2aa( substr($dna,$i,3) );
    }

    return $protein;
}
########3
if($ARGV[0] eq "testdna2peptide")
{
	$seq = "atggagatggaggctgccacgccggtgccgaggagtgacggcaggaagctggcgaggtgcccgaggctgcagatggacgccaagacggtcactgccatcgagcagtccacgggcgcggccatcgccgacgccgctgcggctggcgccgagggcgccggcggcgggatgcgcgtcaagatcgtgctgagcaagcagcagctgaagcaggtggccgcggccgtcgccggagggggcgccttcgcgctgccgccggcgctggagcagctcgtgagcgtgctcaagcggcagcacgcgaagaagcaggtggcagcggctgctgatgtggtcgtcggaaggcgccgctgccggtggtcgccggcgttgcagagcatcccggaggagtgctttagctag";
	$out = &dna2peptide($seq);
	print "MEMEAATPVPRSDGRKLARCPRLQMDAKTVTAIEQSTGAAIADAAAAGAEGAGGGMRVKIVLSKQQLKQVAAAVAGGGAFALPPALEQLVSVLKRQHAKKQVAAAADVVVGRRRCRWSPALQSIPEECFS\n";
	print "$out\n";

	exit;
}
######################################################################33333
#####################################################################3333

	sub complement
	{
		#function: get complement strand of one nucleotide sequence
		#input:($seq)
		#output:($seq)
		#case: ("atgcAnnA-T") -> ("A-TnnTcgat")
		#create: 2004-4-22
		#last update: 2004-4-22

		my ($seq) = @_;
		my $out = reverse($seq);
		$out =~ tr/ATGCatgc/TACGtacg/;
		return($out);
	}

#####################################################################3333
