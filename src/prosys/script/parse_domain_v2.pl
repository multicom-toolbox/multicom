#!/usr/bin/perl -w
##########################################################################
#Parse the domains from a pdb file
#Input: pdp program path, fasta file, pdb file, chain id, output file
#Output: domain1: range, domain2: range, .... and casp output file
#Author: Jianlin Cheng
#Date: 12/30/2005
##########################################################################

if (@ARGV != 5)
{
	die "need five parameters: pdp program path(prosys/pdp), fasta file, pdb file, chain id(-, A, B, ...), output file(in casp format)\n";
}

$pdp_path = shift @ARGV;
$fasta_file = shift @ARGV; 
$pdb_file = shift @ARGV;
$chain_id = shift @ARGV;
$output_file = shift @ARGV; 

$pdp_exe = "$pdp_path/pdp";
-f $pdp_exe || die "can't find program $pdp_exe\n";
-f $pdb_file || die "can't find $pdb_file\n";

open(FASTA, $fasta_file) || die "can't read $fasta_file\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1); 
$seq = <FASTA>;
chomp $seq; 
close FASTA;

#run pdp to parse domains
#domains are separated by "/". The segments within domains are separated by ",".
#we need to reorder domains and assign domain number
#output format: domain 1: a-b c-d, domain2: a-b...

system("$pdp_exe $pdb_file $chain_id > $fasta_file.dom");
open(DOM, "$fasta_file.dom") || die "can't read domain file: $fasta_file.com\n";
$result = <DOM>;
close DOM;
`rm $fasta_file.dom`; 
chomp $result; 

@fields = split(/\s+/, $result);
@domains = split(/\//, $fields[1]); 

#sort the domains according to index
%dom_map = ();
for ($i = 0; $i < @domains; $i++)
{
	#print "domain record: $record\n";
	$record = $domains[$i]; 
	@ranges = split(/-/, $record); 
	#print "start: $ranges[0]\n";
	$dom_map{$ranges[0]} = $record; 
}

@sorted_keys = sort keys %dom_map;  #sort by strings
@sorted_keys = sort {$a<=>$b} @sorted_keys;  #sort by numbers
#print "sorted keys: @sorted_keys\n";

open(DOM, ">$output_file") || die "can't write output file.\n";
print DOM "PFRMAT DP\n";
print DOM "TARGET $name\n";
print DOM "AUTHOR MULTICOM-CMFR\n";
print DOM "METHOD J. Cheng. DOMAC: An Accurate, Hybrid Protein Domain\n";
print DOM "METHOD Prediction Server. Nucleic Acids Res., 35:w354-356, 2007.\n";
$ord = 1; 
$num = @domains; 
print "number of domains: $num\n";
$len = length($seq); 
if ($len <= 135)
{
	#if the sequence length <= 135, set domain number to 1 anyway
	print DOM "REMARK number of domains: 1\n";
}
else
{
	print DOM "REMARK number of domains: $num\n";
}

foreach $id (@sorted_keys)
{
	$dom = $dom_map{$id}; 		
	print "domain $ord: $dom\n";
#	print DOM "REMARK domain $ord: $dom\n";
	$ord++; 
}

print DOM "MODEL 1\n";

#set the domain index flag to 0 for all the residues
$len = length($seq); 
for ($i = 0; $i < $len; $i++)
{
	$flags[$i] = 0; 
}

$ord = 1; 
foreach $id (@sorted_keys)
{
	$dom = $dom_map{$id}; 		

	@segments = split(/,/, $dom);
	for ($i = 0; $i < @segments; $i++)
	{
		$segment = $segments[$i]; 
		@region = split(/-/, $segment);
		$start = $region[0];
		$end = $region[1]; 

		$start >= 1 && $end <= $len || die "domain range is out of sequence length, stop.\n";

		for ($j = $start - 1; $j <= $end - 1; $j++)
		{
			$flags[$j] = $ord; 
		}
	}

	$ord++; 
}

#identify uncovered regions
#print join("", @flags), "\n";

$uncover = 0; 
@left = ();
@right = (); 
for ($i = 0; $i < $len; $i++)
{
	$flag = $flags[$i]; 
	if ($uncover == 0 && $flag == 0)
	{
		$uncover = 1; 
		push @left, $i; 
	}
	
	if ($uncover == 1 && $flag != 0) 
	{
		$uncover = 0;
		push @right, $i - 1; 
	}

	#handle special case
	if ($uncover == 1 && $flag == 0 && $i == $len - 1)
	{
		push @right, $i; 
	}
}

$size = @left; 
#print join(" ", @left), "\n";
#print join(" ", @right), "\n";
$size == @right || die "$name: number of uncover regions doesn't match.\n";

#set the domain index for uncovered regions
for ($i = 0; $i < $size; $i++)
{
	$start = $left[$i];
	$end = $right[$i]; 

	if ($start == 0) #left most region
	{
		for ($j = $start; $j <= $end; $j++)
		{
			$flags[$j] = 1; 
		}
		next; 
	}
	if ($end == $len - 1) #right most region
	{
		for ($j = $start; $j <= $end; $j++)
		{
			$flags[$j] = $num; 
		}
		next; 
	}
	$middle = ($start + $end) / 2;
	$middle = int($middle); 
	$pre = $flags[$start - 1];
	$nxt = $flags[$end + 1];
	for ($j = $start; $j <= $middle; $j++)
	{
		$flags[$j] = $pre; 
	}
	for ($j = $middle + 1; $j <= $end; $j++)
	{
		$flags[$j] = $nxt; 
	}
}


#here, if seuqence length is <= 135, set to one domain anyway
$len = length($seq); 
if ($len <= 135)
{
	print "Since sequence length <= 135, set to one domain to avoid overcut.\n";
	for ($i = 0; $i < $len; $i++)
	{
		$flags[$i] = 1; 
	}
}

#output the domain predictions
for ($i = 0; $i < $len; $i++)
{
	$idx = $i + 1; 
	print	DOM "$idx ", substr($seq, $i, 1), " $flags[$i] 0.6\n";
}
print DOM "END";











