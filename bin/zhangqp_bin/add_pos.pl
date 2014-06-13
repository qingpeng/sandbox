#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn
# 综合信息，加入比上的各个pep 的位置信息
if (@ARGV<5) {
	print  "programm refgene(refGene.txt) pep(refGene_and_transcript.psl.no_redundancy.list.pep) transcript( transcript.txt.table) blastx(rbsah_contig_human_pep.blastx.eblastn) file_out \n";
	exit;
}
($refgene_file,$pep_file,$trans_file,$blastx_file,$file_out) =@ARGV;

open OUT,">$file_out" || die"$!";

##refGene.txt
##	NM_016547	chr1	-	1058369	1073469	1059107	1070231	7	1058369,1059895,1060206,1064681,1065269,1069905,1073329,	1059242,1060071,1060365,1064795,1065406,1070384,1073469,
#
open REFGENE,"$refgene_file" || die"$!";
while (<REFGENE>) {
	@s = split /\t/,$_;
	$info{$s[0]}=$s[1]."\t".$s[3]."\t".$s[4];
#	print  "info\t$s[0]\t$info{$s[0]}\n";
#	exit;
}
close REFGENE;
#
#
##	>gi|14780904|ref|NP_065917.1| (NM_020866) kelch-like 1 protein; kelch-like 1; kelch (Drosophila)-like 1 [Homo sapiens]
## refGene_and_transcript.psl.no_redundancy.list.pep
open PEP,"$pep_file" || die"$!";
while (<PEP>) {
	if ($_=~/(NP_\d+)\..+\s\((NM_\d+)\)/) {
		$np=$1;
		$nm=$2;
		$info{$np} = $info{$nm}."\t".$nm;
#	print  "info\t$nm\t$np\t$info{$np}\n";
#	exit;
	}
}

# transcript.txt.table
# 2	core	ensembl	ensembl	15631	ENST00000334162[5]	1	10[7]	22559926[8]	22560141[9]	1	22559926	22560141	15631	ENSP00000334595[14]	1	11572	ENSG00000186780	1	216	111607			

open TRANS,"$trans_file" || die"$!";
while (<TRANS>) {
	@s = split /\t/,$_;

	$chr_id = "chr".$s[7];
	$info{$s[14]} = $chr_id."\t".$s[8]."\t".$s[9]."\t".$s[5];
#	print  "info\t$s[14]\t$info{$s[14]}\n";
#	exit;
}

# rbsah_contig_human_pep.blastx.eblastn
#	rbsah0/rbsah0.fa.Contig19	888	886	311	824	1003	1466	41.2	7e-04	56/194	28	gi|4502951|ref|NP_000081.1|
#	rbsah0/rbsah0.fa.Contig21	1010	695	1000	459	554	753	40.0	0.002	31/103	30	Translation:ENSP00000336184

open BLASTX,"$blastx_file" || die"$!";
$null = <BLASTX>;
$null = 1;
while (<BLASTX>) {
	chomp;
	@s = split /\t/,$_;
	$id = $s[-1];
	if ($id =~/(NP_\d+)\./) {
		$pep_id = $1;
	}
	else {
		if ($id =~/Translation:(\S+)/) {
			$pep_id = $1;
		}
	}
#	print  "$pep_id\n";
if (exists $info{$pep_id}) {

	$new_line = $_."\t".$info{$pep_id};
	print OUT "$new_line\n";
}
}

