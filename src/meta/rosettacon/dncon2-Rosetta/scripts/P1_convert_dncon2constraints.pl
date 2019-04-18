#! /usr/bin/perl -w


if(@ARGV != 5)
{
	die "The number of parameter is not correct!\n";
}

$dnconfile = $ARGV[0];
$seqfile = $ARGV[1];
$outputfile = $ARGV[2];
$lb = $ARGV[3];
$ub = $ARGV[4];

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
	
	$res1_type='CB';
	$res2_type='CB';
	
	if($res1 eq 'G')
	{
		$res1_type = 'CA';
	}
	if($res2 eq 'G')
	{
		$res2_type = 'CA';
	}
	
	$res1_num_string = sprintf("%4s", $res1_num);
	$res1_type_string = sprintf("%4s", $res1_type);
	
	$res2_num_string = sprintf("%4s", $res2_num);
	$res2_type_string = sprintf("%4s", $res2_type);
	
	$lb_num_string = sprintf("%.2f", $lb);
	$ub_num_string = sprintf("%.2f", $ub);
	$weight_num_string = sprintf("%.2f", 0.5);
	
	$score_string = sprintf("%.2f", $score);
	
	
	
	
# AtomPair   CB   84   CB  125  BOUNDED 3.50 8.00 1.00 #ContactMap: 0.51

#- 1stResidueNum
#- 1stResidueCode
#- 2ndResidueNum
#- 2ndResidueCode
#- mutual information score
#- DI score
	
	print OUT "AtomPair $res1_type_string $res1_num_string $res2_type_string $res2_num_string BOUNDED $lb_num_string $ub_num_string $weight_num_string #ContactMap: $score_string\n";
}
close TMP;
close OUT;

