#!/usr/bin/perl -w

if (@ARGV != 2) {
  print "Usage: structure1  structure2\n";
  exit;
}
$pdb1 = $ARGV[0];
$pdb2 = $ARGV[1];

$GLOBAL_PATH="/home/jh7x3/multicom_beta1.0/";

if(-e $pdb1 and -e $pdb2)
{
	print "Evaluate predicted model <$pdb1> to native structure <$pdb2>\n";
}else
{
	die  "<$pdb2> is not found\n";
}

$command1="$GLOBAL_PATH/tools/tm_score/TMscore_32 $pdb1 $pdb2";
print "Run $command1 \n";
@result1=`$command1`;

foreach $j (@result1){
	print  $j;
}

