#!/usr/bin/perl 
#122 finish package
#update: 2002-08-09

if(!defined(@ARGV)) 
{ 
	print   "\n";
	print   "bridge:  0   \$F_phrap_lis  \$F_contig  \$F_all_reads  \$F_marry  \$F_kiss  \$F_candidate  \n";
	print   "kiss:    1   \$infile  \$MinValue_Tolerance  \n";
	print   "marry:   2   \$phrap_lis  \$unassemble_reads  \n";
	print   "\n";
	exit;
}

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] == 0)
{
	#122 finish packasge 2: bridge
	#function: phrap and connect two contigs
	#2002-08-09

	($type,$F_phrap_lis,$F_contig,$F_all_reads,$F_marry,$F_kiss,$F_candidate) = @ARGV;
	
	#open(B,">>bridge.log");
	print "\n################## Bridge begin ######################\n";
	print `date +'Start time: %Y-%m-%d %H:%M:%S'`;
		
	#parameter
	$max_num_reads = 4; #max reads number of contig splited
	$max_length_contig = 1000; #max length of contig splited
	$ter_length = 2000; #length of contig terminal taken to phrap
	$extend_times = 1;

	$path_package = "/snow1/prj11/122/assemble/finish_package/";
	
	%micro_contig = ();
	%terminal = ();
	%bridge = ();
	%marry = ();
	%kiss = ();
	%seq = ();
	%qual = ();
	
	#split micro contig.
	#get contig' terminal
	print "Now split micro contig and get contig' terminal...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(P,$F_phrap_lis) || die;
	{
		while(<P>)
		{
			@temp = split(/\s+/,$_);

			#Contig1.  982 reads; 39600 bp (untrimmed), 39499 (trimmed).  Isolated contig.
			if($temp[0] =~ /^Contig/)
			{
				$micro_flag = 0;
				if($temp[0] eq "Contig") 
				{ 
					$temp[1] = $temp[0].$temp[1];
					shift(@temp);
				}
				$temp[0] =~ s/(\w+)\S+/$1/;
				$temp[0] = &format_name($temp[0]);
				if($temp[0] =~ /^(Contig\d+)/)
				{
					$contig_name = $1;
					$contig_length = $temp[3];
					#relation: OR
					if($temp[3] <= $max_length_contig || $temp[1] <= $max_num_reads) { $micro_flag = 1; }
				} else { die"error 1\n"; }
				next;
			}
			
			#C    68   701 jkyxa0_010144.z1.abd  623 (  0)  0.00 0.32 0.00    0 (  0)    0 (  0) 
			if(@temp > 12 && $temp[1] =~/^\-*\d+$/ && $temp[2] =~/^\-*\d+$/)
			{
				if($temp[3] =~ /^(\w+)\./) 
				{
					if($micro_flag == 1)
					{
						if(defined($micro_contig{$contig_name})) { $micro_contig{$contig_name} .= " $1"; }else { $micro_contig{$contig_name} = $1; }
					}

					if($contig_length <= $ter_length)
					{
						if(defined($terminal{$contig_name."-L"})) { $terminal{$contig_name."-L"} .= " $1"; } else { $terminal{$contig_name."-L"} = $1; }
						if(defined($terminal{$contig_name."-R"})) { $terminal{$contig_name."-R"} .= " $1"; } else { $terminal{$contig_name."-R"} = $1; }
					}
					else
					{
						if($temp[2] < $ter_length) { if(defined($terminal{$contig_name."-L"})) { $terminal{$contig_name."-L"} .= " $1"; } else { $terminal{$contig_name."-L"} = $1; } }
						if($temp[1] > $contig_length - $ter_length) { if(defined($terminal{$contig_name."-R"})) { $terminal{$contig_name."-R"} .= " $1"; } else { $terminal{$contig_name."-R"} = $1; } }
					}
				} else { die"error 2\n"; }
			}
			
		}
	}
	close(P);

	#establish marry connection
	print "Now establish marry connection...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(M,$F_marry) || die;
	while(<M>)
	{
		#Contig1 L rjkyza0_000106 R 32200
		@temp = split(/\s+/,$_);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		if($temp[2] !~ /^Contig/ || ($temp[2] =~/^Contig/ && defined($micro_contig{$temp[2]})))
		{
			if(defined($marry{"$temp[0]-$temp[1]"})) { $marry{"$temp[0]-$temp[1]"} .= " $temp[2]"; }
			else { $marry{"$temp[0]-$temp[1]"} = $temp[2]; }
		}
	}
	close(M);

	#establish kiss connection
	print "Now establish kiss connection...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(K,$F_kiss) || die;
	while(<K>)
	{
		#Contig000001 R jkyza0_001119.z1.abd R 459/460
		@temp = split(/\s+/,$_);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		if(defined($kiss{$temp[0]."-".$temp[1]})) { $kiss{$temp[0]."-".$temp[1]} .= " $temp[2]-$temp[3]"; } 
		else { $kiss{$temp[0]."-".$temp[1]} = "$temp[2]-$temp[3]"; }
	}
	close(K);

	#read seq
	print "Now read sequence...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(A,$F_all_reads) || die;
	while(<A>)
	{
		if(/^>/) 
		{
			$read_name = "";
			if(/^>(\w+)\./)
			{
				$read_name = $1;
				if(defined($seq{$read_name})) { die; } else { $seq{$read_name} = $_; }
			}
		}
		elsif($read_name ne "") { $seq{$read_name} .= $_; }
	}
	close(A);

	#read qual
	print "Now read quality...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(A,"$F_all_reads.qual") || die;
	while(<A>)
	{
		if(/^>/) 
		{
			$read_name = "";
			if(/^>(\w+)\./)
			{
				$read_name = $1;
				if(defined($qual{$read_name})) { die; } else { $qual{$read_name} = $_; }
			}
		}
		elsif($read_name ne "") { $qual{$read_name} .= $_; }
	}
	close(A);
	
	#gain reads for phrap.
	print "\nNow Game begin...\n";
	print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
	open(C,$F_candidate) || die;
	@candidate = <C>;
	close(C);
	foreach $each (@candidate) 
	{
		%bridge = ();

		@temp = split(/\s+/,$each);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		$connection_dir = "$temp[0]-$temp[1]-$temp[2]-$temp[3]";
		if((-e "../high/$temp[2]-$temp[3]-$temp[0]-$temp[1]") || (-e "../high/$temp[0]-$temp[1]-$temp[2]-$temp[3]") || (-e "$temp[2]-$temp[3]-$temp[0]-$temp[1]") || (-e "$temp[0]-$temp[1]-$temp[2]-$temp[3]")) 
		{
			next;

			chdir"./$connection_dir/" || die;

			system"perl $path_package/EblastN.pl -i bridge.seq.contigs.blast -o bridge.seq.contigs.blast.out -a 98 -l 100";
			system"perl $path_package/finish_package.pl 1 bridge.seq.contigs.blast.out 50";
			$space = " ";
			system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" > bridge.kiss";
			system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";
			$temp[0] = &standard_contigs($temp[0]);
			$temp[2] = &standard_contigs($temp[2]);
			system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" >> bridge.kiss";
			system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";

			chdir"../"; 
		}

		system"mkdir $connection_dir";
		print "Now $connection_dir\n";
		print `date +'Now time: %Y-%m-%d %H:%M:%S'`;
		for($i=0;$i<3;$i++)
		{
			$contig = $temp[$i];
			$direct = $temp[$i+1];

			#get reads from marry
			if(defined($marry{"$contig-$direct"}))
			{
				@temp1 = split(/\s+/,$marry{"$contig-$direct"});
				foreach $each1 (@temp1) 
				{
					if($each1 =~ /^Contig/)
					{
						foreach $each2 (split(/\s+/,$micro_contig{$each1}))
						{
							$bridge{$each2} = 1;
						}
					}
					else { $bridge{$each1} = 1; }
				}
			}

			#get reads from Contig's terminal
			if(defined($terminal{"$contig-$direct"}))
			{
				@temp1 = split(/\s+/,$terminal{"$contig-$direct"});
				foreach $each1 (@temp1) 
				{
					$bridge{$each1} = 1;
				}
			}

			#get kiss reads
			@seed = ($contig."-".$direct);
			@new_seed = ();
			for($j=0;$j<$extend_times;$j++)
			{
				foreach $each1 (@seed) 
				{
					if(defined($kiss{$each1}))
					{
						@temp1 = split(/\s+/,$kiss{$each1});
						foreach $each2 (@temp1) 
						{
							($name,$name_direct) = &LR($each2);

							if($name =~ /^Contig/ && defined($micro_contig{$name}))
							{
								foreach $each2 (split(/\s+/,$micro_contig{$name}))
								{
									$bridge{$each2} = 1;
								}
							}
							elsif($name !~ /Contig/) 
							{ 
								$bridge{$name} = 1;
								@temp2 = &LR($name_direct);
								if($temp2[0] !~ /Contig/) { push(@new_seed,$temp2[1]); }
							}
						}
					}
				}

				@seed = @new_seed;
			}	
		}
		
		#phrap in dir:"./$connection_dir"
		
		#out bridge.list
		#open(O,">$connection_dir/bridge.list");
		#foreach $each1 (keys %bridge) 
		#{
		#	print O "$each1 $bridge{$each1}\n";
		#}
		#close(O);

		#out bridge.seq bridge.seq.qual
		open(S,">$connection_dir/bridge.seq");
		open(Q,">$connection_dir/bridge.seq.qual");
		foreach $each1 (keys %bridge) 
		{
			print S $seq{$each1};
			print Q $qual{$each1};
		}
		close(S);
		close(Q);

		chdir"./$connection_dir/";

		system"phrap bridge.seq -new_ace > phrap.out";
		system"phraplist phrap.out > phrap.lis";
		print "$F_contig\n";
		system"blastall -i bridge.seq.contigs -o bridge.seq.contigs.blast -e 1e-20 -p blastn -d $F_contig -F F -v 10000 -b 10000";
		system"perl $path_package/EblastN.pl -i bridge.seq.contigs.blast -o bridge.seq.contigs.blast.out -a 98 -l 100";
		system"perl $path_package/finish_package.pl 1 bridge.seq.contigs.blast.out 50";
		$space = " ";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" > bridge.kiss";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";
		$temp[0] = &standard_contigs($temp[0]);
		$temp[2] = &standard_contigs($temp[2]);
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" >> bridge.kiss";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";

		chdir"../";		
	}

	print "Now Game over\n";
	print `date +'End time: %Y-%m-%d %H:%M:%S'`;
	print "################################################\n";
	#close(B);

	sub format_name
	{
		my($temp) = @_;
		if($temp =~ /^(Contig)0*(\d+)$/) { return($1.$2); } elsif($temp =~ /^(\w+)\S*$/) { return($1); } else { die"error 3: $temp\n"; }
	}

	sub standard_contigs
	{
		my($temp) = @_;
		if($temp =~ /^Contig0+\d+$/) { return($temp); } 
		elsif($temp =~ /^Contig(\d+)$/) 
		{
			my $mid = "";
			for (my $i=0;$i<6-length($1);$i++) 
			{
				$mid .= "0";
			}
			return("Contig".$mid.$1); 
		} 
		else { die"error 4\n"; }
	}

	sub LR
	{
		my($temp) = @_; 
		my(@temp) = split(/\-/,$temp);
		if($temp[1] eq "R") { $temp[1] = "L"; } elsif($temp[1] eq "L") { $temp[1] = "R"; } else { die"error 5: $temp\n"; }
		return($temp[0],$temp[0]."-".$temp[1]);
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] == 0.5)
{
	#122 finish packasge 2
	#function: phrap and connect two contigs
	#2002-08-09

	($type,$F_phrap_lis,$F_contig,$F_all_reads,$F_marry,$F_kiss,$F_candidate) = @ARGV;
		
	#parameter
	$max_num_reads = 4; #max reads number of contig splited
	$max_length_contig = 1000; #max length of contig splited
	$ter_length = 1000; #length of contig terminal taken to phrap
	$extend_times = 3;

	$path_package = "/snow1/prj11/122/assemble/finish_package/";
	
	%micro_contig = ();
	%terminal = ();
	%bridge = ();
	%marry = ();
	%kiss = ();
	
	#split micro contig.
	#get contig' terminal
	open(P,$F_phrap_lis) || die;
	{
		while(<P>)
		{
			@temp = split(/\s+/,$_);

			#Contig1.  982 reads; 39600 bp (untrimmed), 39499 (trimmed).  Isolated contig.
			if($temp[0] =~ /^Contig/)
			{
				$temp[0] = &format_name($temp[0]);
				$micro_flag = 0;
				if($temp[0] eq "Contig") 
				{ 
					$temp[1] = $temp[0].$temp[1];
					shift(@temp);
				}
				if($temp[0] =~ /^(Contig\d+)/)
				{
					$contig_name = $1;
					$contig_length = $temp[3];
					#relation: OR
					if($temp[3] <= $max_length_contig || $temp[1] <= $max_num_reads) { $micro_flag = 1; }
				} else { die"error 1\n"; }
				next;
			}
			
			#C    68   701 jkyxa0_010144.z1.abd  623 (  0)  0.00 0.32 0.00    0 (  0)    0 (  0) 
			if(@temp > 12 && $temp[1] =~/^\-*\d+$/ && $temp[2] =~/^\-*\d+$/)
			{
				if($temp[3] =~ /^(\w+)\./) 
				{
					if($micro_flag == 1)
					{
						if(defined($micro_contig{$contig_name})) { $micro_contig{$contig_name} .= " $1"; }else { $micro_contig{$contig_name} = $1; }
					}

					if($contig_length <= $ter_length)
					{
						if(defined($terminal{$contig_name."-L"})) { $terminal{$contig_name."-L"} .= " $1"; } else { $terminal{$contig_name."-L"} = $1; }
						if(defined($terminal{$contig_name."-R"})) { $terminal{$contig_name."-R"} .= " $1"; } else { $terminal{$contig_name."-R"} = $1; }
					}
					else
					{
						if($temp[2] < $ter_length) { if(defined($terminal{$contig_name."-L"})) { $terminal{$contig_name."-L"} .= " $1"; } else { $terminal{$contig_name."-L"} = $1; } }
						if($temp[1] > $contig_length - $ter_length) { if(defined($terminal{$contig_name."-R"})) { $terminal{$contig_name."-R"} .= " $1"; } else { $terminal{$contig_name."-R"} = $1; } }
					}
				} else { die"error 2\n"; }
			}
			
		}
	}
	close(P);

	#establish marry connection
	open(M,$F_marry) || die;
	while(<M>)
	{
		#Contig1 L rjkyza0_000106 R 32200
		@temp = split(/\s+/,$_);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		if($temp[2] !~ /^Contig/ || ($temp[2] =~/^Contig/ && defined($micro_contig{$temp[2]})))
		{
			if(defined($marry{"$temp[0]-$temp[1]"})) { $marry{"$temp[0]-$temp[1]"} .= " $temp[2]"; }
			else { $marry{"$temp[0]-$temp[1]"} = $temp[2]; }
		}
	}
	close(M);

	#establish kiss connection
	open(K,$F_kiss) || die;
	while(<K>)
	{
		#Contig000001 R jkyza0_001119.z1.abd R 459/460
		@temp = split(/\s+/,$_);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		if(defined($kiss{$temp[0]."-".$temp[1]})) { $kiss{$temp[0]."-".$temp[1]} .= " $temp[2]-$temp[3]"; } 
		else { $kiss{$temp[0]."-".$temp[1]} = "$temp[2]-$temp[3]"; }
	}
	close(K);
	
	#gain reads for phrap.
	open(C,$F_candidate) || die;
	@candidate = <C>;
	close(C);
	foreach $each (@candidate) 
	{
		%bridge = ();

		@temp = split(/\s+/,$each);
		$temp[0] = &format_name($temp[0]);
		$temp[2] = &format_name($temp[2]);
		$connection_dir = "$temp[0]-$temp[1]-$temp[2]-$temp[3]";
		system"mkdir $connection_dir";
		for($i=0;$i<3;$i++)
		{
			$contig = $temp[$i];
			$direct = $temp[$i+1];

			#get reads from marry
			if(defined($marry{"$contig-$direct"}))
			{
				@temp1 = split(/\s+/,$marry{"$contig-$direct"});
				foreach $each1 (@temp1) 
				{
					if($each1 =~ /^Contig/)
					{
						foreach $each2 (split(/\s+/,$micro_contig{$each1}))
						{
							if(defined($bridge{$each2})) { $bridge{$each2} .= " m$each1"; } else { $bridge{$each2} = "m$each1"; }
						}
					}
					else { if(defined($bridge{$each1})) { $bridge{$each1} .= " m"; } else { $bridge{$each1} = "m"; } }
				}
			}

			#get reads from Contig's terminal
			if(defined($terminal{"$contig-$direct"}))
			{
				@temp1 = split(/\s+/,$terminal{"$contig-$direct"});
				foreach $each1 (@temp1) 
				{
					if(defined($bridge{$each1})) { $bridge{$each1} .= " t$contig"; } else { $bridge{$each1} = "t$contig"; }
				}
			}

			#get kiss reads
			@seed = ($contig."-".$direct);
			@new_seed = ();
			for($j=0;$j<$extend_times;$j++)
			{
				foreach $each1 (@seed) 
				{
					if(defined($kiss{$each1}))
					{
						@temp1 = split(/\s+/,$kiss{$each1});
						foreach $each2 (@temp1) 
						{
							($name,$name_direct) = &LR($each2);

							if($name =~ /^Contig/ && defined($micro_contig{$name}))
							{
								foreach $each2 (split(/\s+/,$micro_contig{$name}))
								{
									if(defined($bridge{$each2})) { $bridge{$each2} .= " k$name"; } else { $bridge{$each2} = "k$name"; }
								}
							}
							elsif($name !~ /Contig/) 
							{ 
								if(defined($bridge{$name})) { $bridge{$name} .= " k$each1"; } else { $bridge{$name} = "k$each1"; }
								@temp2 = &LR($name_direct);
								if($temp2[0] !~ /Contig/) { push(@new_seed,$temp2[1]); }
							}
						}
					}
				}

				@seed = @new_seed;
			}	
		}
		
		#phrap in dir:"./$connection_dir"
		
		#out bridge.list
		#open(O,">$connection_dir/bridge.list");
		#foreach $each1 (keys %bridge) 
		#{
		#	print O "$each1 $bridge{$each1}\n";
		#}
		#close(O);

		#out bridge.seq
		open(A,$F_all_reads) || die;
		open(O,">$connection_dir/bridge.seq");
		while(<A>)
		{
			if(/^>/) { $seq_flag = 0; }
			if(/^>(\w+)\./) 
			{
				if(defined($bridge{$1})) { $seq_flag = 1; }
			}
			if($seq_flag == 1) { print O; }
		}
		close(O);
		close(A);

		#out bridge.seq.qual
		open(A,"$F_all_reads.qual") || die;
		open(O,">$connection_dir/bridge.seq.qual");
		while(<A>)
		{
			if(/^>/) { $seq_flag = 0; }
			if(/^>(\w+)\./) 
			{ 
				if(defined($bridge{$1})) { $seq_flag = 1; }
			}
			if($seq_flag == 1) { print O; }
		}
		close(O);
		close(A);

		chdir"./$connection_dir/";

		system"phrap bridge.seq -new_ace > phrap.out";
		system"phraplist phrap.out > phrap.lis";
		print "$F_contig\n";
		system"blastall -i bridge.seq.contigs -o bridge.seq.contigs.blast -e 1e-20 -p blastn -d $F_contig -F F -v 10000 -b 10000";
		system"perl $path_package/EblastN.pl -i bridge.seq.contigs.blast -o bridge.seq.contigs.blast.out -a 98 -l 50";
		system"perl $path_package/finish_package.pl 1 bridge.seq.contigs.blast.out";
		$space = " ";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" > bridge.kiss";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";
		$temp[0] = &standard_contigs($temp[0]);
		$temp[2] = &standard_contigs($temp[2]);
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[0]$space$temp[1]\" >> bridge.kiss";
		system"more bridge.seq.contigs.blast.out.kiss | grep \"$space$temp[2]$space$temp[3]\" >> bridge.kiss";

		chdir"../";		
	}

	sub Zformat_name
	{
		my($temp) = @_;
		if($temp =~ /^(Contig)0*(\d+)$/) { return($1.$2); } elsif($temp =~ /^(\w+)\S*$/) { return($1); } else { die"error 3: $temp\n"; }
	}

	sub Zstandard_contigs
	{
		my($temp) = @_;
		if($temp =~ /^Contig0+\d+$/) { return($temp); } 
		elsif($temp =~ /^Contig(\d+)$/) 
		{
			my $mid = "";
			for (my $i=0;$i<6-length($1);$i++) 
			{
				$mid .= "0";
			}
			return("Contig".$mid.$1); 
		} 
		else { die"error 4\n"; }
	}

	sub ZLR
	{
		my($temp) = @_; 
		my(@temp) = split(/\-/,$temp);
		if($temp[1] eq "R") { $temp[1] = "L"; } elsif($temp[1] eq "L") { $temp[1] = "R"; } else { die"error 5: $temp\n"; }
		return($temp[0],$temp[0]."-".$temp[1]);
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] == 1)
{
	#122
	#function: abstract eligible extend pairs from blast.out by Eblast.pl
	#product: kiss
	#2002-08-06

	($type,$infile,$MinValue_Tolerance) = @ARGV;
	if(!defined($MinValue_Tolerance)) { $MinValue_Tolerance = 10; }
	
	open(IN,$infile);
	open(OUT,">$infile.kiss");
	<IN>;
	while(<IN>)
	{
		@temp = split(/\s+/,$_);
		if($temp[0] eq "") { shift(@temp); }
		$Q_N = $temp[0];
		$Q_L = $temp[1];
		$Q_B = $temp[2];
		$Q_E = $temp[3];
		$S_N = $temp[11];
		$S_L = $temp[6];
		$S_B = $temp[4];
		$S_E = $temp[5];
		$overlap = $temp[9];

		if($Q_N ne $S_N)
		{
			#Q L
			if($Q_B - 1 <= $MinValue_Tolerance)
			{
				if($S_B < $S_E && $S_L - $S_E <= $MinValue_Tolerance)
				{
					#S R
					print OUT "$Q_N L $S_N R $overlap\n";
				}
				elsif($S_B > $S_E && $S_E - 1 <= $MinValue_Tolerance)
				{
					#S L
					print OUT "$Q_N L $S_N L $overlap\n";
				}
			}
			#S R
			if($Q_L - $Q_E <= $MinValue_Tolerance)
			{
				if(($S_B < $S_E && $S_B - 1 <= $MinValue_Tolerance) || ())
				{
					#S L
					print OUT "$Q_N R $S_N L $overlap\n";
				}
				elsif($S_B > $S_E && $S_L - $S_B <= $MinValue_Tolerance)
				{
					#S R
					print OUT "$Q_N R $S_N R $overlap\n";
				}
			}

			if($Q_B - 1 <= $MinValue_Tolerance && $Q_L - $Q_E <= $MinValue_Tolerance)
			{
				#Q IN S
				print OUT "$Q_N IN $S_N $overlap\n";
			}
		}
	}
	close(IN);

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if($ARGV[0] == 2)
{
	#122 finish packasge 1
	#function: search zf connection from phrap.lis and unassemble.reads
	#product: marry
	#2002-08-07
	#update: 2002-08-09
	#update: 2002-08-20

	($type,$phrap_lis,$unassemble_reads,$self) = @ARGV;
	if(!defined($self) && defined($unassemble_reads) && $unassemble_reads =~ /^[RIC]/) { $self = $unassemble_reads; undef($unassemble_reads); }
	if(defined($unassemble_reads))
	{
		open(U,$unassemble_reads);
		while(<U>)
		{
			if(/^>(\w+)/) { $unassemble{$1} = 0; }
		}
		close(U);
	}

	open(P,$phrap_lis);
	while(<P>)
	{
		@temp = ();
		@temp = split(/\s+/,$_);

		if($temp[0] =~ /^Contig/)
		{
			if($temp[0] eq "Contig") 
			{ 
				chop($temp[1]);
				$contig_name = "Contig".$temp[1];
				$contig_length = $temp[4];
			}
			elsif($temp[0] =~ /^(Contig\d+)/)
			{
				$contig_name = $1;
				$contig_length = $temp[3];
			}
			next;
		}

		if(@temp > 10 && $temp[1] =~/^\-*\d+$/ && $temp[2] =~/^\-*\d+$/)
		{
			if($temp[0] eq "C") { $temp[0] = "L"; } else { $temp[0] = "R"; }
			if($temp[3] =~ /^(\w+)\./) { $reads = $1; } else { next; }
			if($temp[1] < 1) { $temp[1] = 1; }
			if($temp[2] > $contig_length) { $temp[2] = $contig_length; }
			#if(defined($structure{$reads})) { die"error: $reads 425\n"; }
			$structure{$reads}=
			{
				direct=>$temp[0],
				begin=>$temp[1],
				end=>$temp[2],
				contigname=>$contig_name,
				contiglength=>$contig_length
			};
			#if(defined($structure{$reads})) { print "$structure{$reads}->{contigname}\n"; }
		}
	}
	close(P);

	open(P,$phrap_lis);
	$flag = 0;
	while(<P>)
	{
		@temp = ();
		@temp = split(/\s+/,$_);

		if($temp[0] =~ /^Contig/)
		{
			if($flag == 1)
			{
				foreach $each (sort {$a cmp $b} @singlets) 
				{
					print $each;
				}

				foreach	$each (sort {$a cmp $b} keys %partner)
				{
					@taiji = split(/\s+/,$partner{$each});
					$yuedui = @taiji;
					print "$each $yuedui: $partner{$each}\n";
				}

				$flag = 0;
				@singlets = ();
				%partner = ();
			}
			next;
		}

		if(@temp > 10 && $temp[1] =~/^\-*\d+$/ && $temp[2] =~/^\-*\d+$/)
		{
			if($temp[3] =~ /^(\w+)\./) 
			{ 
				$reads = $1;
				$creads = &complement($reads);
			} else { next; }

			if(defined($unassemble{$creads}))
			{
				$flag = 1;
				if($structure{$reads}->{direct} eq "L") 
				{
					$size = $structure{$reads}->{end};
				}
				elsif($structure{$reads}->{direct} eq "R") 
				{ 
					$size = $structure{$reads}->{contiglength} - $structure{$reads}->{begin};
				} else { die"error: 497\n"; }
				
				push(@singlets,"$structure{$reads}->{contigname} $structure{$reads}->{direct} $creads R $size\n");
				next;
			}

			if(defined($structure{$creads}) && $structure{$creads}->{contigname} ne $structure{$reads}->{contigname})
			{
				$flag = 1;
				if($structure{$reads}->{direct} eq "L") { $boy_l = $structure{$reads}->{end}; } 
				else { $boy_l = $structure{$reads}->{contiglength} - $structure{$reads}->{begin}; }
				if($structure{$creads}->{direct} eq "L") { $girl_l = $structure{$creads}->{end}; } 
				else { $girl_l = $structure{$creads}->{contiglength} - $structure{$creads}->{begin}; }
				$k = "$structure{$reads}->{contigname} $structure{$reads}->{direct} $structure{$creads}->{contigname} $structure{$creads}->{direct}";
				$size = $boy_l + $girl_l;
				
				if($self =~ /C/)
				{
					if($reads =~ /^r/) { $clone = $creads; } else { $clone = $reads; } 
					if(defined($partner{$k})) { $partner{$k} .= " $size=$clone"; } else { $partner{$k} = "$size=$clone"; }
				}
				else 
				{ 
					if(defined($partner{$k})) { $partner{$k} .= " $size"; } else { $partner{$k} = $size; }
				}
				next;
			}

			#circle contigs.
			if(defined($self) && defined($structure{$creads}) && $structure{$creads}->{contigname} eq $structure{$reads}->{contigname})
			{
				if($structure{$reads}->{direct} eq "R" && $structure{$creads}->{direct} eq "L") { $R = $reads; $L = $creads; }
				elsif($structure{$creads}->{direct} eq "R" && $structure{$reads}->{direct} eq "L") { $R = $creads; $L = $reads; }
				else { next; }

				if($self =~ /R/ && $structure{$R}->{begin} > $structure{$L}->{end}) 
				{
					$size = $structure{$L}->{end} + $structure{$L}->{contiglength} - $structure{$R}->{begin};
					$k = "Ring $structure{$L}->{contigname}";
					
					if($self =~ /C/)
					{
						if($reads =~ /^r/) { $clone = $creads; } else { $clone = $reads; } 
						if(defined($partner{$k})) { $partner{$k} .= " $size=$clone"; } else { $partner{$k} = "$size=$clone"; }
					}
					else 
					{ 
						if(defined($partner{$k})) { $partner{$k} .= " $size"; } else { $partner{$k} = $size; }
					}
				}
				elsif($self =~ /I/ && $structure{$R}->{begin} < $structure{$L}->{end})
				{
					$size = $structure{$L}->{end} - $structure{$R}->{begin};
					$k = "In $structure{$L}->{contigname}";

					if($self =~ /C/)
					{
						if($reads =~ /^r/) { $clone = $creads; } else { $clone = $reads; } 
						if(defined($partner{$k})) { $partner{$k} .= " $size=$clone"; } else { $partner{$k} = "$size=$clone"; }
					}
					else 
					{ 
						if(defined($partner{$k})) { $partner{$k} .= " $size"; } else { $partner{$k} = $size; }
					}
				}
			}
		}
	}
	#last one output
	if($flag == 1)
	{
		foreach $each (sort {$a cmp $b} @singlets) 
		{
			print $each;
		}

		foreach	$each (sort {$a cmp $b} keys %partner)
		{
			@taiji = split(/\s+/,$partner{$each});
			$yuedui = @taiji;				
			print "$each $yuedui: $partner{$each}\n";
		}

		$flag = 0;
		@singlets = ();
		%partner = ();
	}

	close(P);

	sub complement
	{
		my($forward) = @_;
		my($reverse) = "";
		if($forward =~ /^r(\S+)/) { $reverse = $1; } else { $reverse = "r".$forward; }
		return($reverse);
	}

	exit;
}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
