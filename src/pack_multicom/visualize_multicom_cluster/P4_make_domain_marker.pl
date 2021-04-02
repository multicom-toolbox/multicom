#!/usr/bin/perl -w
$num = @ARGV;
if($num != 3)
{
	die "The number of parameter is not correct!\n";
}
$domain_info = $ARGV[0];
$fastafile = $ARGV[1];
$domain_marker = $ARGV[2];

###### convert global pir to global alignment for visualization on website
open(IN, "$fastafile") || die("Couldn't open file $fastafile\n"); 
@content = <IN>;
close IN;
$qid = shift @content;
$seq = shift @content;
chomp $qid;
chomp $seq;
$fasta_len = length($seq);
if(substr($qid,0,1) eq '>')
{
	$qid = substr($qid,1);
}
open(IN, "$domain_info") || die("Couldn't open file $domain_info\n"); 
open(MARKER, ">$domain_marker") || die("Couldn't open file $domain_marker\n"); 
print MARKER "1-$fasta_len\t$qid\t(length: 1-$fasta_len)\n";
while(<IN>)
{
	$line = $_; #domain 0:1-47
	chomp $line;
	@tmp2 = split(':',$line);
	$id = $tmp2[0];
	$range = $tmp2[1];
	print MARKER "$range\t$id\t(range: $range)\n";
}
close MARKER;