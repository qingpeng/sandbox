#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

# transform snap output file to .location file 
# 2004-8-17 11:14
# 
if (@ARGV<2) {
	print  "programm file_in file_out \n";
	exit;
}
($file_in,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";






# cluster6754_2_Step2	765	254	765	-	chr4	40267076	35964808	35965331	2	165	254,390;718,765;	35965331,35965195;35964855,35964808;	-119;-46;	185
# cluster135116_-2_Step1	483	14	483	+	chr1	199385307	199380691	199385307	2	418	14,303;300,483;	199380691,199380980;199385124,199385307;	+250;+171;	470
# rssp28_e14.y1.abd	634	9	634	+	chr16	68738164	68729191	68738164	3	459	9,128;127,360;464,634;	68729191,68729310;68737657,68737890;68737994,68738164;	+108;+204;+149;	523


# #Read AlignmentLen Read_start ------ Read_end Chromosome AlignmentLen Chr_start ------ Chr_end |Direction
# A01.abd.ADD356            479	  10 ------  488	chr15      526	  46147466 ------   46147991	|-
# A02.abd                   563	  51 ------  613	chr5       613	  95309442 ------   95310054	|-
# A02.abd.ADD2332           605	 146 ------  750	chr5       668	  95309387 ------   95310054	|-
# A04.abd.ADD3039           240	   1 ------  240	chr16      240	  64233797 ------   64234036	|+
print OUT "#Read AlignmentLen Read_start ------ Read_end Chromosome AlignmentLen Chr_start ------ Chr_end |Direction\n";
while (<IN>) {
	chomp;
	@s = split /\t/,$_;
	$est_id = $s[0];
	$direction = $s[4];
	$chr = $s[5];
	$q_pos = $s[11];
	$s_pos = $s[12];
	@s_q_pos = split ";",$q_pos;
	@s_s_pos = split ";",$s_pos;
	for (my $k = 0;$k<scalar @s_q_pos;$k++) {
		$count = $k+1;
		$read  = $est_id."-".$count;
		@ss_q_pos = split ",",$s_q_pos[$k];
		@ss_s_pos = split ",",$s_s_pos[$k];
		$readStart = $ss_q_pos[0];
		$readEnd = $ss_q_pos[1];
		$readAlignmentLength = $readEnd-$readStart+1;
		if ($direction eq "+") {
			$chrStart = $ss_s_pos[0];
			$chrEnd = $ss_s_pos[1];
			$chrAlignmentLength = $chrEnd - $chrStart +1;
		}
		else {
			$chrStart = $ss_s_pos[1];
			$chrEnd = $ss_s_pos[0];
			$chrAlignmentLength = $chrEnd - $chrStart +1;
		}

	printf OUT ("%-25s%4d\t%4d ------ %4d\t%-10s%4d\t%10d ------ %10d\t\|%s\n",$read,$readAlignmentLength,$readStart,$readEnd,$chr,$chrAlignmentLength,$chrStart,$chrEnd,$direction);

	
	}
}
