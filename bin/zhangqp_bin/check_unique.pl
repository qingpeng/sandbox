#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# check unique是否比到本身基因上
# 2005-2-1 10:20
# 
if (@ARGV<5) {
	print  "programm file_list file_in49 file_in21 file_out49 file_out21 \n";
	exit;
}
($file_list,$file_in49,$file_in21,$file_out49,$file_out21) =@ARGV;

open IN49,"$file_in49" || die"$!";
open IN21,"$file_in21" || die"$!";

open OUT21,">$file_out21" || die"$!";
open OUT49,">$file_out49" || die"$!";


open LIST,"$file_list" || die"$!";

#Ensembl Gene ID	Ensembl Transcript ID	RefSeq ID	LocusLink ID
#ENSG00000091129.6	ENST00000351718.2	NP_005001	4897
#ENSG00000091129.6	ENST00000351718.2	NM_005010	4897
#ENSG00000197245.1	ENST00000356363.1		
#ENSG00000146223.4	ENST00000304734.4	NP_940888	285855
#ENSG00000146223.4	ENST00000304734.4	NM_198486	285855


#ENSG00000136870.3       ENST00000339664.1       AF025772        NM_197977
#ENSG00000136870.3       ENST00000339664.1       U95992  NP_003443
#ENSG00000136870.3       ENST00000339664.1       U95991  NP_003443
#ENSG00000136870.3       ENST00000339664.1       U75454  NP_003443
#ENSG00000136870.3       ENST00000339664.1       AF025770        NP_003443
#ENSG00000136870.3       ENST00000339664.1       AF025771        NP_003443
#ENSG00000136870.3       ENST00000339664.1       AF025772        NP_003443
#ENSG00000136870.3       ENST00000339664.1       U95992  NM_003452
#ENSG00000136870.3       ENST00000339664.1       U95991  NM_003452
#ENSG00000136870.3       ENST00000339664.1       U75454  NM_003452


<LIST>;
my %refseq;
my %ensg;
my %embl;
my %refseq_of_enst;
my %embl_of_enst;
while (<LIST>) {
	chomp;
	@s =split/\t/,$_;
	if ($s[0] =~/(\w*)\.\d*/) {
		$ensg = $1;
	}
	if (defined $s[3]) {
		if ($s[3]=~/NM_*/) {
			$refseq = $s[3];
		}
	}
	if (defined $s[1]) {
		if ($s[1]=~/(\w*)\.\d*/) {
			$enst = $1;
		}
	}

	if (defined $s[2]) {
		$embl = $s[2];
	}

	${$refseq{$ensg}}{$refseq} = 1;
	${$embl{$ensg}}{$embl} = 1;
	${$ensg{$enst}}{$ensg} = 1;
}


@enst = keys %ensg;
foreach my $enst (@enst) {
	@ensg = keys %{$ensg{$enst}};
	foreach my $ensg (@ensg) {
		@refseq = keys %{$refseq{$ensg}};
		foreach $refseq (@refseq) {
			${$refseq_of_enst{$enst}}{$refseq} = 1;
		}
		@embl = keys %{$embl{$ensg}};
		foreach $embl (@embl) {
			${$embl_of_enst{$enst}}{$embl} = 1;
		}
	}
}



#NM_000015	ENST00000286479	1	69	931	999	69
#NM_000595	ENST00000309399	1	54	1075	1128	54
#NM_002895	ENST00000344359	1	69	3033	3101	69
#NM_002895	ENST00000262877	1	69	3033	3101	69
#NM_001539	ENST00000337863	1	35	1207	1241	35


while (<IN21>) {
	chomp;
	@s =split/\t/,$_;
	if ($s[0] =~/NM_/) {
	
	if (exists ${$refseq_of_enst{$s[1]}}{$s[0]}) {
		print OUT21 "Y\t$_\n";
	}
	else {
		print OUT21 "-\t$_\n";
	}

	}
	else {
		if (exists ${$embl_of_enst{$s[1]}}{$s[0]}) {
			print OUT21 "Y\t$_\n";
		}
		else {
			print OUT21 "-\t$_\n";
		}
	}
}


#NM_000595	69	1	54	1075	1128	1386	 107	2e-23	54/54	100	ENST00000309399
#NM_002895	69	1	69	3033	3101	3243	 137	2e-32	69/69	100	ENST00000344359
#NM_002895	69	1	69	3033	3101	4270	 137	2e-32	69/69	100	ENST00000262877
#NM_001539	69	1	69	1207	1276	2242	 123	3e-28	69/70	98	ENST00000337863
#NM_001539	69	1	69	1267	1335	1458	 113	3e-25	66/69	95	ENST00000360253

while (<IN49>) {
	chomp;
	@s = split /\t/,$_;
	if ($s[0] =~/NM_/) {
	
	if (exists ${$refseq_of_enst{$s[11]}}{$s[0]}) {
		print OUT49 "Y\t$_\n";
	}
	else {
		print OUT49 "-\t$_\n";
	}

	}
	else {
		if (exists ${$embl_of_enst{$s[11]}}{$s[0]}) {
			print OUT49 "Y\t$_\n";
		}
		else {
			print OUT49 "-\t$_\n";
		}
	}
}


