#!/usr/local/bin/perl 
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# pick certain sequence from nr database by name in list
# 2004-3-10 20:51

# just for this project!
# 
# 2004-6-17 13:48
# 不具有通用性
# 
# nr /nt fasta file
# >gi|46366704|ref|ZP_00228915.1| COG4247: 3-phytase (myo-inositol-hexaphosphate 3-phosphohydrolase) [Kineococcus radiotoler
# ans SRS30216]
# MPFTPHVPTAPRARRGRGPAVTAGVLALTLLPLTGAAATGPDVRWATTTATAQTPQVFDDEAGGDADADDPALWVSPTAP
# ADSVLLGTLKNGGLDVYGLDGSRLQHLDVAPTPDGAEEGSRYNNVDVVRGARLGGRVVDLAVVSDRGRDRLRLFEIDPRG
# AAAGAEVLRDVTAADAAPVFNTPETAVDEQRNAYGLAAGLAPDGGVQVLTTRRNTTEFAVLELVPAADGTVGYRQVSRQA
# LPAAFTLPGGSTWAPCEEPGEGPQAEGVVHDAVGGAWFVAQEDVGIWRITVDGDRATSRQLVDTVRGFGVPATYDEDTET
# CRVTGADPGVGGTHLSADAEGLTLLRGGDGAGYLLASSQGDSTFAAYALEPGPDAPPRYVGGFSVVDGAPAAEGGPAVDG
# VQHSDGATLTTADLGPAFPHGVFVSHDGEAMPTATGEDGSDRVATNFKLVPLERITAPLGLTR
# >gi|3243069|gb|AAC23899.1| cytochrome P450 hydroxylase [Streptomyces sclerotialus]
# LLIAGHETTANMISLGTYTLLRHPDRLAELRADPGLAPAAVEELLRMLSIADGMLRVATEDIEAGGTVIRAGDGVIFGTS
# VINRDETVYTDPDALDWHRPARHHVAFGFGIHQCLGQNL


# list file
# ref|NP_777225.1|	1e-73	p97 protein [Bos taurus] dbj|BAA20065.1| bucentaur [Bos taurus]
# ref|NP_921277.1|	0.0	Transposase of Tn10 [Oryza sativa (japonica cultivar-group)] gb|AAK98750.1| Transposase of Tn10 [Oryza sativa] gb|AAP53564.1| Transposase of Tn10 [Oryza sativa (japonica cultivar-group)]
 
# 
# 2004-4-12 14:07

if (@ARGV<3) {
	print  "programm fasta_file list_file file_out \n";
	exit;
}
($file_in,$file_list,$file_out) =@ARGV;


open IN,"$file_in" || die"$!";
open LIST,"$file_list" || die"$!";
open OUT,">$file_out" || die"$!";


while (<LIST>) {
	chomp;
	$title = $_;
	@s = split /\t/,$_;
#	$title=~s/\s//g;
	$mark{$s[1]} = 5;
}

while (<IN>) {
	chomp ;
# >gi|46366704|ref|ZP_00228915.1|
	if ($_ =~/>\w+\|\d+\|(\S+)\s+/) {
		$title = $1;
#		print  "title==$title\n";
		if ( $mark{$title}==5) {
			$get{$title} = 5;
			$yes = 1;
			print OUT "$_\n";
		}
		else {
			$yes = 0;
		}
	}
	else {
		if ($yes == 1) {
			print OUT "$_\n";
		}
	}
	
}

print  "items in list not picked!!\n";
foreach my $key (keys %mark) {
	unless ($get{$key}==5) {
		print  "$key\n";
	}
}