use strict;
use warnings;
#use Bio::SeqIO;

my $dataset="lt30";
#my @strand=("+","-");
#my @strandName=("sense","antisense");
open DATA,">overlap.result";

			my %loci2id;
			#my %loci2est;
			&getLoci2Distribution(\%loci2id);
			&getEST2count(\%loci2id);

		#close DATA;
#}
close DATA;



#########################################################################################################
sub getEST2count{
	my ($loci2id)=@_;
	#my @frag=sort {$a<=>$b} keys %{$loci2est};
	my %id2est;       #the potential ID's covered ESTs

	print "start counting the est\n";
	#print "$frag[0]\t$frag[1]\t$frag[2]\n";
	

		my $file_est="smallRNA_loci_no_repeat.txt";
		open DATAIN1,$file_est or die $!;
		open TEST1,">testlog_id2est_v5_$dataset.txt";
		open TEST2,">testlog_loci2est_v5_$dataset.txt";
		# go over the whole SNP
		while(my $line=<DATAIN1>){
			chomp $line;
#585	chr1	800	801	rs28853987	0	+	G	G	A/G	genomic	single	unknown	0	0	locus	exact	1
#585	chr1	876	877	rs28484712	0	+	G	G	A/G	genomic	single	unknown	0	0	locus	exact	1
#585	chr1	884	885	rs28775022	0	+	G	G	A/G	genomic	single	unknown	0	0	locus	exact	1

#loci_47401	chr4	-	125801730	125801753
#loci_47402	chr4	-	29826201	29826225
#loci_47403	chr3	-	194363565	194363589
#loci_47404	chr3	-	116128859	116128882
#loci_47405	chr21	-	46352185	46352208
#loci_47406	chr20	-	44623303	44623326
#loci_47407	chr17	-	20953030	20953053
#loci_47408	chr16	-	50679352	50679376
#loci_47409	chr15	-	86240275	86240297
#loci_47410	chr14	-	34651947	34651970
#loci_47411	chr13	-	35828792	35828815

			my @a=split /\t/,$line;
			#my @size = split /,/, $a[19];
			#my @start = split /,/, $a[21];
			my ($chr,$s1,$s2,$id,$strand)=($a[1],$a[3],$a[4],$a[0],$a[2]);
			#my ($Chr,$s1,$s2,$id,$strand)=($a[14],$a[2],$a[3],$a[4],$a[6]);
			#print "$Chr\n";

			#if($chr ne $Chr){next;}
			#my $id=$a[10];
			#my $strand=$a[9];
			#print "$chr\t$Chr\t$strand\t$id\n";

			#if($Strand ne $strand){next;}
			#for(my $i=0;$i<scalar(@start);$i++){
			#	my $s1=$start[$i];
			#	if($s1!~/^\d+$/) {next;}
			#	my $s2=$start[$i]+$size[$i]-1;
			#	if($s2!~/^\d+$/) {next;}
			#	my $id_index=$id."_$i";
				my $id_est="$chr:$s1:$s2:$strand:$id";
				my @bin=&getFragBin($s1,$s2);
				#foreach my $loci (@bin) {
					#$loci2id->{$loci}++;
					#push @{$loci2est->{$loci}},$id_est;
					print TEST2 "$chr\t$s1\t$s2\t@bin\t$strand\t$id_est\n";
					&calESTcount(\%id2est,\@bin,$loci2id,$id_est,$chr);
				#}
			#}
		}


	foreach my $id (keys %id2est) {
		my @ests=@{$id2est{$id}};
		my %ests;
		foreach my $est (@ests) {
			$ests{$est}=1;
		}
		my $count=scalar(keys %ests);
		print "$id\t$count\n";
		print DATA "$id\t$count\n";
	}
	close TEST2;
	close TEST1;

	close DATAIN1;
}

###########################################################################################
sub calESTcount{
	my ($id2est,$bins,$loci2id,$id_est,$chr)=@_;
	my @frag=@{$bins};
	for(my $i=0;$i<scalar(@frag);$i++){
			my $loci=$frag[$i];
			#print "$loci\n";
			if(!$loci2id->{$chr}{$loci}){next;}
			my @id=@{$loci2id->{$chr}{$loci}};
			#print "@id\n";
			#print "$id_est\n";
			#my @est=@{$loci2est->{$loci}};
			#print "@id\n";
			#print "@est\n";
			&getID2SNP($id2est,\@id,$id_est);
	}

}

#########################################################################################################
sub getID2SNP{
	my ($id2est,$ids,$id_est)=@_;
	
	my ($chr2,$ss1,$ss2,$strand2,$est)=split /:/,$id_est;
	foreach my $id (@{$ids}) {
		my ($chr1,$s1,$s2,$strand1,$id)=split /:/,$id;
			if($chr1 ne $chr2){next;}
			if($strand1 ne $strand2){next;}
			if($s1<=$ss2 && $s2>=$ss1){
				push @{$id2est->{$id}},$est;
				print TEST1 "$id\t$est\t$chr1\n";
			}
	}
	
}

#########################################################################################################
sub getLoci2Distribution{
	my ($loci2id)=@_;
	#my $dataset=("ge50","ge30lt50","lt30");
	#my @dataset=("ge50");
	my $file_pos="all.negative.lt30.genome_pos.unique.num.v2";
#N_1019  chr10   +       77426754        77426775
#N_1020  chr10   +       77440334        77440355
#N_1021  chr10   +       77458837        77458858
#N_1022  chr10   -       89533058        89533085


		open DATAIN,$file_pos or die $!;
		open TEST,">testlog_loci2count_as_strand_v5_$dataset.txt";
		#my $row=0;
		#locate the sRNA to bins
		while(my $line=<DATAIN>){
			chomp $line;

			my ($id,$chr,$strand,$s1,$s2)=split /\t/,$line;
			#if($chr ne $Chr){next;}
			my $id_sRNA="$chr:$s1:$s2:$strand:$id";
			#if($Strand ne $strand){next;}

			my @bin=&getFragBin($s1,$s2);
			foreach my $loci (@bin) {
				#$loci2id->{$loci}++;
				push @{$loci2id->{$chr}{$loci}},$id_sRNA;
				print TEST "$chr\t$s1\t$s2\t$loci\t$id_sRNA\n";
			}
		}
		close DATAIN;
		close TEST;

		#locate the est to bins
		#loadCoordinateEST($loci2est,$file_est);

}

########################################################################################################
sub getFragBin{
	my ($s1,$s2)=@_;
	my @bin;
	my $binSize=40;
	for(my $i=$s1;;$i--){
		if($i % $binSize==0){
			push @bin,$i;
			last;
		}
	}
	for(my $i=$s1;$i<=$s2;$i++){
		if($i % $binSize==0){
			push @bin,$i;
		}
	}
	return @bin;
}

