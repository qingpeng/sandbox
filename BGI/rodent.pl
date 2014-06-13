#!/usr/local/bin/perl -w

%do = qw(BGLII 1 CYRA11_MM 1 MERVL 1 MERVL_LTR 1 MMAR1 1 MMERGLN 1 MMETn 1 MMTV 1 MMURS 1 MMURS4 1 MMVL30 1 MULV 1 MURVY 1 MYSERV 1 MYSPL 1 MYS_LTR 1 RAL_RN 1 RCHARR1 1 RLTR14 1 RMER1A 1 RMER1B 1 RMER1C 1 RMER21A 1 RMER21B 1 RMER30 1 SRV_MM 1 URR1A 1 URR1B 1 YREP_MM 1);

foreach $file (@ARGV) {
    open (IN, $file);
    ($outfile = $file) .= ".rodspec";
    open (OUT, ">$outfile");
    while (<IN>) {
	@bit = split;
	next if !$bit[10] || $bit[10] eq 'Low_complexity' || $bit[10] eq 'Simple_repeat';
	if ($bit[10] =~ /^SINE/) { 
	    print OUT unless $bit[10] eq 'SINE/MIR';
	} elsif ($bit[10] =~ /^LINE/) {
	    if ($bit[10] eq 'LINE/L1') {
		if ($bit[9] !~ /^L1M[^d]|^HAL1/ &&
		    $bit[9] eq 'L1' && $bit[1] <= 28) {	# L1MA6-10 are on average 28% diverged in mouse
		    print OUT;
		}
	    }
	} elsif ($bit[10] =~ /^LTR/) {
	    if ($bit[10] eq 'LTR/MaLR') {
		print OUT unless $bit[9] =~ /^MLT/;
	    } elsif ($bit[9] =~ /^RLTR|^RMER|^IAP|^ETn|^LTRIS/) {
		print OUT;
	    } else {
		$bit[9] =~ s/-int//;
		print OUT if $do{$bit[9]};
	    }
	} elsif ($do{$bit[9]} || $bit[10] =~ /^Satellite/) {
	    print OUT; 
	} elsif ($bit[10] =~ /RNA/ && $bit[1] < 25) {
	    print OUT;   
	}
    }
    close OUT;
    close IN;
}


