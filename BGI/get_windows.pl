#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 生成 windows 必须都位于同一染色体上
# 2005-4-6 16:04
# 
if (@ARGV<3) {
	print  "programm file_in file_repeat file_out \n";
	exit;
}
($file_in,$file_repeat,$file_out) =@ARGV;

open IN,"$file_in" || die"$!";

open OUT,">$file_out" || die"$!";


#chr10	77630083	chr4-29529552	chr14-19005178	bsaf-39901	5
#chr10	77639589	chr4-29537106	chr14-19014251	bsaf-47137	84
#chr10	77641042	chr4-29538531	chr14-19015782	bsaf-47786	209
#chr12	105616127	chr10-35275166	chr10-84535972	bsax-5458	56
#chr12	105618886	chr10-35272472	chr10-84538959	bsax-6147	92
#chr12	105627997	chr10-35263304	chr10-84547647	bsax-7888	373
#chr12	105634289	chr10-35258985	chr10-84551579	bsax-9942	163
	$last_dog_chr = "";
	$last_mouse_chr = "";
	$last_deer_chr = "";
	$last_human_chr ="";


while (<IN>) {
	chomp;
	@s =split/\t/,$_;
	@ss = split "-",$s[2];
	@sss = split "-",$s[3];
	@ssss = split "-",$s[4];
	if ($s[0] eq $last_human_chr && $ss[0] eq $last_dog_chr && $sss[0] eq $last_mouse_chr && $ssss[0] eq $last_deer_chr) {

		print OUT "## $last_human_chr\t$last_human_pos\t$s[1]\t$last_dog_chr\t$last_dog_pos\t$ss[1]\t$last_mouse_chr\t$last_mouse_pos\t$sss[1]\t$last_deer_chr\t$last_deer_pos\t$ssss[1]\n";
#bsab_muntjac	11751	11907	+	L3	LINE/CR1
#bsab_dog_chr20	9122250	9122494	+	L3	LINE/CR1
#bsab_mouse_chr6	115643125	115643251	+	Charlie4	DNA/MER1_type
#bsab_human_chr3	12174459	12174769	C	L2	LINE/L2

		open REPEAT,"$file_repeat" || die"$!";
		while (<REPEAT>) {
			chomp;
			@ks = split /\t/,$_;
			if ($ks[0] =~/(.*)_muntjac/) {
				$deer_chr = $1;
				if ($deer_chr eq $last_deer_chr){
					if ($last_deer_pos > $ssss[1]) {
						$w_deer_start = $ssss[1];
						$w_deer_end = $last_deer_pos;
					}
					else {
						$w_deer_start = $last_deer_pos;
						$w_deer_end = $ssss[1];
					}
					if ($ks[1] >$w_deer_start && $ks[2] <$w_deer_end) {
						print OUT "			$_\n";
					}

				}

			}
			elsif ($ks[0] =~/.*_dog_(.*)/) {
				$dog_chr = $1;
				if ($dog_chr eq $last_dog_chr){
					if ($last_dog_pos > $ss[1]) {
						$w_dog_start = $ss[1];
						$w_dog_end = $last_dog_pos;
					}
					else {
						$w_dog_start = $last_dog_pos;
						$w_dog_end = $ss[1];
					}
					if ($ks[1] >$w_dog_start && $ks[2] <$w_dog_end) {
						print OUT "			$_\n";
					}

				}

			}
			elsif ($ks[0] =~/.*_mouse_(.*)/) {
				$mouse_chr = $1;
				if ($mouse_chr eq $last_mouse_chr){
					if ($last_mouse_pos > $sss[1]) {
						$w_mouse_start = $sss[1];
						$w_mouse_end = $last_mouse_pos;
					}
					else {
						$w_mouse_start = $last_mouse_pos;
						$w_mouse_end = $sss[1];
					}
					if ($ks[1] >$w_mouse_start && $ks[2] <$w_mouse_end) {
						print OUT "			$_\n";
					}

				}

			}
			elsif ($ks[0] =~/.*_human_(.*)/) {
				$human_chr = $1;
				if ($human_chr eq $last_human_chr){
					if ($last_human_pos > $s[1]) {
						$w_human_start = $s[1];
						$w_human_end = $last_human_pos;
					}
					else {
						$w_human_start = $last_human_pos;
						$w_human_end = $s[1];
					}
					if ($ks[1] >$w_human_start && $ks[2] <$w_human_end) {
						print OUT "			$_\n";
					}

				}

			}

		}
		close REPEAT;

	}
	
	
	$last_human_chr = $s[0];
	$last_human_pos = $s[1];
	$last_dog_chr = $ss[0];
	$last_dog_pos = $ss[1];
	$last_mouse_chr = $sss[0];
	$last_mouse_pos = $sss[1];
	$last_deer_chr = $ssss[0];
	$last_deer_pos = $ssss[1];

}