#!/usr/bin/perl -w
$num = @ARGV;
if($num != 2)
{
	die "The number of parameter is not correct!\n";
}
$dnconfile = $ARGV[0];
$outptufile = $ARGV[1];

open(IN, "$dnconfile") || die("Couldn't open file $dnconfile\n"); 
open(MARKER, ">$outptufile") || die("Couldn't open file $outptufile\n"); 
$sequence_num = 0;
$effective_sequence_num = 0;
while(<IN>)
{
	$line = $_; #domain 0:1-47
	chomp $line;
	if(index($line,'REMARK Number of sequences in the alignment =')==0)
	{
		$sequence_num = substr($line,length('REMARK Number of sequences in the alignment ='));
		$sequence_num =~ s/^\s+|\s+$//g;
	}
	if(index($line,'REMARK Effective number of sequences in the alignment =')==0)
	{
		$effective_sequence_num = substr($line,length('REMARK Effective number of sequences in the alignment ='));
		$effective_sequence_num =~ s/^\s+|\s+$//g;
	}
}
close IN;
$effective_sequence_num = sprintf("%.0f",$effective_sequence_num);
print MARKER "Alignment Number\n";
print MARKER "N $sequence_num\n";
print MARKER "Neff $effective_sequence_num\n";
close MARKER;