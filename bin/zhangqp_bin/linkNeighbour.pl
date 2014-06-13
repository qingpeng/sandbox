#!/usr/bin/perl -w

use strict;


die "need 1 param!\n" if (1>@ARGV);

open (IN,"$ARGV[0]") || die;
open (OUT,">out") || die;
open (THROWN,">thrown") || die;

my %out;


my $name;
while (<IN>) {
    chomp;
	unless ($_=~/^\#/) {
	$name=(split(/\s+/))[0];
		if (exists $out{$name}) {
			push @{$out{$name}},$_;
		} else {
			$out{$name}=[$_];
		}
	}
}

close IN;


foreach (keys %out) {
    my $name=$_;
    my @content=@{$out{$_}};
    my @pickedItem=();
    for (my $i=0;$i<@content;$i++) {
	my ($score,$chr,$chrStart,$chrEnd);
#rbdf_15140.y1.abd       236.4   183     441     623     183     91.80   7.4e-58 |chr10       182     609702  609883  |14
	if ($content[$i]=~/\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\|(chr\w+)\s+\d+\s+(\d+)\s+(\d+)\s+\|\d+/) {
	    $score=$1;
	    $chr=$2;
	    $chrStart=$3;
	    $chrEnd=$4;
	}else {die"A!"}
	#print "$content[$i]\n$score----$chr----$chrStart----$chrEnd\n";
	push @pickedItem,"$i\t$score\t$chr\t$chrStart\t$chrEnd";
    }
    # compare and merge
    for (my $i=0;$i<(@pickedItem-1);$i++) {
	next if ($pickedItem[$i]=~/thrown/);
	my @a=split(/\t/,$pickedItem[$i]); 
	#next if (@a==6); #this one is thrown away...
	for (my $j=$i+1;$j<@pickedItem;$j++) {
	    next if ($pickedItem[$j]=~/thrown/);
	    my @b=split(/\t/,$pickedItem[$j]);
	    #next if (@b==6); #this one is thrown away...
	    if ( ($a[2] eq $b[2]) and (	(  ($a[3]-$b[4])<=1000) and (($b[3]-$a[4])<=1000))   ) {
		if ($a[1]>$b[1]) {
		    $pickedItem[$j].="\tthrown!";
		    #print "$name:\t$a[1]>$b[1]\:$a[2]\t$a[3]\t$a[4]---$b[2]\t$b[3]\t$b[4]\n"; 
		}else {
		    $pickedItem[$i].="\tthrown!";
		    #print "$name:\t$a[1]<=$b[1]\:$a[2]\t$a[3]\t$a[4]---$b[2]\t$b[3]\t$b[4]\n";
		}
		#print "found $a[1] vs $b[1]!\n";
	    }
	}
    }
    #comparation finished
    for (my $i=0;$i<@content;$i++) {
	@_=split(/\t/,$pickedItem[$i]);
	if (5==@_) {
	    print OUT "$content[$i]\n";
	} else {
	    print THROWN "$content[$i]\n";
	}

    }
}


close OUT;
close THROWN;
