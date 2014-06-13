#!/usr/bin/perl -w
# extract reads and human genome segments in pairs. 
# ready for the blastz alignment
#
#
#


use strict;
use Getopt::Std;

my %opts;
getopts("i:o:r:g:d:hv",\%opts);
my $perlInfoAuth="LIu TAo";
my $perlInfoVer="1.2";
my $perlInfoEmail="liut\@genomics\.org\.cn";
my $perlInfoLastModified="Today";
my $perlInfoUsage=<<"Usage";
$0: extract reads and human genome segments in pairs.
Need paras:
    <-i <filename>> Input location file
    <-o <filename>> Ouput directory
    <-r <filename>> Input integrated reads file 
    <-g <dirname>>  Input human genome directory(file name: chr??.fa)
    <-d <a,b,c,d,e,f>>  four fields in the list file(read_name,start,end,chromosome_name,start,end)
    [-h]          help
    [-v]          version
Note: fields begin from 1, not 0.

$perlInfoAuth made this program at $perlInfoLastModified version $perlInfoVer
Report bugs to $perlInfoEmail 
Usage

die "$perlInfoUsage" if (exists $opts{"h"});

die "$perlInfoVer\n" if (exists $opts{"v"});

die "Error: need paras\n$0 -h for help\n" unless ($opts{"i"} and $opts{"o"} and $opts{"r"} and $opts{"g"} and $opts{"d"} and exists $opts{"d"});

my $locationFile=$opts{"i"};
my $outDir=$opts{"o"};
my $readFile=$opts{"r"};
my $humanDir=$opts{"g"};
my $fields=$opts{"d"};

my @fields=split(/,/,$fields);

die "Error: -d must be followed by six digits seperated by comma!\n$0 -h for help\n" if (6!=@fields);

############################

#read the location file
print "Process1: read $locationFile...\n";
my @location; # store the location info about region from where to where is aligned to human chromosome from where to where.   

my %list; # store the read name 

open (LIST,"$locationFile") || die "$!";
while (<LIST>) {
    next if (/^\#/);
    my ($readName,$readStart,$readEnd,$chrName,$chrStart,$chrEnd)=(split(/\s+/,$_))[$fields[0]-1,$fields[1]-1,$fields[2]-1,$fields[3]-1,$fields[4]-1,$fields[5]-1];
    $chrName=~s/.*(chr\S+)/$1/;
    my %item=('rn'=>$readName,'rs'=>$readStart,'re'=>$readEnd,'cn'=>$chrName,'cs'=>$chrStart,'ce'=>$chrEnd);
    push @location,\%item;
    $list{$readName} = 0;
}
close LIST;
print "Process1: finished!\n";
#read over
#test
#for (my $i=0;$i<@location;$i++) {
#    my %item=%{$location[$i]};
#    print "$item{rn},$item{rs},$item{re}---$item{cn},$item{cs},$item{ce}\n";
#}
#test over

#read reads file

print "Process2: read $readFile... \*it will takes a considerable long time.\n";
my %readSeq; #store the read sequences
my %duplicateReads; #some duplicate reads are in the pig genome reads
$/="\>";

open(READ,"$readFile") || die;
<READ>;
while (<READ>) {
   chomp;
   s/^(\S+).*\n(.*)/$2/;
   if (exists $readSeq{$1}) {$duplicateReads{$1}=1;}
   $readSeq{$1}=uc $_;
}

close READ;
$/="\n";
print "Process2: finished!\n";

#read over
#test read
#foreach (keys %readSeq) {
#    print "\>$_\n$readSeq{$_}";
#}

#test over

#calculate and make dirs
print "Process3: Create directories...\n";
my $numberOfDirs;
$numberOfDirs=@location;
{
    my $dirNum=int $numberOfDirs/1000;
    my $lastSubdirNum=$numberOfDirs-$dirNum*1000;
    mkdir $outDir,0777;
    for (my $i=0;$i<$dirNum;$i++) {
	mkdir "$outDir/$i",0777;
	for (my $j=1;$j<=1000;$j++) {
	    mkdir "$outDir/$i/$j",0777;
	}
    }
    mkdir "$outDir/$dirNum",0777;
    for (my $j=1;$j<=$lastSubdirNum;$j++) {
	mkdir "$outDir/$dirNum/$j",0777;
    }
}
print "Process3: finished!\n";

#arrange data

my %homoChr=(); # human chromosome sequence

open (LOG,">log")|| die "$!";

print "Process4: arrange data...\n";
for (my $i=0;$i<@location;$i++) {
    my $pathName="$outDir/".(int $i/1000)."/".($i-(int $i/1000)*1000+1);
    my %item=%{$location[$i]};
    open (READSEQ,">$pathName/read.fa") || die "$!"; # picked out sequence from pig genome
    print READSEQ "\>$item{rn}\_\_",++$list{$item{rn}},"\n$readSeq{$item{rn}}"; 
    #
    # add a mark to the read name to indicate it's order
    # when a read occured in the first time:
    # >original_name__1
    # ATCG...
    # then second time:
    # >original_name__2
    # ATCG...
    # althrough the sequence itself is unchanged.
    #
    print LOG ">write $pathName/read.fa\n";
    if (exists $duplicateReads{$item{rn}}) {warn "Warning: duplicate reads: $item{rn}\n";}
    close READSEQ;
    #homo genome fasta file
    if (not exists $homoChr{$item{'cn'}}){
	open (CHRFILE,"$humanDir/$item{cn}\.fa") || die "$!";
	<CHRFILE>;
	undef $/;
	$homoChr{$item{'cn'}}=<CHRFILE>;
	$homoChr{$item{'cn'}}=~s/\n//g;
	$/="\n";
    }
    open (HOMO,">$pathName/homo.fa") || die "$!";
    my $from=$item{'cs'}-1000;
    my $to=$item{'ce'}+1000;
    print HOMO "\>$item{cn}_$item{cs}_$item{ce}\t$from to $to\n";
    my $seq=uc(substr $homoChr{$item{'cn'}},$from-1,$to-$from+1);
    print HOMO "$seq\n";
    close HOMO;
    print LOG ">write $pathName/homo.fa\n";
}
print "Process4: finished!\n";
#arrangement complete!



print "All done! check $outDir\n";

