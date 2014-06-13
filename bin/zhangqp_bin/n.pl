 #!/usr/local/bin/perl
open(INPUT,"/disk10/prj0326/zhangqp/MaQian/AIV/ha_need.sep") || die; 
while(<INPUT>){




###############BASE A###########   
while ($inputline =~ /\[|A|]\S+/g) {
    $wordA = $&;
    # remove punctuation
   $wordlistA{$wordA} += 1;
 
 
 foreach $A (keys(%wordlistA)) {
	$a=$wordlistA{$A};
 print ("A: $wordlistA{$A}\n");

}


###############BASE T###########
while ($inputline =~ /\[|T|]\S+/g) {
    $wordT = $&;
    # remove punctuation
   $wordlistT{$wordT} += 1;
 }
 
foreach $T (keys(%wordlistT)) {
	$t = $wordlistT{$T};
 print ("T: $wordlistT{$T}\n");


 }

############BASE C################
while ($inputline =~ /\[|C|]\S+/g) {
    $wordC = $&;
    # remove punctuation
   $wordlistC{$wordC} += 1;
 }
 
foreach $C (keys(%wordlistC)) {
	$c=$wordlistC{$C};
 print ("C: $wordlistC{$C}\n");


 }

#############BASE G################
while ($inputline =~ /\[|G|]\S+/g) {
    $wordG = $&;
    # remove punctuation
   $wordlistG{$wordG} += 1;
 }
 
foreach $G (keys(%wordlistG)) {
    $g=$wordlistG{$G};
 print ("G: $wordlistG{$G}\n");


 }


 $Z=$t+$a+$c+$g;
 print "$Z\n";
 $GC=($c+$g)/$Z;
 print "GC:$GC\n";

}  

