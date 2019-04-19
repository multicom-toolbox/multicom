#!/usr/bin/perl -w
####################################################
#Check if ids in fasta file repeats twice to identify
#the protein which is generated twice in rych.set
####################################################
if (@ARGV != 1)
{
	die "need fasta file.\n";
}
$fasta = shift @ARGV; 
open(FASTA, "$fasta") || die "can't open fasta file:$fasta\n";

@content = <FASTA>;
close FASTA;
$pre = ""; 
@all = (); 
while (@content)
{
	$name = shift @content;
	$seq = shift @content;
	#if ($name eq $pre)
	foreach $pre (@all)
	{
		if ($name eq $pre)
		{
			print "$name"; 
		}
	}
	push @all, $name; 
}

