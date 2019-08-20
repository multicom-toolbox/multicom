#!/usr/bin/perl -w

$num = @ARGV;
if($num != 2)
{
	die "Wrong parameters\n\n";
}


$inputfile = $ARGV[0];
$outputfile = $ARGV[1];

open(IN,"$inputfile") || die "Failed to open file\n";
@content = <IN>;
close IN;

## at least 2 lines
if(@content <= 2)
{
	print "at least 2 lines in fasta file, exit\n\n";
	exit(-1);
}

$id = shift @content;
$seq = shift @content;
chomp $id;
chomp $seq;

open(OUT,">$outputfile") || die "Failed to write $outputfile\n\n";

print OUT "$id\n$seq\n";

while (@content)
{
	$id = shift @content;
	$seq = shift @content;
	chomp $id;
	chomp $seq;
	
	### keep 1,3,5,7,9,11 .....
	shift @content;
	shift @content;
	
	print OUT "$id\n$seq\n";
}
close OUT;

