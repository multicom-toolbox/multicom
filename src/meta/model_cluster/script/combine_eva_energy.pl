#!/usr/bin/perl -w
##################################################################
#combine model evaluation score and model energy
#Inputs: model eval file, model energy file, output prefix
#Author: Jianlin Cheng
#Date: 2/20/2008
##################################################################

if (@ARGV != 3)
{
	die "need three parameters: model eval file, model energy file, and output prefix.\n";
}

$eva_file = shift @ARGV;
$energy_file = shift @ARGV;
$prefix = shift @ARGV;

open(FILE, $eva_file) || die "can't read file $eva_file.\n";
@scores = <FILE>;
close FILE;
pop @scores;

$title1 = shift @scores; 
$title2 = shift @scores; 
$title3 = shift @scores; 
$title4 = shift @scores;

@eva = ();
@eva_names = ();
while (@scores)
{
	$line = shift @scores;
	chomp $line;	
	($name, $score) = split(/\s+/, $line);

	push @eva, {
		name => $name,
		score => $score,
		rank => 0
	};
	push @eva_names, $name;
}

open(FILE, $energy_file) || die "can't read $energy_file.\n";
@energies = <FILE>;
close FILE;
pop @energies;
shift @energies; shift @energies; shift @energies; shift @energies;

@eng = ();
while (@energies)
{
	$line = shift @energies;
	chomp $line;	
	($name, $energy) = split(/\s+/, $line);
	push @eng, {
		name => $name,
		energy => $energy,
		rank => 0
	}
}

@sorted_eva = sort { $b->{"score"} <=> $a->{"score"} } @eva;
@sorted_eng = @eng;


for ($j = 0; $j <= $#sorted_eva; $j++)
{
	$score = $sorted_eva[$j]{"score"};	
	push @scores, $score;
}

@scores == @sorted_eng || die "the number of models does not match.\n";

$num = @scores;
print "number of scores: $num\n";

@sorted_scores = sort {$b <=> $a} @scores;


open(AVE, ">$prefix") || die "can't create $prefix\n";
print AVE "$title1$title2$title3$title4";

for ($i = 0; $i < @sorted_eng; $i++)
{
	print AVE $sorted_eng[$i]{"name"}, " ", $sorted_scores[$i], "\n";
}
print AVE "END\n";
