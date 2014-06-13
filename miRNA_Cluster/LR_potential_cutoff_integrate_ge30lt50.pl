#!/usr/bin/perl
use strict;
use warnings;
#use DBI;


&main();
############################################################################################################
#
#                         main sub for running the main program
#
############################################################################################################
sub main{
	my $mir_set="ge30lt50";

	my @dataset=  ("dNdS",
					"dG","RNAfold",
					"BLASTevalue","phastCons",
					"SNPnumber",
					"GC_percent",
					"ESTnumber","Unigene");
	my @methy_data=("CTCF","H2AZ","H3K27me2","H3K36me1","H3K4me1","H3K4me3","H3K79me3","H3R2me1","PolII","H2BK5me1");
	push @dataset,@methy_data;
					
	my @dataGroup=("dNdS",
					"foldingEnergy","foldingEnergy",
					"seqConservation","seqConservation",
					"SNPnumber",
					"GCpercent",
					"TranscriptCoverage","TranscriptCoverage");
	my @methy_file;
	my @methy_type;
	foreach my $methy_data (@methy_data) {
		push @dataGroup,"methylation";
		my $methy_file="$methy_data"."_methylation_ge30lt50.txt";
		push @methy_file,$methy_file;
		push @methy_type,"lost";
	}

#my $dir="/home/qpzhang/Ge50";
	my @filein1=("dnds_value_final_ge30lt50.txt",
				 "all.negative.ge30lt50.genome_pos.unique.num.expand_for_cut.fa.title2.dG","all.negative.ge30lt50.genome_pos.unique.num.expand_for_cut.fa.title2.out.negative",
				 "blastn_sRNA_neglog10evalue.txt","all.negative.ge30lt50.genome_pos.unique.phast.all.ID.pro",
				"SNP_coverage_stat_v5_ge30lt50.txt.pro",
				"GC_percent_ge30lt50.txt",
				"EST_coverage_stat_v5_ge30lt50.txt.pro","all.negative.ge30lt50.genome_pos.unique.num.unigene");
	push @filein1,@methy_file;

	my @valuetype=("norm",
					"norm","norm",
					"norm","norm",
					"lost",
					"norm",
					"lost","lost");
		push @valuetype,@methy_type;

	#my @termEachDataset=&getTermEachData();
	my @term2lr;
		for (my $i=0;$i<scalar(@dataset);$i++) {
			$term2lr[$i]=&dataset_getTerm2LR($dataset[$i]);
			#die;
		}
	
	#print "start calculating the test set\n";
	my %mirna2value;
	&loadTestSetValueMatrix(\%mirna2value,\@dataset,\@filein1);
	my %mirna2lr;


	my %LRall;
	foreach my $mirna (keys %mirna2value) {
		my $LRint=1;
		my %LRints;
		 for(my $i=0;$i<scalar(@dataset);$i++){
			 my %term2lrs=%{$term2lr[$i]};
			 if(defined $mirna2value{$mirna}[$i] or $valuetype[$i] eq "lost"){
				 my $value;
				 if(defined $mirna2value{$mirna}[$i]){
					 $value=$mirna2value{$mirna}[$i];
				 }
				 elsif($valuetype[$i] eq "lost"){
					 $value=0;
				 }
				 my $term;
				 $term=&getTermCont1(\%term2lrs,$value);
				#if($valuetype[$i] eq "Dist"){$term=&getTermDist(\%term2lrs,$value);}
				#elsif($valuetype[$i] eq "Cont"){$term=&getTermCont1(\%term2lrs,$value);}
				my $lr=$term2lrs{$term};
				
				#$LRint+=$lr;
				my $g=$dataGroup[$i];
				if(!$LRints{$g}){
					$LRints{$g}=$lr;
					$LRall{$mirna}{$dataGroup[$i]}=$lr;
				}
				elsif($LRints{$g}<$lr){
					$LRints{$g}=$lr;
					$LRall{$mirna}{$dataGroup[$i]}=$lr;
				}
			 }
			 foreach my $g (sort keys %LRints) {
				 if($LRints{$g}){
					 my $lr=$LRints{$g};
					 $LRint*=$lr;
				 }
			 }
		 }


		 $LRint=log($LRint)/log(10);

		 $mirna2lr{$mirna}=$LRint;
		 #print "$mirna\t$LRint\n";
	}
	open DATA2,">lr_matrix_$mir_set.txt";
	print DATA2 "seq_id";
	my %group;
	foreach my $group (@dataGroup) {
		$group{$group}=1;
	}
	foreach my $dataset (sort keys %group) {
		print DATA2 "\t$dataset";
	}
	print DATA2 "\n";
	
		foreach my $gene (keys %LRall) {
			print DATA2 "$gene";
			foreach my $dataset (sort keys %group) {
				my $lr=$LRall{$gene}{$dataset};
				if($lr){
					print DATA2 "\t$lr";
				}
				else{
					print DATA2 "\t";
				}
			}
			print DATA2 "\n";
		}
	close DATA2;


	open DATA1,">LR_rankList_$mir_set.txt";
	 foreach my $mirna (sort {$mirna2lr{$b}<=>$mirna2lr{$a}} keys %mirna2lr) {
		 print DATA1 "$mirna\t$mirna2lr{$mirna}\n";
	 }
	 close DATA1;
}


############################################################################################################

############################################################################################################
sub loadTestSetValueMatrix{
	my ($mir2value,$refDataset,$refile)=@_;
	my @dataset=@{$refDataset};
	my @file=@{$refile};
	open TEST,">testlog_load.txt";
	for(my $i=0;$i<scalar(@dataset);$i++){
		#my $filein="envidence_value_$dataset.txt";
		open DATAIN,$file[$i] or die "cannot locate the file $file[$i]\n";;
		while(my $line=<DATAIN>){
			chomp $line;
			my ($mir,$value)=split /\t/,$line;
			print TEST "$mir\t$value\n";
			if($value and $mir){
				$mir2value->{$mir}[$i]=$value;
				#print "got it!\n";
			}
		}
		close DATAIN;
	}
	close TEST;
	#test the loading
	open TEST1,">testlog_potential2value.txt";
	foreach my $dataset (@dataset) {
		print TEST1 "\t$dataset";
	}
	print TEST1 "\n";
	foreach my $mir (keys %{$mir2value}) {
		print TEST1 "$mir";
		my @value=@{$mir2value->{$mir}};
		foreach my $value (@value) {
			if($value){
				print TEST1 "\t$value";
			}
			elsif(!$value){
				print TEST1 "\t";
			}
#			print TEST1 "\t$value";
		}
		print TEST1 "\n";
	}
	close TEST1;

#	foreach my $mir (keys %{$mir2value}) {
#		print TEST1 "$mir\t";
#		my @value=@{$mir2value->{$mir}};
#		print TEST1 "@value";
#		print TEST1 "\n";
#	}
#	close TEST1;
}
############################################################################################################
#                         calculate SNP parameters
############################################################################################################
sub dataset_getTerm2LR{
	my ($dataset)=@_;
	print "start loading the $dataset LR\n";
	my $filein="/user/home2/qpzhang/Lt30_Score/Lt30_qpzhang/NetworkIntegrationMi3/evidence2lr_$dataset.txt";
	open DATAIN,"$filein" or die "cannot locate the file $filein!\n";
	my %term2lr;
	while(my $line=<DATAIN>){
		chomp $line;
		#$line=~s/[\S\n]+//g;
		my ($term,$lr)=split /\t/,$line;
		#if($lr and $term){
		$term2lr{$term}=$lr;
		#}
	}

	 
	return (\%term2lr);
}

############################################################################################################
#  if the value is larger than the last bin, its LR is the same as the last bin
############################################################################################################
sub getTermCont1{
	my ($refTerm,$value)=@_;
	my @term=(sort {$a<=>$b} keys %{$refTerm});


	my $len=scalar(@term);
	#my $lastBin=$term[$len-1];
	#if($value>$lastBin)
	my $i=0;
	while($value>$term[$i]){
		$i++;
		if($value>$term[$len-1]){
			return $term[$len-1];
		}
	}
	my $term=$term[$i];

	return $term;
}



























