#!/usr/bin/perl -w
#######################################################################
#Conver the data set file to fasta file
#Assume the data entry is separated by blank line. For each entry: first three lines are: name, length, sequence
#Author: Jianlin Cheng, 8/5/2005 
#Modified from set2fasta.pl
######################################################################

if (@ARGV != 2)
{
	die "need two parameters: input data set file, output fasta file.\n";
}

open(DATASET, "$ARGV[0]") || die "can't open the input data set file.\n";

$num = 0; 
$count = 0; 
@seqs = (); 
while (<DATASET>)
{
	$line = $_;
	if ($line eq "\n")
	{
		$count = 0; 
		next; 
	}
	$count++;
	if ($count == 1)
	{
		$name = $line; 
		chomp $name;
	}

	if ($count == 2)
	{
		$resolution = $line;
		$type = "";
		($res, $type) = split(/\s+/, $resolution); 
	}
	
	if ($count == 3)
	{
		chomp $line; 
		$length = $line; 
	}
	if ($count == 4)
	{
		chomp $line; 
		@aas = split(/\s+/, $line); 
		if (@aas != $length)
		{
			print "$name, $length\n"; 
			print "$line\n";
			die "sequence length doesn't match.\n"; 
		}
		$seq = join("", @aas);
		push @seqs, {
				"name" => $name,
				"res" => $res,
				"seq" => $seq
				}; 
		$num++; 
	}
	
}
close(DATASET);
close(OUTPUT); 

@sorted_seqs = sort {$a->{"res"} <=> $b->{"res"}} @seqs; 

open(OUTPUT, ">$ARGV[1]") || die "can't create the output file.\n";
for ($i = 0; $i < @sorted_seqs; $i++)
{
	$name = $sorted_seqs[$i]{"name"}; 
	$res = $sorted_seqs[$i]{"res"}; 
	#print OUTPUT ">$name | $res\n";
	print OUTPUT ">$name\n";
	$seq = $sorted_seqs[$i]{"seq"}; 
	print OUTPUT "$seq\n"; 
}

print "total number of sequence in sorting by resolution: $num\n"; 
