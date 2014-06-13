#!/usr/bin/perl
#用来定义麂子上和人对应的位置

if (@ARGV<2) {
	print  "programm $file_multi file_solar file_out \n";
	exit;
}
($file_multi,$file_solar,$file_out) =@ARGV;
open MULTI,"$file_multi" || die "$!";
open SOLAR,"$file_solar" || die"$!";
open OUT,">$file_out" || die"$!";

#a score=5230.0
#s hg17.chr8     134532012 46 + 146274826 AAAGCTGTCTGCCCCTGCCTGGATCCC----------------CACCCCGGCCC--------------CTCACCAT
#s panTro1.chr7  137510921 46 + 149542033 AAAGCTGTCTGCCCCTGCCTGGGTCCC----------------CACCCCGGCCC--------------CTTACCAT
#s mm5.chr5        8356606 46 - 149219885 AAAGTAGAATGATCCTATCCAGATACT----------------CACCCCGCCCC--------------CTCCCCAT
#s canFam1.chr13  32912793 76 +  66159989 GGTCTTCTGTGCTCCAGGAAGCGTACCAGGCACAGGCGGGGAGCTCCCCGGCCCTGTCAAGAGGGAGGCTCACTGC
#



while (<MULTI>) {
	chomp;
    if (/^s/) {
		@s=split /\s+/,$_;
		@ss=split ".",$s[1];
		$spec=$ss[0];
		$start=$s[2];
		$align_length=$s[3];
		$direction=$s[4];
		$chr_length=$s[5];
		if ($direction eq "-") {
			$start= $chr_length-$start-$align_length+2;
		}
		if (/hg17/) {
			$h_chro=$ss[1];
			push @{$human{$h_chro}},$start;
		}
		elsif (/canFaml/) {
			$d_chro=$ss[1];
		    $dog_info = $d_chro."-".$start;
			push @{$dog{$h_chro}},$dog_info;
		}
		if (/mm5/) {
			$m_chro=$ss[1];
			$mm_info = $m_chro."-".$start;
			push @{$mouse{$chro}},$mm_info;
		}

    }

}
#bsab	64518	1431	59553	+	chr3	199505740	12173310	12290136	33	4951	1431,1465;3244,3393;4115,4161;9209,9270;10785,10839;12209,12466;12736,13000;17014,17132;17227,17680;17892,18301;18664,18764;20877,21170;24167,24360;31255,31479;31507,31555;32379,32461;33102,33317;34459,34632;34908,34972;35268,35385;35434,35501;38857,38961;39786,39945;40047,40096;41635,41794;41962,42173;46655,46713;51486,51574;54725,54940;55094,55501;55727,56300;56674,56715;59358,59553;	12173310,12173344;12177957,12178105;12179331,12179377;12189357,12189418;12192522,12192576;12194053,12194316;12196965,12197232;12201777,12201894;12201984,12202438;12207056,12207460;12207830,12207930;12210007,12210300;12217473,12217666;12239255,12239478;12239497,12239545;12243953,12244035;12244475,12244690;12245805,12245974;12246087,12246151;12246471,12246587;12246640,12246707;12252041,12252144;12252926,12253082;12253181,12253230;12255434,12255592;12255761,12255973;12261345,12261403;12270642,12270730;12280155,12280372;12280521,12280931;12284448,12285023;12285874,12285915;12289945,12290136;	+33;+129;+42;+54;+49;+224;+223;+103;+375;+340;+91;+259;+169;+207;+45;+69;+191;+148;+57;+98;+63;+91;+138;+46;+131;+193;+53;+75;+188;+360;+495;+39;+173;

while (<SOLAR>) {
	chomp;
	@info=split /\t+/,$_;
	$bac=$info[0];
	$human_chr=$info[5];
	@muntjac_ps=split ";",$info[11];
	@human_ps=split ";",$info[12];
	for ($n=0 ;$n<@muntjac_ps ;$n++) {
		@muntjac_start=split ",",$muntjac_ps[$n];
		@human_start=split ",",$human_ps[$n];
		push @{$hm_start{$human_chr}},$human_start[0];
		$deer_info = $bac."-".$muntjac_start[0];
		push @{$deer_start{$human_chr}},$deer_info;
	}
}

foreach my $chro (keys %human) {
	for ($k=0; $k<@{$human{$chro}};$k++) {
		$n=0;
		$min=10000;
		for ($m=0;$m<@{$hm_start{$chro}};$m++) {
			if (abs(${$human{$chro}}[$k]-${$hm_start{$chro}}[$m])<$min) {
				$min=abs(${$human{$chro}}[$k]-${$hm_start{$chro}}[$m]);
				$min_position=$m;
			}
		}
		$deer_start = ${$deer_start{$human_chr}}[$min_position];
		print OUT "$chro\t${$human{$chro}}[$k]\t${$human{$chro}}[$k]\t


	push @{$muntjac{$human_chr}},$deer_start[$min_position];


	}

}