#! /usr/bin/perl -w


if(@ARGV != 3)
{
	die "The number of parameter is not correct!\n";
}

$dnconfile = $ARGV[0];
$seqfile = $ARGV[1];
$outputfile = $ARGV[2];

open(OUT,">$outputfile") || die "Failed to open file $outputfile\n";
open(SEQ,$seqfile) || die "Failed to open file $seqfile\n";
@content = <SEQ>;
close SEQ;

shift @content;
$sequence = shift @content;
chomp $sequence;


open(TMP,$dnconfile) || die "Failed to open file $dnconfile\n";
while(<TMP>)
{
	$line=$_;
	chomp $line;
	if(index($line,'PFRMAT')>=0 or index($line,'TARGET')>=0 or index($line,'AUTHOR')>=0 or index($line,'METHOD')>=0 or index($line,'REMARK')>=0 or index($line,'MODEL')>=0)
	{
		next;
	}
	@tmp = split(/\s/,$line);
	if(@tmp != 5)
	{
		next;
	}

	$res1_num = $tmp[0];
	$res1 = substr($sequence,$res1_num-1,1);
	$res2_num = $tmp[1];
	$res2 = substr($sequence,$res2_num-1,1);
	$score = $tmp[4];

#- 1stResidueNum
#- 1stResidueCode
#- 2ndResidueNum
#- 2ndResidueCode
#- mutual information score
#- DI score
	
	print OUT "$res1_num $res1 $res2_num $res2 0 $score\n";
}
close TMP;
close OUT;

