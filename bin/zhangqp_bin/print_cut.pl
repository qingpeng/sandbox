opendir  (DBDIR,"./CUT_NEW/" )|| die"can't open $dbdir:$!";
 @name = grep (!/^\.\.?$/,readdir DBDIR);
# @name = readdir (DBDIR);
close ;


foreach my $filename (@name){
	if ($filename =~/^(.*)_chr.*cut$/) {
print $filename,"\n";
	}
}
