#!/usr/bin/perl -w
######################################################################
#rank templates according to sp3 scores
#Input: sp3 score file, output: template ranking list
#Author: Jianlin Cheng
######################################################################

if (@ARGV != 2)
{
	die "need two prameters: sp3 score file, query name.\n";
}

$sp3_file = shift @ARGV;
$qname = shift @ARGV;

open(SP3, $sp3_file) || die "can't read $sp3_file.\n";
@sp3 = <SP3>;
close SP3;

@info = ();
$ave = 0;
$num = @sp3;
while (@sp3)
{
	$line = shift @sp3;
	chomp $line;
	@fields = split(/\s+/, $line);
	$name = $fields[3];	
	$score1 = $fields[13];
	$score2 = $fields[7];

	push @info, {
		prot => $name,
		score1 => $score1,
		score2 => $score2, 
		zscore => 0
	};
	$ave += $score2;
}
$ave = $ave / $num;
$var = 0;
for ($i = 0; $i < @info; $i++)
{
	$diff = $info[$i]{"score2"} - $ave;
	$var += $diff * $diff;	
}

$std = sqrt($var / ($num-1));
#$std = sqrt($var / $num);
for ($i = 0; $i < @info; $i++)
{
	$zscore = ($ave - $info[$i]{"score2"}) / $std;
	$info[$i]{"zscore"} = $zscore;
}


#@sorted_info = sort {$a->{"score2"} <=> $b->{"score2"}} @info;
@sorted_info = sort {$b->{"zscore"} <=> $a->{"zscore"}} @info;
print "Ranked templates for $qname, total = 99999\n";
for ($i = 0; $i < @sorted_info; $i++)
{
	print $i+1, "\t";
	$name = uc($sorted_info[$i]{"prot"});
	$name = uc($name);
	$name =~ s/_/A/g;

	$name = substr($name, 0, 5);

	print $name, "\t";
	print $sorted_info[$i]{"zscore"}, "\n";
	#print $sorted_info[$i]{"score1"}, "\t";
	#print $sorted_info[$i]{"score2"}, "\n";
}
	



