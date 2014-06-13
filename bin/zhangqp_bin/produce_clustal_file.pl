#!/usr/bin/perl
#programmer:zhouqi

if (@ARGV<3) {
	print  "programm human_mouse_dog_chick muntjac linklist\n";
	exit;
}
($human_mouse_dog_chick_in,$muntjac_in,$list) =@ARGV;

open HMDC,"$human_mouse_dog_chick_in" || die"$!";
open MUNTJAC, "$muntjac_in" || die "$!";
open LIST, "$list" || die "$!";
$/=">";
#	>14|ENSG00000020577|ENST00000305831|ENSP00000306381
#ATGAAACTGCTGCCCAAAATCCTGGCTCACTCTATTGAACACAACCAGCACATTGAGGAGAGCAGGCAGCTGCTGTCCTA
#TGCTTTGATACATCCAGCCACTTCGTTAGAAGACCGTAGTGCTTTAGCCATGTGGCTGAATCACTTGGAGGACCGCACGT

#>bsbq1_gw1_1 ENSP00000237305 + bsbq1:43818,43934;44231,44420;45413,45504;45596,45658;45775,45913;46921,47001;48121,48228;49647,49781;
#TCCCCGTCCCCCAGTCCCACCGACTCCAAGCGCTGTTTCTTCGGGGCAAGCCCTGGACGACTACACATCTCGGACTTCAGCTTCCTCATGGTTCTAGGAA
#AAGGCAGTTTTGGGAAGGTGATGCTGGCCGAGCGCCGGGGTTCCGATAAGCTCTACCCCATCAAGATCCTGAAAAAAGAGGTGAGTCGCCCAGGATGACA

#ENSG00000028528	ENST00000261889	ENSP00000261889	522	ENSMUSG00000032382.2	0.0588513	ENSMUSP00000034946	ENSCAFG00000017041.1	ENSCAFP00000025091	ENSGALG00000002189.1	ENSGALP00000003420
#ENSG00000107643	ENST00000342796	ENSP00000345944	428	ENSMUSG00000021936.3	0.0493934	ENSMUSP00000022504	ENSCAFG00000006551.1	ENSCAFP00000009814	ENSGALG00000006109.1	ENSGALP00000009848

while (<HMDC>) {
	chomp;
		if ($_ ne '') {
			@in=split(/\n/,$_,2);
			$in[0]=~s/\s+\S+//g;
			$in[0]=~s/\s+|\n//g;
			$in[1]=~s/\s+|\n//g;
			$in[1]=~s/ //g;
			$in[1]=uc($in[1]);
			@s=split /\|/,$in[0];
#			print "$in[0]\n";
			$pep_name=$s[3];
			print $pep_name;
			#print "$in[0]+++++++\n$in[1]\n";
			$hash_seq{$pep_name}=$in[1];#get chromosome sequence;
		}

}



while (<MUNTJAC>) {
	chomp;
		if ($_ ne '') {
			@inn=split(/\n/,$_,2);
			$inn[1]=~s/\s+|\n//g;
			$inn[1]=~s/ //g;
			$inn[1]=uc($inn[1]);
			@ss=split /\s/,$inn[0];
			$pr_name=$ss[1];
#			print "$pr_name\n";
			$muntjac{$pr_name}=$inn[1];#get chromosome sequence;
			$bac_name{$pr_name}=$ss[0];
		}
		
}
$/="\n";
while (<LIST>) {
	chomp;
	@p=split /\t/,$_;
	$human_pep=$p[2];
	$mouse_pep=$p[6];
	$dog_pep=$p[8];
	$chick_pep=$p[10];
	$list{$human_pep}=[$mouse_pep,$dog_pep,$chick_pep];


}
foreach $name (keys %list) {
	$file_out=$name.".clustal";
#	print "$name\n";
	open OUT,">$file_out" || die "$!";
	print OUT ">$name\n";
	print OUT "$hash_seq{$name}\n\n";
	print OUT ">$list{$name}->[0]\n";
	print OUT "$hash_seq{$list{$name}->[0]}\n\n";
	print OUT ">$list{$name}->[1]\n";
	print OUT "$hash_seq{$list{$name}->[1]}\n\n";
	print OUT ">$list{$name}->[2]\n";
	print OUT "$hash_seq{$list{$name}->[2]}\n\n";
	print OUT ">$bac_name{$name}_$name\n";
	print OUT "$muntjac{$name}\n\n";

}