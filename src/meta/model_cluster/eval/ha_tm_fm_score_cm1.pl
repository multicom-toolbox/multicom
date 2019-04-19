#!/usr/bin/perl -w

$score_file = "con.txt";
$ha_file = "HA";
$tm_file = "TM";
$fm_file = "FM";

open(SCORE, $score_file) || die "can't read $score_file.\n";
@score = <SCORE>;
close SCORE;

%name2score = ();

$num = 0;
$total = 0;
while (@score)
{
	$name = shift @score;
	chomp $name;
	if ($name =~ /^T/)
	{
		$score = shift @score;
		chomp $score;
		shift @score;
		$name2score{$name} = $score;
		$num++;
		$total += $score;
	}
}

print "total target num = $num; total score = $total\n";

open(HA, $ha_file);
@ha = <HA>;
close HA;
$num = 0;
$total = 0;
foreach $ent (@ha)
{
	chomp $ent;

	$ent .= ".pdb";

	if (exists $name2score{$ent})
	{
		$total += $name2score{$ent};
		$num++;
	}
}
print "total HA target num = $num; total HA score = $total\n";


open(TM, $tm_file);
@tm = <TM>;
close TM;
$num = 0;
$total = 0;
foreach $ent (@tm)
{
	chomp $ent;
	$ent .= ".pdb";

	if (exists $name2score{$ent})
	{
		$total += $name2score{$ent};
		$num++;
	}
}
print "total TM target num = $num; total TM score = $total\n";


open(FM, $fm_file);
@fm = <FM>;
close FM;
$num = 0;
$total = 0;
foreach $ent (@fm)
{
	chomp $ent;
	$ent .= ".pdb";

	if (exists $name2score{$ent})
	{
		$total += $name2score{$ent};
		$num++;
	}
}
print "total FM target num = $num; total FM score = $total\n";





