#!/usr/bin/perl -w

use strict;

die "Choose two items from blastz result.\nFirst pick out alignment/reads length>75% hits, then in order their original order in blastall.\nneed 1 para: $0 <filename>\n" if @ARGV!=1;

open ( IN,"< $ARGV[0]" ) || die "cannot open $ARGV[0]:$!\n" ;

#Query  Subject Q_len   S_len   Score   Direction       Q_X     Q_Y     S_X     S_Y     Length  Overlap Gap     Identity
#
#BD_48061.z1.abd.ADD2093__1      chr7_128149148_128149291_128148148_to_128150291 685     2144    17986   -       363     669        889     1191    307     247     5       80.5
#BD_48061.z1.abd.ADD2093__2      chr6_50912050_50912204_50911050_to_50913204     685     2155    20253   -       291     643        999     1349    353     284     4       80.5
#BD_48061.z1.abd.ADD2093__3      chr7_128151243_128151314_128150243_to_128152314 685     2072    6342    -       290     365        1001    1076    76      70      0       92.1
#BD_48061.z1.abd.ADD2093__4      chrX_112387594_112387737_112386594_to_112388737 685     2144    22439   -       290     684        1001    1394    395     310     3       78.5
#BD_48061.z1.abd.ADD2093__5      chr6_79546300_79546359_79545300_to_79547359     685     2060    13390   +       5       276        891     1154    272     209     11      76.8
#
#
#
my $comment = "# processed by choseTwo.pl\n# Query  Subject Q_len   S_len   Score   Direction       Q_X     Q_Y     S_X     S_Y     Length  Overlap Gap     Identit\n";

my %hitshash;
my $threshold=0.75;

while (<IN>) {
    # bypass ^# lines
    next if (/^\#/);
    
    # read into hash, throw away <75% ones
    my @line = split /\s+/,$_;
    die "check this line, not enough fields:\n$_\n" if @line != 14;
    
    #  throw away <75% ones
    my $coverage = ( abs($line[7]-$line[6])+1 )/$line[2];
    next if ( $coverage < $threshold );
    
    if ( $line[0]=~/^(.*?)\_\_(\d)$/ ) {
	#  Query  Subject Q_len   S_len   Score   Direction       Q_X     Q_Y     S_X     S_Y     Length  Overlap Gap     Identity	
	${$hitshash{$1}}{$2}={all=>"$_",query=>"$1",order=>"$2",subject=>"$line[1]",qlen=>"$line[2]",
			      slen=>"$line[3]",score=>"$line[4]",direction=>"$line[5]",qx=>"$line[6]",
			      qy=>"$line[7]",sx=>"$line[8]",sy=>"$line[9]",length=>"$line[10]",
			      overlap=>"$line[11]",gap=>"$line[12]",identity=>"$line[13]",
			      coverage=>$coverage};
    } else {
	die "check this line, wrong first field:\n$_\n";
    }
}

close IN;

# choose first two from the hash
my $maxChoice=2;

# print sth with tab as the seperator
sub printtab {
    my $line = join "\t",@_;
    print $line,"\n";
}

print $comment;

foreach my $read (sort keys %hitshash) {    # every query read
    my $count = 0;
    foreach my $order (sort {$a <=> $b} keys %{$hitshash{$read}}) {    # every hits of the read
	printtab ($hitshash{$read}->{$order}->{query},$hitshash{$read}->{$order}->{subject},
		  $hitshash{$read}->{$order}->{qlen},$hitshash{$read}->{$order}->{slen},
		  $hitshash{$read}->{$order}->{score},$hitshash{$read}->{$order}->{direction},
		  $hitshash{$read}->{$order}->{qx},$hitshash{$read}->{$order}->{qy},
		  $hitshash{$read}->{$order}->{sx},$hitshash{$read}->{$order}->{sy},
		  $hitshash{$read}->{$order}->{length},$hitshash{$read}->{$order}->{overlap},
		  $hitshash{$read}->{$order}->{gap},$hitshash{$read}->{$order}->{identity});
	$count ++;
	last if ($count == $maxChoice);
    }    
}
