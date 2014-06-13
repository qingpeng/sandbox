DIR=$1

cp ../Phrap/$DIR/$DIR.fa ./$DIR/assemble/
mv ./$DIR/assemble/$DIR.fa ./$DIR/assemble/$DIR.reads
cp ../Phrap/$DIR/$DIR.fa.singlets ./$DIR/assemble/
mv ./$DIR/assemble/$DIR.fa.singlets ./$DIR/assemble/$DIR.phrap.singlets
cp ../Final/$DIR/Scaffold/$DIR.phrap.scaffold ./$DIR/assemble/
cp ../Final/$DIR/Scaffold/$DIR.join.* ./$DIR/assemble/
cp ../Final/$DIR/SVG/$DIR.*.svg ./$DIR/annotation/
cp ../Final/$DIR/Fgenesh/$DIR.fgenesh.aa ./$DIR/annotation/
cp ../Final/$DIR/Fgenesh/$DIR.fgenesh.na ./$DIR/annotation/
cp ../Final/$DIR/genewise/GW.*  ./$DIR/annotation/
cp ../Final/$DIR/Hit_Gene/$DIR.human_gene.aa   ./$DIR/annotation/
mv ./$DIR/annotation/GW.na ./$DIR/annotation/$DIR.humangenewise.na
mv ./$DIR/annotation/GW.aa ./$DIR/annotation/$DIR.humangenewise.aa
