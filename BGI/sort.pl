
open IN,"restore.list" || die"$!";

while (<IN>) {
	chomp;
	print  "more  $_\|~/bin/sort -k1,1 -k9,9g \|awk \'\$4-\$3>100\'\|perl -ane \'\{if \(\$count\{\$F[0]}<5)\{print \$_;\$count\{\$F[0]}++;}}\'\|sort -k12,12 -k5,5n>$_.sort\n";
}

