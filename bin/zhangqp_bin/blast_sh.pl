($file)=@ARGV;
#`blastall -p blastn -i $file -d /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Genome/Ensembl/human.fa -e 1e-2 -o $file.human_genome.blastn &`;
`blastall -p blastx -i $file -d /disk1/prj11/temp_project/zhangjg/Sci2004-4_BirdFlu/zhangqp/Public_Data/Human_Pep/Human_DB/refGene_and_transcript.psl.no_redundancy.list.pep -e 1e-2 -o $file.human_pep.blastx &`;

