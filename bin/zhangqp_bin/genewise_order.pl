#!/usr/bin/perl
#ENSP00000288816	592	325	583	+	bsbq1	76397	45416	49995	5	257	325,353;349,375;375,422;481,538;546,583;	45416,45502;45579,45659;45773,45916;49614,49784;49882,49995;	+41;+39;+88;+54;+44;
#ENSP00000348148	392	2	250	-	bsah	94921	55555	56395	2	68	2,157;149,250;	56395,55925;55845,55555;	-37;-33;
#ENSP00000346087	504	232	481	+	bsay	49005	8896	9702	1	60	232,481;	8896,9702;	+60;
#ENSP00000263975	735	134	340	+	bsbq1	76397	45410	49781	4	168	134,170;165,186;186,233;271,340;	45410,45520;45594,45659;45773,45916;49608,49781;	+24;+33;+62;+59;
#ENSP00000312769	301	8	97	-	bsah	94921	74567	74888	2	72	8,47;47,97;	74888,74769;74701,74567;	-34;-39;
#ENSP00000348904	296	8	97	-	bsah	94921	74567	74888	2	72	8,47;47,97;	74888,74769;74701,74567;	-34;-39;
#ENSP00000253546	306	11	305	+	bsba	93397	58227	59325	4	418	11,36;38,51;72,175;164,305;	58227,58304;58372,58413;58631,58939;58903,59325;	+30;+39;+156;+212;
#E

if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";

while (<IN>) {
	chomp;
	@s= split /\t/,$_;
	$pep_name=$s[0];
	$direction=$s[4];
	$bac_name=$s[5];
	if ($direction eq "+") {
		print OUT "\/usr\/local\/genome\/wise2.2.0\/genewise\t\-splice\tflat\tpep\/$pep_name\.fa\tbac\/$bac_name\.bac\t\-quiet -genesf -gff -pretty -para -pseudo \>out\/$pep_name\_$bac_name\ &\n";
				
	}
	else {
		print OUT "\/usr\/local\/genome\/wise2.2.0\/genewise\t\-splice\tflat\tpep\/$pep_name\.fa\tbac\/$bac_name\.bac\t\-quiet -genesf -gff -pretty -para -pseudo -trev\>out\/$pep_name\_$bac_name\ &\n";
	}
}
