#!/usr/bin/perl

if (@ARGV<2) {
	print  "programm $file_mouse $file_dog file_in file_out \n";
	exit;
}
($file_mouse,$file_dog,$file_in,$file_out) =@ARGV;
open MOUSE,"$file_mouse" || die "$!";
open DOG,"$file_dog"|| die "$!";
open IN,"$file_in" || die"$!";
open OUT,">$file_out" || die"$!";


while (<MOUSE>) {
	chomp;
	@info=split /\t/,$_;
	$mouse{$info[0]}=$info[1];
	print $info[1],"\n";
}
#print $mouse{"ENSMUSP00000019516"},"((((((";
while (<DOG>) {
	chomp;
	@sp=split /\t/,$_;
	$dog{$sp[0]}=$sp[1];
}
while (<IN>) {
	chomp;
	@s=split /\t/,$_;
	@s=split /\t/,$_;
	$human_gene=$s[0];
	$human_pep=$s[2];
	$mouse_pep=$s[6];
	$dog_pep=$s[8];
	print OUT "$human_gene\t$human_pep\t$s[3]\t$mouse_pep\t$mouse{$mouse_pep}\t$dog_pep\t$dog{$dog_pep}\n";

	

}

