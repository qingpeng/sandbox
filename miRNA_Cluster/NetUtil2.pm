##############################################################################
# This is a collection of functions generate various random, hierachial, multiscale
# or scalefree networks, and# summerize topological properties of the networks
# author: Jackie Han
# created on March 12, 2004
####################################################################

use strict;
#use OLS;
#use Statistics::Distributions;
use CommonUtil2;


############################################################################
## loadEdgeAndNodeLists
############################################################################
sub loadEdgeAndNodeLists {
  my $refgraphEdges = shift;
  my $refgraphNodeDegs = shift;
  #my %randomGraphEdges = %$refgraphEdges;  # this would not keep the pointer, as it capture the value to a new variable
  #my %randomGraphNodeDegs = %$refgraphNodeDegs;
  my $i=shift;
  my $j=shift;
  my $mark=shift;
  my $edgeAttr=shift;
  my $loaded=0;
  my $isNewNode=0;


  if (!$mark) {
    $mark=0;
  }

  if (!$edgeAttr) {
    $edgeAttr=1;
  }


  if ((!$i) || (!$j) || exists $refgraphEdges->{"$i|$j"} || exists $refgraphEdges->{"$j|$i"}) { # collapse a-b/b-a, so is homodimer
    return ($loaded, $isNewNode);
  }

  $refgraphEdges->{"$i|$j"}=$edgeAttr;  # only this way, we can keep the pointer and get the original variable modified

  #if (exists $randomGraphNodeDegs{$i}) { #wrong
  if (exists $refgraphNodeDegs->{$i}) {
    #print "11. node $i\n";
    #push @{$randomGraphNodeDegs{$i}}, $j; #wrong
    push @{$refgraphNodeDegs->{$i}}, $j;
  }
  else {
    #print "12. node $i\n";
    my @partners;
    push @partners,$j;
    #$randomGraphNodeDegs{$i}=\@partners; #wrong
    $refgraphNodeDegs->{$i}=\@partners;
    $isNewNode=1;
  }

  $loaded=1;

  if ($i eq $j) {  # homodimer is added once
    return ($loaded,$isNewNode);
  }

  if ($mark==0) {

  #if (exists $randomGraphNodeDegs{"$j"}) { #wrong
  if ((exists $refgraphNodeDegs->{$j}) ) {
    #print "21. node $j\n";
    #push @{$randomGraphNodeDegs{"$j"}}, "$i"; #wrong
    push @{$refgraphNodeDegs->{$j}}, $i;
  }
  else {
    #print "22. node $j\n";
    my @partners;
    push @partners, "$i";
    #$randomGraphNodeDegs{"$j"}=\@partners; #wrong
    $refgraphNodeDegs->{"$j"}=\@partners;
    $isNewNode=1;
  }

  } else {
	  next;
  }
  return ($loaded, $isNewNode);
}

############################################################################
## getOriginalDegreeDist from File
############################################################################
sub getOriginalNetworkFromFile{
  my $refgraphEdges = shift;
  my $refgraphNodeDegs = shift;
  my $filename = shift;
  my $mark=1;

  open(IN, "$filename") || die "can not open $filename to read\n";
  while(my $line=<IN>) {
    chomp $line;
    my ($i, $j)=split /\t/, $line;
    #print "read pair: $i\t$j\n";
    loadEdgeAndNodeLists($refgraphEdges, $refgraphNodeDegs, $i, $j,$mark);
  }
  #print "in sub, node list length=", scalar(keys %randomGraphNodeDegs),"\n";
  #return \%randomGraphNodeDegs;
}


############################################################################
## genInteractionFile
############################################################################
sub genInteractionFile{
  my $refEdges = shift;
  my %edges = %{$refEdges};
  my $filename= shift;

  open(OUT1, ">$filename") || die "can not open $filename to write\n";
  foreach my $edge (keys %edges) {
    #my ($i, $j)=split /\|/, $edge;
    $edge=~s/\|/\t/g;
    print OUT1 "$edge\n";
    #print "write pair: $edge\n";
  }
  close OUT1;
}

############################################################################
## genKpKFile
############################################################################
sub genKpKFile{
  my $refNodeDegs = shift;
  my %nodeDegs = %{$refNodeDegs};
  my $filename= shift;

  my %kCounts;
  foreach my $node (keys %nodeDegs) {
    #print "$node\n";
    my $degree=scalar(@{$nodeDegs{$node}});
    if (exists $kCounts{$degree}) {
      #print "1.degree=", $degree, "\n";
      $kCounts{$degree}++;
      #print "1.degree count=", $kCounts{$degree}, "\n";
    }
    else {
      #print "2.degree=", $degree, "\n";
      $kCounts{$degree}=1;
    }
  }

  if ($filename) {
    open(OUT2, ">$filename") || die "can not open $filename to write\n";
    foreach my $k (keys %kCounts) {
      print "$k\t$kCounts{$k}\n";
      print OUT2 "$k\t$kCounts{$k}\n";

    }
    close OUT2;
  }
  return \%kCounts;
}

############################################################################
## getAvgK
############################################################################
sub getAvgK{
    my $refKCounts=shift;
    my %kCounts=%{$refKCounts};
    my $avgK;
    if (scalar(keys %kCounts)>2) {
      print "calculating parameters ......\n";
      ##### get avgK
      my $sn=0;
      my $snk=0;
      foreach my $k (keys %kCounts) {
        my $n=$kCounts{$k};
        #print "*****", ($k, $n), "\n";
        $sn=$sn+$n;
        $snk=$snk+($k*$n);
      }
      if ($sn!=0) {
       $avgK=$snk/$sn;
       }
       #print "avgK=$avgK\n";
    }
    return $avgK;
}

############################################################################
## GenerateScreenDist(\%randomGraphEdges, \%randomGraphNodeDegs, \%screenGraphNodeDegs, $bait_nmuber, $edgeCoverage)
############################################################################
sub generateScreenDist{
  my $refgraphEdges = shift;
  my $refgraphNodeDegs = shift;
  my %randomGraphEdges = %$refgraphEdges;  # we don't want to modify the original value, so copy to a new variable
  my %randomGraphNodeDegs = %$refgraphNodeDegs;
  my $refScreenEdges=shift;  # we want to modify the original value, so copy to a new variable
  my $refScreenNodeDegs=shift;
  my $bait_number = shift;
  my $edgeCoverage = shift;

  print "bait_number=$bait_number\n";
  print "edgeCoverage=$edgeCoverage\n";

  my @nodes=keys %randomGraphNodeDegs;
  Randomize(\@nodes);

  my @nodeSelected;
  for my $i (1..$bait_number) {
    push @nodeSelected, $nodes[$i-1];
  }
  print "selectedNodes length=", scalar(@nodeSelected), "\n";
  my %screenGraphNodeDegs;

  foreach my $i (@nodeSelected) {
    #print "\$i=$i\n";
    #print "length of keys randomGraphNodeDegs = ".(keys %randomGraphNodeDegs)."\n";
    if (!$i) { return; }
    foreach my $j (@{$randomGraphNodeDegs{$i}}) {
      if (rand(1)<$edgeCoverage) {
        #print "loading $i|$j\n";
        loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $i, $j);
      }
    }
  }
}

############################################################################
## GenerateMatrixScreenDist(\%randomGraphEdges, \%randomGraphNodeDegs, \%screenGraphNodeDegs, $bait_nmuber, $edgeCoverage)
############################################################################
sub generateMatrixScreenDist{
  my $refgraphEdges = shift;
  my $refgraphNodeDegs = shift;
  my %randomGraphEdges = %$refgraphEdges;  # we don't want to modify the original value, so copy to a new variable
  my %randomGraphNodeDegs = %$refgraphNodeDegs;
  my $refScreenEdges=shift;  # we want to modify the original value, so copy to a new variable
  my $refScreenNodeDegs=shift;
  my $bait_number = shift;
  my $edgeCoverage = shift;

  print "bait_number=$bait_number\n";
  print "edgeCoverage=$edgeCoverage\n";

  my @nodes=keys %randomGraphNodeDegs;
  Randomize(\@nodes);

  my %nodeSelected;
  for my $i (1..$bait_number) {
    $nodeSelected{$nodes[$i-1]}="1";
  }
  print "selectedNodes length=", scalar(keys %nodeSelected), "\n";
  my %screenGraphNodeDegs;

  #$edgeCoverage=((scalar @nodes)/(scalar keys %nodeSelected))*$edgeCoverage; comment out because simulation should have the same chance get edge for different size of bait selected

  foreach my $i (keys %nodeSelected) {
    #print "\$i=$i\n";
    #print "length of keys randomGraphNodeDegs = ".(keys %randomGraphNodeDegs)."\n";
    if (!$i) { return; }

    foreach my $j (@{$randomGraphNodeDegs{$i}}) {
      if (rand(1)<$edgeCoverage && (exists $nodeSelected{$j})) { # restrict preys to bait list only!!!
          print "*************** matrix screen: loading $i|$j\n";
          loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $i, $j);
      }
    }
  }
}


############################################################################
## getPartners(refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $totalNodes, $maxNodes, @nodeIds)
# this is depth first, we do not want to grow the network like this
############################################################################
sub getPartners{
  my $refgraphNodeDegs = shift;
  my $refScreenEdges = shift;
  my $refScreenNodeDegs = shift;
  my $totalNodes = shift;
  my $maxNodes = shift;
  my $refNodeIds = shift;
  my @nodeIds=@$refNodeIds;

  if ($totalNodes<$maxNodes) {
    foreach my $nodeId (@nodeIds) {
      print "totalNodes=$totalNodes, crawl to $nodeId ..............\n";
      my @partners=@{$refgraphNodeDegs->{$nodeId}};
      foreach my $partnerId (@partners) {
        if ($totalNodes>=$maxNodes) { return $totalNodes; }
        if ($nodeId eq $partnerId) { next; }
        if (exists $refScreenEdges->{"$nodeId.$partnerId"} || exists $refScreenEdges->{"$partnerId.$nodeId"}) {
          next;
        }
        print "loading $nodeId.$partnerId\n";
        loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $nodeId, $partnerId);
        $totalNodes++;
        $totalNodes=getPartners($refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $totalNodes, $maxNodes, \@partners);
      }
    }
  }
  return $totalNodes;
}


############################################################################
## getOneHoppers(refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $totalNodes, $maxNodes, @nodeIds)
# this is breadth first, we want to grow the network like this
############################################################################
sub getOneHoppersWithMax{
  my $refgraphNodeDegs = shift;
  my $refScreenEdges = shift;
  my $refScreenNodeDegs = shift;
  my $maxNodes = shift;
  my $refNodeIds = shift;
  my @nodeIds=@$refNodeIds;

  while ((scalar(keys %{$refScreenNodeDegs})<$maxNodes) && @nodeIds) {
  my @oneHoppers;
  foreach my $nodeId (@nodeIds) {
      #print "crawl to $nodeId ..............\n";
      my @partners=@{$refgraphNodeDegs->{$nodeId}};
      foreach my $partnerId (@partners) {
        if ($nodeId eq $partnerId) { next; }
        #print "trying to load $nodeId.$partnerId\n";
        my ($loaded, $isNewNode)=loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $nodeId, $partnerId);
        if ($isNewNode) {
          push @oneHoppers, $partnerId;
        }
      }
  }
  @nodeIds=@oneHoppers;
}
}

############################################################################
## getOneHoppers(refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $totalNodes, $maxNodes, @nodeIds)
# this is breadth first, we want to grow the network like this,
# recurse makes the compiled codes out of memory
############################################################################
sub getOneHoppers1{
  my $refgraphNodeDegs = shift;
  my $refScreenEdges = shift;
  my $refScreenNodeDegs = shift;
  my $refNodeIds = shift;
  my @nodeIds=@$refNodeIds;
  my $totalNodes=shift;

  #print "*** 2. length of node list= ".scalar(keys %{$refgraphNodeDegs})."\n";
  if (!@nodeIds) { return;}
  my @oneHoppers;
  foreach my $nodeId (@nodeIds) {
      #print "crawl to $nodeId, totalNodes=$totalNodes..............\n";

      my @partners=@{$refgraphNodeDegs->{$nodeId}};
      foreach my $partnerId (@partners) {
        if ($nodeId eq $partnerId) { next; }
        #print "trying to load $nodeId.$partnerId\n";
        my ($loaded, $isNewNode)=loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $nodeId, $partnerId);
        if ($isNewNode) {
          $totalNodes++;
          #print "loaded .... totalNodes=$totalNodes \n";
          push @oneHoppers, $partnerId;
        }
      }
  }
  getOneHoppers($refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, \@oneHoppers, $totalNodes);

}

############################################################################
## getOneHoppers(refgraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $totalNodes, $maxNodes, @nodeIds)
# this is breadth first, we want to grow the network like this,
# make it in infinite while loop now
############################################################################
sub BFS{
  my $refgraphNodeDegs = shift;
  my $refScreenEdges = shift;
  my $refScreenNodeDegs = shift;
  my $refNodeIds = shift;
  my $totalNodes=shift;
  my $refDists=shift;
  my $out=shift;

  my @nodeIds=@$refNodeIds;
  open OUT, ">$out";

 #print "*** 2. length of node list= ".scalar(keys %{$refgraphNodeDegs})."\n";
 my @firstLvNodes=@nodeIds;
 my $level=1;
 while (@nodeIds) {
  my @oneHoppers;
  foreach my $nodeId (@nodeIds) {
      #print "crawl to $nodeId, totalNodes=$totalNodes..............\n";
	  my @partners;
	  if (exists $refgraphNodeDegs->{$nodeId}) {
		  @partners=@{$refgraphNodeDegs->{$nodeId}};
	  }
      foreach my $partnerId (@partners) {
        #if ($nodeId eq $partnerId) { next; }
        #print "trying to load $nodeId.$partnerId\n";
        my ($loaded, $isNewNode)=loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $nodeId, $partnerId);
        if ($isNewNode) {
          if ($nodeId ne $partnerId) {
            $totalNodes++;
          }
          #print "loaded .... totalNodes=$totalNodes \n";
          push @oneHoppers, $partnerId;
        }
      }
  }

   foreach my $source (@firstLvNodes) {
       foreach my $target (@oneHoppers) {
           $refDists->{"$source|$target"}=$level;
           print "$source|$target=$level\n";
		   print OUT "$source|$target=$level\n";
       }
   }
  $level++;
  @nodeIds=@oneHoppers;
  print "*********@nodeIds\n";
}
}

############################################################################
##getComponentSizes(\%randomGraphEdges, \%randomGraphNodeDegs, \%screenGraphNodeDegs, $bait_nmuber, $edgeCoverage)
############################################################################
sub getComponentSizes{
  my $refgraphNodeDegs = shift;

  my %graphNodeDegs=%{$refgraphNodeDegs};
  my $largestCompSize=0;
  my $largestCompId;

  my %nodesToCover=%graphNodeDegs;

  #my $maxNodesToCover=int(scalar(keys %graphNodeDegs)*0.5);

  my $totalNodes=0;
  my %compEdges;
  my %compNodes;

  my $compId=0;
  ##my %dists;
  while (scalar (keys %nodesToCover)) {
    #print "*** 1. length of node list= ".scalar(keys %nodesToCover)."\n";
    my @nodeIds=keys %nodesToCover;
    Randomize(\@nodeIds);
    my @nodeSelected;
    push @nodeSelected, $nodeIds[0];
    #print "***1. node selected = ".$nodeIds[0]."\n";
    my $currentCompSize=1;

    my %screenEdges;
    my %screenNodeDegs;

    #print "********************** 1. maxNodesToCover=$maxNodesToCover\n";
    my $total=1;

    ##my %subdists;
    BFS(\%nodesToCover, \%screenEdges, \%screenNodeDegs, \@nodeSelected, $total);
    $compId++;
    $currentCompSize=scalar(keys %screenNodeDegs);
    $compNodes{$compId}=\%screenNodeDegs;
    $compEdges{$compId}=\%screenEdges;
    #print "currentCompSize=$currentCompSize, currentCompId=$compId\n";
    if ($currentCompSize>$largestCompSize) {
      $largestCompSize=$currentCompSize;
      $largestCompId=$compId;
    }

    #if ($totalNodes>=$maxNodesToCover) { last; }
    #print "length of screened nodes=".scalar(keys %screenNodeDegs)."\n";

    foreach my $id (keys %screenNodeDegs) {
      delete $nodesToCover{$id};
    }
    ##foreach my $dist (keys %subdists) {
    ##   $dists{$dist}=$subdists{$dist};
    ##   print " 1. sub $dist =$subdists{$dist}\n";
    ##}
    $totalNodes=$totalNodes+$currentCompSize;
  }
  my $tot=0;
  my $nu=0;
  ##foreach my $dist (keys %dists) {
  ##    $tot += $dist;
  ##    $nu++;
  ##    print " 2. sub $dist =$dists{$dist}\n";
  ##}
  ##my $avgDist=sprintf("%.2f", $tot/$nu);
  ##print "tot dists=$tot, nu=$nu, avgDist=$avgDist\n";
  return (\%compEdges, \%compNodes, $largestCompId);
}

############################################################################
##getLargestCompSize(\%randomGraphEdges, \%randomGraphNodeDegs, \%screenGraphNodeDegs, $bait_nmuber, $edgeCoverage)
############################################################################
sub getLargestCompSize{
  my $refgraphNodeDegs = shift;

  my %graphNodeDegs=%{$refgraphNodeDegs};
  my $largestCompSize=0;

  my %largestCompEdges;
  my %largestCompNodeDegs;

  my %nodesToCover=%graphNodeDegs;

  my $maxNodesToCover=int(scalar(keys %graphNodeDegs)*0.5);

  my $totalNodes=0;
  while (scalar (keys %nodesToCover)) {
    #print "*** 1. length of node list= ".scalar(keys %nodesToCover)."\n";
    my @nodeIds=keys %nodesToCover;
    Randomize(\@nodeIds);
    my @nodeSelected;
    push @nodeSelected, $nodeIds[0];
    #print "***1. node selected = ".$nodeIds[0]."\n";
    my $currentCompSize=1;

    my %screenEdges;
    my %screenNodeDegs;

    #print "********************** 1. maxNodesToCover=$maxNodesToCover\n";
    my $total=1;
    BFS(\%nodesToCover, \%screenEdges, \%screenNodeDegs, \@nodeSelected, $total);
    $currentCompSize=scalar(keys %screenNodeDegs);
    #print "currentCompSize=$currentCompSize, largestCompSize=$largestCompSize\n";
    if ($currentCompSize>$largestCompSize) {
      $largestCompSize=$currentCompSize;
      %largestCompEdges=%screenEdges;
      %largestCompNodeDegs=%screenNodeDegs;
    }

    if ($totalNodes>=$maxNodesToCover) { last; }
    #print "length of screened nodes=".scalar(keys %screenNodeDegs)."\n";

    foreach my $id (keys %screenNodeDegs) {
      delete $nodesToCover{$id};
    }

    $totalNodes=$totalNodes+$currentCompSize;
  }
  return (\%largestCompEdges, \%largestCompNodeDegs, $largestCompSize);
}

############################################################################
##calculate log(p(k)) vs log(k) regression r square and significance
############################################################################
#sub logLogRegression{
#  my $refKCounts = shift;
#  my %kCounts = %$refKCounts;

#  my @logKs;
#  my @logPKs;
#  my $n=0;

#  foreach my $k (keys %kCounts){
#    $logKs[$n] = log10($k);
#    $logPKs[$n] = log10($kCounts{$k});
#    print "$logKs[$n]\t$logPKs[$n]\n";
#    $n++;
#  }

#  my $ls = Statistics::OLS->new();
#  $ls->setData (\@logKs, \@logPKs);
#  $ls->regress();
#  my $R_squared = $ls->rsq();
#  my ($intercept, $slope) = $ls->coefficients();
#  my ($tstat_intercept, $tstat_slope) = $ls->tstats();
#  #print "R_squared, tstat_intercept, tstat_slope:$R_squared, $tstat_intercept, $tstat_slope\n";
#  my $pIntercept=Statistics::Distributions::tprob(2*$n-2,$tstat_intercept);
#  my $pSlope=Statistics::Distributions::tprob(2*$n-2,$tstat_slope);
#  print "R_squared, tstat_intercept, tstat_slope:$R_squared, $pIntercept, $pSlope\n";
#  return ($R_squared, $intercept, $slope, $pIntercept, $pSlope);
#  #return ($R_squared, $tstat_intercept, $tstat_slope);
#}

###############################################################################################
#  getClusteringCs
###############################################################################################
sub getClusteringCs{
# To calculate the distance between protein pairs within interaction networks;
# algorithm is based on Haiyuan Yu 03/27/2003 TopNet.txt
my $refGraphEdges=shift;
my $refNodeDegs=shift;

my %edges=%{$refGraphEdges};
my %nodes=%{$refNodeDegs};
my %ccs;
# Calculate the clustering coefficient of each individual protein within the interaction networks;
# Suppose a vertex has k neighbours; then at most k(k-1)/2 edges can exist between them; C denote the fraction of these allowable edges that actually exist;
# CC for the whole networks is the average CC for each individual vertex;

# Calculate the CC;
my $totCC;
my $noNodes=0;
for my $aa (sort keys %nodes) {
    #print "$nodes{$aa}\n";
    my @partners=@{$nodes{$aa}};
    if (scalar(@partners) > 3) {
                my $PE = scalar(@partners) * (scalar(@partners) - 1)/2; # $PE: Possible Edges;
                my $N = 0;
                for (my $i=0; $i<(scalar(@partners)-1); $i++) {
                     for (my $j=$i+1; $j<scalar(@partners); $j++) {
                          my $bb=$partners[$i];
                          my $cc=$partners[$j];
                          $N ++ if (exists $edges{"$bb|$cc"} || exists $edges{"$cc|$bb"});
                     }
                }
                my $CC = $N / $PE;
                #print "$N\t$PE\t$CC\n";
                if ($CC > 1) {
                        print "Something wrong with $aa\t",scalar(@partners),"\t$CC\t$N\n";
                        exit;
                }
                #print "cc: $aa\t",scalar(@partners),"\t$CC\t$N\n";
                $ccs{$aa}=$CC;
                $noNodes++;
                $totCC += $CC;
     }
}
my $avgCC=-1;
if ($noNodes>0) {
 $avgCC=sprintf("%.2f", $totCC/$noNodes);
}
return ($avgCC, \%ccs);
}

#########################################################
# getDiameter3
#########################################################
sub getDiameter3 {
my $refGraphEdges=shift;
my $refNodeDegs=shift;
my $file="diameterTmp";
Create_NetAcess_infiles($file, $refGraphEdges, 1);
Run_NetAcess();
#Parse_PairDistance_File();
my $pairdistance_file = '=' . $file . '.PairDistance.dat';
my ($avgDist, $refDists) = Calc_AvgPairDistance($pairdistance_file);
print "avgDist $avgDist\n";
Clean_infiles($file);
return ($avgDist, $refDists);
}

#########################################################
#
#########################################################
sub Create_NetAcess_infiles{
  my $file = shift;
  my $refGraphEdges=shift;
  my $write_dictionnary = shift;
  my %edges=%{$refGraphEdges};

  ## create the file data.in
  my %prot = ();
  my $ct = 0;

  open(IN, ">$file.in") || die "cant open $file.in\n";

  foreach my $edge (keys %edges) {
    #next if $_ =~ /[bait|prey]/i;
    my ($bait, $prey) = split /\|/, $edge;
    #print join("\t", $bait, $prey), "\n";
    unless ($prot{$bait}){
      $prot{$bait} = $ct;
      $ct++;
    }
    unless ($prot{$prey}){
      $prot{$prey} = $ct;
      $ct++;
    }
    print IN join("\t", $prot{$bait}, $prot{$prey}), "\n";
  }
  close(IN);


  ## create the file data.dict
  if ($write_dictionnary == 1){
    open(DIC, ">$file.dict") || die "cant open $file.dict\n";
    foreach my $prot (keys %prot){
      print DIC join("\t", $prot, $prot{$prot}), "\n";
    }
    close(DIC);
  }

  ## create NET.INI file
  Create_NET_INI_file($file);

  return 1;
}


#########################################################
#
#########################################################
sub Create_NET_INI_file{
  my $file = shift;

  ## create the NET.INI file
  open(INI, ">NET.INI") || die "cant open NET.INI\n";
  print INI << "E_O_E";
############################################################################
# NET's initialization file, created by NetIni VERSION 1.18
# Use the flag -h to have a list of command line options
################### Master parameters ######################################
#
 NK         =   50                # Number of nodes
# The following three fields select the random distribution of fitnesses:
#   0: Uniform [ x in (0,A) ]
#   1: Exponential [ A*exp(-A*x), x>0 ]
#   2: Gaussian [ (2*Pi*A^2)^-0.5*exp(-x^2/2A^2), x>0 ]
#   3: Power [ c*x^-A if x>B,  c*B^-A if x<=B ]
#
 DISTRIB    =   0
   A        =   0               # Parameter for the distribution above
   B        =   0               # Another parameter for the distribution above
 LINKTYPE   =   0               # Linking probability function
   CUTOFF   =   0               # Cutoff in the linking probability
   M        =   0              # Probability of successfull connections per node
   E        =   0            # Parameter in the linking prob (like kT in the Fermi distrib)
 TREE     =   0                 # Force the generation of tree graphs
 ACYCLIC     =   0                 # Force the generation of acyclic graphs
#
# The following two fields select BA parameters:
 BA_N0         =   0                # Number of starting nodes
 BA_M          =   0                # Number of incoming links at each step
#
################### Basic control  #########################################
#
E_O_E


  print INI " PROJNAME      =   $file      # Project name\n";

  print INI << "E_O_E";
 NET_GENR      =   0                 # 0=FITNESS, 1=BA
 NET_TYPE      =   0                 # 0=undirected, 1=directed
 WEIGHTED      =   0                 # 0=unweighted, 1=weighted edges
 MULTI           =   1                # Multiple runs
 READ_IN        =   1                 # Read net from file
################### Output control #########################################
 SAVE_NET       =   0                 # Save the resulting net onto file .net or .paj
 SHOW_NET       =   0                 # Display the resulting net on screen 1=DOT 2=GML
 RUN_GRACE      =   0                 # Open xmgrace at the end: 1=LOG-LOG 2=LIN-LIN
 DEGREE_DISTRIB =   0                  # Calculates and saves the degree distrib
 KNN            =   0                  # Calculates and saves the nearest neighs connectivity
 CLUSTER_COEFF  =   0                  # Calculates and saves the clustering coeff
 CLUSTER_COEFF2 =   0                  # Calculates and saves the clustering coeff up to 2nd neighs
 COMMUNITIES    =   0                  # Calculates the community size distribution
 SCC                    =   0                  # Finds the Strongly Connected Component of a directed graph
 REDUCTION      =   0                  # Reduce the net to that nr of nodes
 AMATRIX        =   0                  # Calculates eigenvalues and eigenvectors of graph associated matrices
 LANCZOS        =   0                  # Calculates eigenvalues and eigenvectors using lanczos routines
 EDGE_BETWEEN   =   0                  # Calculates and saves the edge betweenness
 SITE_BETWEEN   =   1                 # Calculates and saves the site betweenness
 PAIR_DISTANCE  =   1             # Save pairs and their distance
 SAVE_CLUSTER   =   0             # Save the node cluster sizes
 SPLIT_CLUSTER  =   0             # Save found clusters onto separate files
#
######################## END ###############################################
E_O_E
  close(INI);

  return 1;
}

#########################################################
#
#########################################################
sub Run_NetAcess {

  system('Net.access');
  return 1;

};

#########################################################
# Calc_AvgPairDistance
#########################################################
sub Calc_AvgPairDistance{
  my $file = shift;
  my $connect = 0;
  my $dist_tot = 0;

  open(IN, $file) || die "cant open $file\n";
  my %dists;
  while(<IN>){
    chomp;
    next if $_ =~ /^#/;
    my ($a, $b, $dist) = split;
    $dists{"$a|$b"}=$dist; # both a-b and b-a
    next if $dist == -1;
    $connect++;
    $dist_tot += $dist;
  }
  close(IN);

  my $avgDist = $dist_tot / $connect;
  return ($avgDist, \%dists);
}

#########################################################
#Clean_infiles
#########################################################
sub Clean_infiles{
  my $file = shift;
  system ("rm NET.INI");
  system ("rm =$file*");
  system ("rm +$file*");
  return 1;
}

################################################################################################
##  getDiameter
################################################################################################
sub getDiameter{
# To calculate the distance between protein pairs within interaction networks;
# algorithm is based on Haiyuan Yu 03/27/2003 TopNet.txt
my $refGraphEdges=shift;
my $refNodeDegs=shift;

my %edges=%{$refGraphEdges};
my %prots;
my %Inter;
foreach my $edge (keys %edges) {
    my ($aa, $bb)=split /\|/, $edge;
    $prots{$aa} = 1;
    $prots{$bb} = 1;
    $Inter{$aa}{$bb} = $Inter{$bb}{$aa} = 1;
}
close (DATA);

# Calculate the distance between protein pairs using greedy algorithm;
#open (ALL, ">Net_Distance_all.txt");
my $totalDist=0;
my $totalPairs=0;
my %read;
my (@level, @nlevel);
my $i;
my %overlap;
my %dists;
for my $aa (sort keys %prots) {
        %overlap = ();
        $overlap{$aa} = 1;
        $read{$aa} = 1;
        $i = 0;
        @level = ();
        $level[0] = $aa;
        while ($#level >= 0) {
                $i ++;
                @nlevel = ();
                for my $bb (@level) {
                        for my $cc (sort keys %{$Inter{$bb}}) {
                                if (!exists $overlap{$cc}) {
                                        push @nlevel, $cc;
                                        if (!exists $read{$cc}) {
                                            $dists{"$aa|$cc"}=$i; # only a-b or b-a not both
                                            $totalPairs++;
                                            $totalDist += $i;
                                            #print "distance: $aa|$cc=$i\t$totalDist/$totalPairs\n";
                                        }
                                }
                                $overlap{$cc} = 1;
                        }
                }
                @level = ();
                push @level, @nlevel;
        }
}
my $avgDist=sprintf("%.2f", $totalDist/$totalPairs);
#print "total Dist=$totalDist; totalPairs=$totalPairs; avgDist=$avgDist.\n";
return ($avgDist, \%dists);
}

################################################################################################
##  getDiameter1
################################################################################################
sub getDiameter1{
# To calculate the distance between protein pairs within interaction networks;
# algorithm is based on Debra Goldberg's program
my $refGraphEdges=shift;
my $nbd_p=shift;
my %dists;
my %pathlen;                # hash of shortest path lengths to current "root"

my @rootnodes;                # nodes to consider as root
my @nextnodes;                # next nodes to consider
my $numpaths = 0;        # total number of paths (each counted twice)
my $numuupaths;                # number of paths from node uu as root
my $totplen = 0;        # total length of shortest paths (each counted twice)
my $totuuplen;                # total length of shortest paths from node uu
my $maxuuplen;                # maximum path length (largest shortest path) from uu
my $maxplen = 0;        # maximum largest shortest path for any node (diameter)
my $minplen;                # minimum largest shortest path for any node (radius)
my $lgminplen;                # minimum path length in largest component (radius)
my $lgnumpaths = 0;        # twice number of paths in largest component
my $lgtotplen = 0;        # twice total path lengths in largest component
my $centernode;                # node with smallest largest shortest path
my $uu;                        # loop variable for a node
my $vv;                        # loop variable for a node
my $ww;                        # loop variable for a node
my $connected = 1;        # is this graph connected?
my %seen = ();                        # nodes already "assigned" a component
my $components = 0;                        # number of components

my $prt_dist=0;
if ($prt_dist) {
   print "Gene1\tGene2\tDistance\tComponent\n";
}

# get list of nodes in graph
@rootnodes = (keys %{$nbd_p});
my $num_other_nodes = $#rootnodes;        # one less than number of nodes
$minplen = $num_other_nodes + 1;
$lgminplen = $num_other_nodes + 1;
# for each node in graph
while (@rootnodes) {                        # for each node $uu
   $uu = shift @rootnodes;
   # clear hash of nodes seen from root so far
   %pathlen = ();
   $pathlen{$uu} = 0;
   # reset number of shortest paths computed from this root
   $numuupaths = 0;
   $totuuplen = 0;
   $maxuuplen = 0;

   if ( $prt_dist && ( ! defined $seen{$uu}) ) {
      $components++;
      $seen{$uu} = $components;
   }

   # determine shortest path to all other nodes, using BFS
   push @nextnodes, $uu;
   # nextnodes contains nodes to visit next;
   #  all neighbors that have not already been visited
   while (@nextnodes) {                        # for each node $vv
      $vv = shift @nextnodes;
      for $ww (@{${$nbd_p}{$vv}}) {
         if (! defined $pathlen{$ww}) {
            $pathlen{$ww} = $pathlen{$vv} +1;
            if ($prt_dist) {
               if ( (defined $seen{$ww}) && ($seen{$ww} != $seen{$uu}) ) {
                 print "Error: $ww was component $seen{$ww}, now $seen{$uu}\n";
               }
               $seen{$ww} = $seen{$uu};
               print "$uu\t$ww\t$pathlen{$ww}\tcomponent$seen{$ww}\n";
            }
            # something delays putting into the hash below
            $dists{"$uu|$ww"}=$pathlen{$ww} if (!exists $dists{"$uu|$ww"}); # only a-b or b-a not both?
            push @nextnodes, $ww;
            $numuupaths++;
            $totuuplen += $pathlen{$ww};
            if ($pathlen{$ww} > $maxuuplen) {
               $maxuuplen = $pathlen{$ww};
            }
         } # if not already processed
      } # end for each ww
   } # end while there are still nodes to traverse

   # graph is connected if all nodes have been visited
   if ($numuupaths != $num_other_nodes) {
      $connected = 0;
   }
   # this assumes largest component contains > 1/2 the nodes
   # if not, won't get statistics on largest component
   if ($numuupaths > ($num_other_nodes/2)) {
      if ($maxuuplen < $lgminplen) {$lgminplen = $maxuuplen;}
      $lgnumpaths += $numuupaths;
      $lgtotplen += $totuuplen;
   }

   $numpaths += $numuupaths;
   $totplen += $totuuplen;
   if ($maxuuplen > $maxplen) {$maxplen = $maxuuplen;}
   if ($maxuuplen < $minplen) {$minplen = $maxuuplen; $centernode = $uu;}
} # end while rootnodes

# need the following header line:
#  print "Characteristic path length (L)\tDiameter\tradius\tconnected?\t";

my $avg = $totplen / $numpaths;
print "$avg\t";

print "$maxplen\t$minplen\t";
print "$connected\t";
# problems if above assumption doesn't hold...
if ($lgnumpaths > 0) {
   $avg = $lgtotplen / $lgnumpaths;
   print "$avg\t";
}
else {
   print "Error\t";
}
#print "\n";

# Determine number and size of components
if ($connected) {
   print "1\t".($num_other_nodes+1)."\n";
}
else {
   @rootnodes = (keys %{$nbd_p});
   %seen = ();                        # nodes already "assigned" a component
   $components = 0;                        # number of components
   my $comp_size;                        # size of current component
   my @comp_sizes;                        # size of each component

   while (@rootnodes) {                        # for each node $uu
      $uu = shift @rootnodes;
      next if (defined $seen{$uu});

      # initialize for a new component
      $components ++;
      $comp_size = 0;

      push @nextnodes, $uu;
      # nextnodes contains nodes to visit next;
      #  all neighbors that have not already been visited
      while (@nextnodes) {                        # for each node $vv
         $vv = shift @nextnodes;
         next if (defined $seen{$vv});
         $seen{$vv} = 1;
         $comp_size ++;

         for $ww (@{${$nbd_p}{$vv}}) {
            next if (defined $seen{$ww});
            push @nextnodes, $ww;
         } # end for each ww
      } # end while there are still nodes to traverse

      push @comp_sizes, $comp_size;

   } # end while (@rootnodes) -- end current component
   print "$components";
   for $comp_size (sort {$b <=> $a} @comp_sizes) { print "\t$comp_size"; }
   print "\n";

} # end: Determine number and size of components

##################
my $avgDist=$avg;
return ($avgDist, \%dists);
}

################################################################################################
##  getDiameter2
################################################################################################
sub getDiameter2{
  my $gmlfile = shift;

  my $Diameter_prog="~jhan/commonCprogs/Get_Diameter";
  my $diameter;

  chomp($diameter = `$Diameter_prog $gmlfile`);

  return $diameter;
}

################################################################################################
##  getComponents
################################################################################################
sub getComponentSizes2{
  my $refGraphEdges=shift;
  my $refNodeDegs=shift;
  my $gmlfile = shift;

  generateGML($refGraphEdges, $refNodeDegs, $gmlfile);
  my $Component_prog = "~jhan/commonCprogs/Get_Component";
  ## Get sizes of comps
  ## run comp_prog that returns: <prot_id> <comp_id>
  my $compfile = $gmlfile."_subnet";

  system("$Component_prog $gmlfile $compfile");

  open(COMP,"$compfile") || die "cant open compfile $compfile\n";
  my %comp_size;
  my %compDegrees;
  while(<COMP>){
    chomp;
    my ($prot_id,$comp_id) = split;
    $comp_id = "comp_".$comp_id;     ## Can't use string ("0") as a HASH ref while "strict refs" in use
    if ($comp_size{$comp_id}){
      $comp_size{$comp_id}++;
      $compDegrees{$comp_id}=$compDegrees{$comp_id}+scalar(@{$refNodeDegs->{$prot_id}});
    }
    else {
      $comp_size{$comp_id} =1;
      $compDegrees{$comp_id}=scalar(@{$refNodeDegs->{$prot_id}});
    }
    if (exists $refGraphEdges->{"$prot_id|$prot_id"}) { # add one degree for homodimer to make the final edge count=degree/2
        $compDegrees{$comp_id}++;
    }
  }
  close(COMP);
  #system("rm $compfile");


  ## extract the list of prot of the biggest component
  #my @comps=sort { $comp_size{$b} <=> $comp_size{$a} } keys %comp_size;
#  my $largestCompId=$comp[0];
#  my $largestCompSize=$comp_size{$largestCompId};

  ## get the avg size of the other components
  #my $other_comp_size_tot = 0;
  #foreach my $comp_id (keys %comp_size){
#    if (!($comp_id eq $biggest_comp_id)){
#      $other_comp_size_tot += $comp_size{$comp_id};
#    }
#  }
#  if (scalar keys %comp_size == 1){
#    $other_comp_avgsize = 0;
#  }
#  else{
#    $other_comp_avgsize = $other_comp_size_tot / ((scalar keys %comp_size)-1);
#  }
  return (\%comp_size, \%compDegrees);
}

################################################################################################
##  sampleGraph
################################################################################################
sub sampleGraph {
  my $noOfNodes=shift;
  my $refInputGraphEdges=shift;
  my $refInputGraphNodeDegs=shift;
  my $coveragePlotFilename=shift;
  my $foldername=shift;
  my $isMatrix=shift;

  $noOfNodes=scalar(keys %{$refInputGraphNodeDegs}); # do not use the desired noNodes but rather use the actual noNodes

  my $covFolder="PctCovPctNodesPlot";

  if ($isMatrix) {
    $covFolder=$covFolder."Matrix";
    $foldername=$foldername."Matrix";
  }

  # change to > after done
  open(OUT, ">$covFolder"."/$coveragePlotFilename") || die ("can not open PctCovPctNodesPlot/$coveragePlotFilename\n");
  for (my $i=0.01;  $i<1.01; $i=$i+0.01) {
    for (my $j=0.01; $j<1.01; $j=$j+0.01) {

#for (my $i=0.1;  $i<=0.1; $i=$i+0.01) {
  #for (my $j=0.1; $j<=0.1; $j=$j+0.01) {
      $i=sprintf("%.2f",$i);
      $j=sprintf("%.2f",$j);
      #if ($i<0.89 || ($i==0.89 && $j<=0.07)) { next;} # comment out after done
      print "i, j: $i, $j\n";
      my $bait_number=$i*$noOfNodes;
      my $edgeCoverage=$j;
      print "bait_number, edgeCoverage: $bait_number, $edgeCoverage\n";
      my %screenGraphNodeDegs;
      my %screenGraphEdges;
      if ($isMatrix) {
           generateMatrixScreenDist($refInputGraphEdges, $refInputGraphNodeDegs, \%screenGraphEdges, \%screenGraphNodeDegs, $bait_number, $edgeCoverage);
      }
      else {
           generateScreenDist($refInputGraphEdges, $refInputGraphNodeDegs, \%screenGraphEdges, \%screenGraphNodeDegs, $bait_number, $edgeCoverage);
      }
      genInteractionFile(\%screenGraphEdges, "$foldername"."/screenDegsB$i.C$j.txt");
      print "screen node list length=", scalar(keys %screenGraphNodeDegs),"\n";
      #my %kCounts=%{genKpKFile(\%screenGraphNodeDegs)};
      my %kCounts=%{genKpKFile(\%screenGraphNodeDegs, "Deg$foldername"."/screenDegsB".sprintf("%.2f", $i).".C".sprintf("%.2f",$j).".txt")};

      my $avgK=getAvgK(\%kCounts);
      print "avgK=$avgK\n";
      ####### other params
      my ($refCompEdges, $refCompNodeDegs, $largestComponentId)=getComponentSizes(\%screenGraphNodeDegs);
      my %allCompsEdges=%{$refCompEdges};
      my %allCompsNodeDegs=%{$refCompNodeDegs};

      my $numComps=scalar(keys %allCompsNodeDegs);
      my $avgCompSize= sprintf("%.1f", scalar(keys %screenGraphNodeDegs)/$numComps);
      print "tot number of nodes=", scalar(keys %screenGraphNodeDegs), "\n";
      my %compEdges=%{$allCompsEdges{$largestComponentId}};
      print "number of Comps=$numComps, avgCompSize=$avgCompSize \n";

      my %largestCompNodes=%{$allCompsNodeDegs{$largestComponentId}};
      my $largestComponentSize=scalar(keys %largestCompNodes);

      my ($avgCC,$refccs)=getClusteringCs(\%screenGraphEdges, \%screenGraphNodeDegs);

      my ($R_squared,$intercept, $slope, $pIntercept, $pSlope)=logLogRegression(\%kCounts);
      #my $largestComponentSize=getLargestCompSize(\%screenGraphNodeDegs);
      my $totalNodesCollected=scalar(keys %screenGraphNodeDegs);
      my $fractionOfLargestComp=$largestComponentSize/$totalNodesCollected;
      my $totalEdges=scalar(keys %screenGraphEdges);

      print "++++++", join("\t", $i, $edgeCoverage, $R_squared,$intercept, $slope, $pIntercept, $pSlope, $largestComponentSize, $totalNodesCollected,$fractionOfLargestComp, $totalEdges,
            $avgK, $numComps, $avgCompSize, $avgCC),"\n";
      print OUT join("\t", $i, $edgeCoverage, $R_squared, $intercept, $slope, $pIntercept, $pSlope, $largestComponentSize, $totalNodesCollected, $fractionOfLargestComp,$totalEdges,
            $avgK, $numComps, $avgCompSize, $avgCC),"\n";
    }
  }

#for (my $i=0.1;  $i<=0.1; $i=$i+0.01) {
##  for (my $j=0.1; $j<=0.1; $j=$j+0.01) {
##for (my $i=1;  $i<1.01; $i=$i+0.01) {
#  for (my $j=1; $j<1.01; $j=$j+0.01) {
#    print "i, j: $i, $j\n";
#    my $bait_number=$i*$noOfNodes;
#    my $edgeCoverage=$j;
#    print "bait_number, edgeCoverage: $bait_number, $edgeCoverage\n";
#    my %screenGraphNodeDegs;
#    my %screenGraphEdges;
#    generateScreenDist($refInputGraphEdges, $refInputGraphNodeDegs, \%screenGraphEdges, \%screenGraphNodeDegs, $bait_number, $edgeCoverage);
#    genInteractionFile(\%screenGraphEdges, "$foldername"."/screenDegsB$i.C$j.txt");
#    print "screen node list length=", scalar(keys %screenGraphNodeDegs),"\n";
#    #my %kCounts=%{genKpKFile(\%screenGraphNodeDegs)};
#    my %kCounts=%{genKpKFile(\%screenGraphNodeDegs, "Deg$foldername"."/screenDegsB$i.C$j.txt")};

#    if (scalar(keys %kCounts)>2) {
#      my ($R_squared,$intercept, $slope, $pIntercept, $pSlope)=logLogRegression(\%kCounts);
#      my $largestComponentSize=getLargestCompSize(\%screenGraphNodeDegs);
#      my $totalNodesCollected=scalar(keys %screenGraphNodeDegs);
#      my $fractionOfLargestComp=$largestComponentSize/$totalNodesCollected;

#      print "++++++", join("\t", $bait_number,$edgeCoverage, $R_squared,$intercept, $slope, $pIntercept, $pSlope, $largestComponentSize, $totalNodesCollected,$fractionOfLargestComp),"\n";
#      print OUT join("\t", $bait_number,$edgeCoverage, $R_squared, $intercept, $slope, $pIntercept, $pSlope, $largestComponentSize, $totalNodesCollected, $fractionOfLargestComp),"\n";
#    }
#  }
#}

close OUT;
}

################################################################################################
##  generateGraphOfSize
################################################################################################
sub generateGraphOfSize {
  my $refLcEdges=shift;
  my $refLcNodeDegs=shift;
  my $refCompNodeSizes = shift;
  my $refCompEdgeSizes = shift;
  my %screenEdges; # all currently selected components
  my %screenNodeDegs;

  my %compNodeSizes=%{$refCompNodeSizes};
  my %compEdgeSizes=%{$refCompEdgeSizes};
  #foreach my $compId (sort { $compNodeSizes{$b} <=> $compNodeSizes{$a} } keys %compNodeSizes) {
  my @sortedCompIds= sort { $compNodeSizes{$b} <=> $compNodeSizes{$a} } keys %compNodeSizes;
  my $compId=$sortedCompIds[0];
  my ($refcompEdges,$refcompNodeDegs)=generateComponentOfSize($refLcEdges, $refLcNodeDegs,$compNodeSizes{$compId},$compEdgeSizes{$compId});
  ### uncomment for all components
   # if ($refcompEdges) {
#      my %compEdges=%{$refcompEdges};
#      foreach my $edge (keys %compEdges) {
#        my ($ida, $idb)=split /\|/, $edge;
#        #print "********************loading screen edge $ida|$idb************************\n";
#        loadEdgeAndNodeLists(\%screenEdges,\%screenNodeDegs,$ida, $idb);
#      }
#    }
#  } # foreach compId
#  return (\%screenEdges, \%screenNodeDegs);
  ### end of comment

  return ($refcompEdges,$refcompNodeDegs);
}

################################################################################################
##  generateComponentOfSize
################################################################################################
sub generateComponentOfSize {
  my $refLcEdges=shift;
  my $refLcNodeDegs=shift;
  my $noNodes = shift;
  my $noEdges = shift;
#  my $refScreenEdges=shift;
#  my $refScreenNodeDegs=shift;
#  my $refCompEdges=shift;
#  my $refCompNodeDegs=shift;

  my $MAX_ATTEMPTS=5;
  my $noAttempts=0;
  while ($noAttempts<$MAX_ATTEMPTS) {
    $noAttempts++;
    # get linked nodes of $noNodes number, this can always succeed
    my %testEdges;
    my %testNodeDegs;
    # pass in Screen graphs to make sure the new component is not connected to existing components
    #growRandomNetToNodeSize($refLcEdges,$refLcNodeDegs,$noNodes,$refScreenEdges,$refScreenNodeDegs,\%testEdges, \%testNodeDegs);
    growRandomNetToNodeSize($refLcEdges,$refLcNodeDegs,$noNodes,\%testEdges, \%testNodeDegs);

    # the following is unlikely, because avgK=1 if only add one like to each new node, but just in case
    if ((keys %testEdges)>$noEdges) {
      print "!!!!!!!!!!!!!!!!!!!!!! got component 1: !!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
      return (\%testEdges,\%testNodeDegs);
    }

    # get total possible edges among the testNodes
    my @allPossibleEdges;
    my %lcEdges=%{$refLcEdges};
    foreach my $edge (keys %lcEdges) {
      my ($ida, $idb)=split /\|/, $edge;
      if (exists $testEdges{"$ida|$idb"} || exists $testEdges{"$idb|$ida"}) { next; }
      if (exists $testNodeDegs{$ida} && exists $testNodeDegs{$idb}) {  # both nodes of an edge in the same component
        push @allPossibleEdges, $edge;
      }
    }

    if (((scalar @allPossibleEdges)+scalar(keys %testEdges)) < $noEdges) {
      #print "??????????????????? ",scalar @allPossibleEdges, "+", scalar(keys %testEdges), ", not enough edges to pick edges to get=$noEdges ?????????????????????????\n";
      next;
    } # force to pick new nodes, add one attempt

    # add edges to get the desired number of edges, because now there are enough available edges
    # it should be able to always reach the desired number of edges
    Randomize(\@allPossibleEdges);
    while ((scalar (keys %testEdges)) <$noEdges) {
      my $edge=pop @allPossibleEdges;
      my ($ida, $idb)=split /\|/, $edge;
      #if (exists $testEdges{"$ida|$idb"} || exists $testEdges{"$idb|$ida"}) { next; }
      #print "======================adding new edge $ida|$idb, current edges", scalar (keys %testEdges), "edges to get=$noEdges\n";
      loadEdgeAndNodeLists(\%testEdges, \%testNodeDegs, $ida, $idb);
    }
    # copy good networks to the pointers to send out
    #print "length of testEdges=", scalar(keys %testEdges), "\n";
    #print "length of testNodeDegs=", scalar(keys %testNodeDegs), "\n";
    return (\%testEdges,\%testNodeDegs);
  }
}

################################################################################################
##  growRandomNetOfSize
################################################################################################
sub growRandomNetToNodeSize {
  my $refInputGraphEdges=shift;
  my $refInputGraphNodeDegs=shift;
  my $noNodes = shift;
#  my $refScreenEdges=shift;
#  my $refScreenNodeDegs=shift;
  my $refCompEdges=shift;
  my $refCompNodeDegs=shift;

  my %inputGraphNodeDegs=%{$refInputGraphNodeDegs};
  my @nodesToPick=keys %inputGraphNodeDegs;
  my %seeds;
    #print "RECREATING SEED\n";
  my $seedId = pickRandom(\@nodesToPick);
  $seeds{$seedId}=1;

    my %intx;
    ## ... expand the seed up to the size of the "jh_module"
    #print "EXPANDING SEED $seedId \n";
    my $size = scalar keys %seeds;
    while ($size < $noNodes){
      #print "++++++size=$size, noNodes=$noNodes\n";
      #expandSubnet($refInputGraphNodeDegs, $refScreenEdges, $refScreenNodeDegs, $refCompEdges, $refCompNodeDegs, \%seeds);
      expandSubnet($refInputGraphNodeDegs, $refCompEdges, $refCompNodeDegs, \%seeds);
      %seeds = %{$refCompNodeDegs};
      $size = scalar keys %seeds;
      #print ".";
    }
    #print " done\n";
}

################################################################################################
##  pickRandom
################################################################################################
#sub pickRandom {
#my $refArray=shift;
#Randomize($refArray);
#return $refArray->[0];
#}

##########################################################################################################
##
##########################################################################################################
sub  expandSubnet{
  my $refInputGraphNodeDegs=shift;
#  my $refScreenEdges=shift;
#  my $refScreenNodeDegs=shift;
  my $refCompEdges=shift;
  my $refCompNodeDegs=shift;
  my $refSeeds=shift;
  my %seeds=%{$refSeeds};

  ## take a random prot in keys %prot ($initProt)
  my @initprots = keys %seeds;
#  print join(",",@initprots);
  my $initprot = pickRandom(\@initprots);
  #print " initprot $initprot\t";

  ## select all intx with this prot as idA and as idB: get the list of intercators
  my @partners=@{$refInputGraphNodeDegs->{$initprot}};

  #foreach my $partner (@partners) {
#    print "partner id= $partner\n";
#  }

  if ((scalar @partners)==0) {
    return;
  }

  ## pick one partner randomly
  my $partnerPicked = pickRandom(\@partners);
  #print " partner picked=$partnerPicked\n";

  # the following can not garantee to pick all edges among the nodes picked
  if (exists $seeds{$partnerPicked}) {return;} # load only new node so that each node is extended only by one edge
  #print "new node found $partnerPicked......";
  #if (exists $refScreenEdges->{"$initprot|$partnerPicked"} || exists $refScreenEdges->{"$partnerPicked|$initprot"}) {return;} # load only the new nodes that do not directly link to previously selected components
  #print "not in previous components $partnerPicked......\n";
  loadEdgeAndNodeLists($refCompEdges, $refCompNodeDegs, $initprot, $partnerPicked);
}


################################################################################################
##  AllocateDegreeDistribution
################################################################################################
sub AllocateDegreeDistribution {
my $num_node=shift;
my $refFi=shift;
my @fi=@{$refFi};
my $sum_fi = shift;
my $refNodes = shift;

# because starting at node degree 1 truncate the left tail of Gaussian distribution
# at the negative side of x-axis, need to renormalize the fraction to total of 1

for (my $i=0 ; $i<scalar @fi ; $i++){
  #print "fi=$fi[$i], sum_fi=$sum_fi\n";
  $fi[$i] = $fi[$i] / $sum_fi;
}

# create Sigma(number of nodes at degree i) number of nodes,
# for each node, assign the degree i
my $node_idx = 1;
my $tot_slot_num = 0;
for (my $i=0 ; $i<scalar @fi ; $i++){
  my $num_node_of_this_degree  = sprintf("%d",$num_node * $fi[$i]);
  for(1..$num_node_of_this_degree){
    $refNodes->{$node_idx} = $i;
    $node_idx++;
    $tot_slot_num += $i;
  }
}

if ($tot_slot_num % 2){
   $refNodes->{'1'} += 1;
   $tot_slot_num += 1;
}
  print "tot_slot_num= $tot_slot_num\n";
  return $tot_slot_num;
}

################################################################################################
##  generateGraphFromDistribution
################################################################################################
sub generateGraphFromDistribution {
my $refScreenEdges = shift;
my $refScreenNodeDegs = shift;
my $num_node=shift;
my $refNodes=shift;
my %nodes=%{$refNodes};
my $tot_slot_num = shift;

my $edge_number = $tot_slot_num / 2;

my %graph;
for (1..$edge_number){
  my @available_node;
  foreach my $node (keys %nodes){
    push(@available_node,$node) unless $nodes{$node} == 0 ;
  }
  Randomize(\@available_node);
  my $flag = 1;
  my $i = 0;
  while($flag){
    if (($i+1) > (scalar @available_node) ){  ## ($i+2)
      $i = 0;                                 ## there's a crazy pb ; it seems that an empty entry to %node is generated
      Randomize(\@available_node);            ## at some point in the script ... i cannot get why
    }
    my $node1 = $available_node[$i];
    my $node2 = $available_node[$i+1];
    ($node1,$node2) = sort{$a<=>$b}($node1,$node2);
    my $id = $node1."|".$node2;
    if ($graph{$id}[0]){
      $i++;   # $i, $i+1 are the current pair of nodes to be chosen
    }
    else{
      $flag = 0; # if the following $node1 and $node2 are paired, use the same randomized array to move to pair $i+2, $i+3
      $graph{$id}[0] = $node1;
      $graph{$id}[1] = $node2;
      #print "edge $graph{$id}[0]. $graph{$id}[1]\n";
      $nodes{$node1} --;
      $nodes{$node2} --;
    }
  }
}

 foreach my $id (keys %graph){
  unless (($graph{$id}[0] eq "") or ($graph{$id}[1] eq "")) {
    loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $graph{$id}[0], $graph{$id}[1]);
  }
}

############# rewrite ##################
#my @available_node;
#my $MaxNumOfTries=10;
#foreach my $node (keys %nodes){
#  push(@available_node,$node) unless $nodes{$node} == 0 ;
#}
#my $numOfTries=0;
#while (@available_node) {
#  Randomize(\@available_node);
#  my $node1 = $available_node[0];
#  Randomize(\@available_node);
#  my $node2 = $available_node[0];

#  my ($loaded, $isNewNode)=loadEdgeAndNodeLists($refScreenEdges, $refScreenNodeDegs, $node1, $node2);
#  $numOfTries++;
#  print "node picked $node1, $node2\n";
#  if ($numOfTries>$MaxNumOfTries) {last;}
#  if ($loaded) {
#    $numOfTries=0;
#    $nodes{$node1} --;
#    $nodes{$node2} --;
#    print "node loaded $node1, $node2\n";
#    my @newAvailableNodes;
#    foreach my $node (keys %nodes) {
#      push(@newAvailableNodes,$node) unless $nodes{$node} == 0 ;
#    }
#    @available_node=@newAvailableNodes;
#  }
#}

}

##################################################################################################
##   generateGML
##################################################################################################
sub generateGML{
  my $refintx = shift;
  my $refprot = shift;
  my $gmlfile = shift;
  my %intx = %{$refintx};
  my %prot = %{$refprot};

  ## node_gml_id and node_label are to be the same

  open (GML,">$gmlfile") || die ("can't open $gmlfile");

  print GML "Creator \"LEDA GraphWin\"\r\n";
  print GML "Version 1.5\r\n";
  print GML "graph [\r\n\r\n  label \"\"\r\n  directed 1\r\n\r\n";

  my $x = -200.0;
  my $y = -350.0;

  my %nodesMap;
  my $cnt=1;
  foreach my $node (keys %prot){
    $nodesMap{$node}=$cnt;
    $cnt++;
  }

  foreach my $node (keys %prot){
    print GML "  node [\r\n";
    print GML "    id $nodesMap{$node}\r\n";
    print GML "    label \"$node\"\r\n";
    print GML "      labelAnchor \"n\"\r\n";
    print GML "    graphics [\r\n";
    print GML "      x $x\r\n";
    print GML "      y $y\r\n";
    print GML "      w 27.9\r\n";
    print GML "      h 27.9\r\n";
    print GML "      type \"oval\"\r\n";
    print GML "      width 1.19\r\n";

    print GML "      fill \"#0000ff\"\r\n";
    print GML "      outline \"#000000\"\r\n";
    print GML "    ]\r\n";
    print GML "    LabelGraphics [\r\n";
    print GML "      type \"text\"\r\n";
    print GML "      fill \"#0000ff\"\r\n";
    print GML "      anchor \"n\"\r\n";
    print GML "    ]\r\n";
    print GML "  ]\r\n";
    $x += 0.1;
    $y += 0.1;
  }
  foreach my $edge (keys %intx){
    my ($i, $j)=split /\|/, $edge;
    print GML "  edge [\r\n";
    print GML "    source $nodesMap{$i}\r\n";
    print GML "    target $nodesMap{$j}\r\n";
    print GML "    graphics [\r\n";
    print GML "      type \"line\"\r\n";
    print GML "      arrow \"last\"\r\n";
    print GML "    ]\r\n";
    print GML "  ]\r\n";
  }
  print GML "]\r\n";

}


1;
