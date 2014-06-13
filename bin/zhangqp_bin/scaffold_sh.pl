#!/usr/local/bin/perl -w
# programmer: zhangqp
# e-mail:zhangqp@genomics.org.cn

if (@ARGV<1) {
	print  "programm dir_list  \n";
	exit;
}
($dir_list) =@ARGV;

# bsan/
# bsao/
# bsap/
# bsaq/

open LIST,"$dir_list" || die"$!";
while (<LIST>) {
	chomp;
	@s = split /\//,$_;
	$dir = $s[0];


`perl Scaffold_bin/format_phrap_out_list.pl $dir/phrap.out.list $dir/phrap.out.list.forScore`;

`perl Scaffold_bin/Contig_Scoring_Update_2.pl -i $dir/phrap.out.list.forScore -insert insert.file -o $dir/phrap.out.list.forScore.score`;

`perl Scaffold_bin/Contig_Grouping_Update_2.3.pl -s $dir/phrap.out.list.forScore.score -o $dir/phrap.out.list.forScore.score.group`;


`more $dir/phrap.out.list.forScore |grep "Contig"|perl -ane '\{@s = split /\\\./,\$F\[0];print "\$s\[0]\\t\$F\[3]\\n"}'>$dir/contig.length`;

`perl Scaffold_bin/Scaffold_create.pl -i $dir/phrap.out.list.forScore.score.group -l $dir/contig.length -o $dir/scaffold.out`;

`more $dir/$dir.fa.contigs|perl -ne '\{if (\$_=~/\^>\\S+\(Contig\\d+)/)\{\$s = \$1;print ">\$s\\n";}else \{print "\$_";}}'>$dir/$dir.fa.p.contigs`;
`more $dir/$dir.fa.contigs.qual|perl -ne '\{if (\$_=~/\^>\\S+\(Contig\\d+)/)\{\$s = \$1;print ">\$s\\n";}else \{print "\$_";}}'>$dir/$dir.fa.p.contigs.qual`;

`perl Scaffold_bin/get_scaffold_seq_new.pl $dir/scaffold.out $dir/$dir.fa.p.contigs $dir/$dir.scaffold.fa`;


}
