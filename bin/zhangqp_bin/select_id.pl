#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm $file_mouse $file_dog file_in file_out \n";
	exit;
}
($file_mouse,$file_dog,$file_in,$file_out) =@ARGV;
open MOUSE,"$file_mouse" || die "$!";
open DOG,"$file_dog"|| die "$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

#ENSG00000020577	ENST00000357634	ENSP00000350261	346	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
#ENSG00000020577	ENST00000251091	ENSP00000251091	346	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
#ENSG00000020577	ENST00000321411	ENSP00000319786	170	ENSMUSG00000021838.3	0.0506757	ENSMUSP00000022386	ENSCAFG00000014940.1	ENSCAFP00000022017
#ENSG00000054654	ENST00000312125	ENSP00000308694	856	ENSMUSG00000054397.2	0.2683621	ENSMUSP00000069066	ENSCAFG00000015819.1	ENSCAFP00000023286
#ENSG00000054654	ENST00000312125	ENSP00000308694	856	ENSMUSG00000058969.1	0.1832669	ENSMUSP00000079352	ENSCAFG00000015819.1	ENSCAFP00000023286

while (<MOUSE>) {
	chomp;
	@info=split /\t/,$_;
	$mouse{$info[0]}=$info[1];
}
while (<DOG>) {
	chomp;
	@sp=split /\t/,$_;
	$dog{$sp[0]}=$sp[1];
}

while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	$human_gene=$s[0];
	$human_pep=$s[2];
	$mouse_pep=$s[6];
	$dog_pep=$s[8];
	if ($mouse_pep ne "" && $dog_pep ne "" && $_ ne "" ) {
		if (!exists $line{$human_pep}) {
			$line{$human_pep}=$_;
		}
		else {
			@ss= split /\t/,$line{$human_pep};
			if ($mouse{$mouse_pep} > $mouse{$ss[6]}) {
				$line{$human_pep}=$_;
			}
			elsif ($mouse{$mouse_pep}= $mouse{$ss[6]}){
				if ($dog{$dog_pep} > $dog{$ss[8]}) {
					$line{$human_pep}=$_;
				}
			}
		}
	}


}
foreach $subject (keys %line) {
	@ss=split /\t+/,$line{$subject};
	$human_pep_length=$ss[3];
	if (!exists $l{$ss[0]}) {
		$l{$ss[0]}=$line{$subject};
	}
	else {
		@sss=split /\t/,$l{$ss[0]};
		if ($human_pep_length > $sss[3]) {
			$l{$ss[0]}=$line{$subject};
		}
	}
}

foreach $id (keys %l) {
	print OUT "$l{$id}\n";
}