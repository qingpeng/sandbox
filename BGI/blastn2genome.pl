#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<1) {
	print  "programm dir_list \n";
	exit;
}
($dir_list) =@ARGV;

open IN,"$dir_list" || die"$!";

while (my $line = <IN>) {
	chomp $line;################# 路径可能需要修改#####################
chop $line;
print	"blastall -p blastn -i $line/$line.scaffold.fa -d /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Genome/Ensembl/human.fa -e 1e-2 -o $line/$line.scaffold.human.1e-2.blastn &\n";
print  "blastall -p blastx -i $line/$line.scaffold.fa -d /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Pep/Human_DB/refGene_and_transcript.psl.no_redundancy.list.pep -e 1e-2 -o $line/$line.scaffold.human.1e-2.blastx &\n";
print  "wait\n";
}
close IN;

open IN,"$dir_list" || die"$!";

while (my $line = <IN>) {
	chomp $line;
chop $line;
print	"perl /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/bin/EblastN.pl -i $line/$line.scaffold.human.1e-2.blastn -o $line/$line.scaffold.human.1e-2.blastn.EblastN \n";
print	"perl /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/bin/EblastN.pl -i $line/$line.scaffold.human.1e-2.blastx -o $line/$line.scaffold.human.1e-2.blastx.EblastN \n";
}
close IN;

