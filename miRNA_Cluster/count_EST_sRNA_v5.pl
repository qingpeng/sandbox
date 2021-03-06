use strict;
use warnings;
#use Bio::SeqIO;


#my @strand=("+","-");
#my @strandName=("sense","antisense");
open DATA,">EST_coverage_stat_v5.txt";

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
	

		my $file_est="./hg17_EST.pos";
		open DATAIN1,$file_est or die $!;
		open TEST1,">testlog_id2est_v5.txt";
		open TEST2,">testlog_loci2est_v5.txt";
		# go over the whole EST
		while(my $line=<DATAIN1>){
			chomp $line;
##bin	matches	misMatches	repMatches	nCount	qNumInsert	qBaseInsert	tNumInsert	tBaseInsert	strand	qName	qSize	qStart	qEnd	tName	tSize	tStart	tEnd	blockCount	blockSizes	qStarts	tStarts
#585	330	13	0	0	2	2	3	4	-[9]	AA663731	346	1	346	chr1[14]	247249719	2802[16]	3149[17]	6	47,26,73,27,165,5,[19]	0,47,74,147,174,340,	2802,2850,2876,2951,2979,3144,[21]
#585	393	7	0	0	0	0	0	0	+	AA936549	409	9	409	chr1	247249719	4224	4624	1	400,	9,	4224,
#585	372	8	0	0	0	0	0	0	+	AA293168	380	0	380	chr1	247249719	4263	4643	1	380,	0,	4263,
#585	391	8	0	0	0	0	0	0	+	AA458890	399	0	399	chr1	247249719	4263	4662	1	399,	0,	4263,

			my @a=split /\t/,$line;
			my @size = split /,/, $a[19];
			my @start = split /,/, $a[21];
			my $chr=$a[14];
			#my ($Chr,$s1,$s2,$id,$strand)=($a[14],$a[2],$a[3],$a[4],$a[6]);
			#print "$Chr\n";

			#if($chr ne $Chr){next;}
			my $id=$a[10];
			my $strand=$a[9];
			#print "$chr\t$Chr\t$strand\t$id\n";

			#if($Strand ne $strand){next;}
			for(my $i=0;$i<scalar(@start);$i++){
				my $s1=$start[$i];
				if($s1!~/^\d+$/) {next;}
				my $s2=$start[$i]+$size[$i]-1;
				if($s2!~/^\d+$/) {next;}
				my $id_index=$id."_$i";
				my $id_est="$chr:$s1:$s2:$strand:$id_index";
				my @bin=&getFragBin($s1,$s2);
				#foreach my $loci (@bin) {
					#$loci2id->{$loci}++;
					#push @{$loci2est->{$loci}},$id_est;
					print TEST2 "$chr\t$s1\t$s2\t@bin\t$strand\t$id_est\n";
					&calESTcount(\%id2est,\@bin,$loci2id,$id_est,$chr);
				#}
			}
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
			&getID2EST($id2est,\@id,$id_est);
	}

}

#########################################################################################################
sub getID2EST{
	my ($id2est,$ids,$id_est)=@_;
	
	my ($chr2,$ss1,$ss2,$strand2,$est)=split /:/,$id_est;
	foreach my $id (@{$ids}) {
		my ($chr1,$s1,$s2,$strand1,$id)=split /:/,$id;
			if($chr1 ne $chr2){next;}
			if($strand1 ne $strand2){next;}
			if($s1>=$ss1 && $s2<=$ss2){
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
	my $file_pos="../seq/sRNA_pos_id.txt";
#chr17	+	72949785	72949811	loci_11
#chr12	+	87326689	87326712	loci_12

		open DATAIN,$file_pos or die $!;
		open TEST,">testlog_loci2count_as_strand_v5.txt";
		#my $row=0;
		#locate the sRNA to bins
		while(my $line=<DATAIN>){
			chomp $line;

			my ($chr,$strand,$s1,$s2,$id)=split /\t/,$line;
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

