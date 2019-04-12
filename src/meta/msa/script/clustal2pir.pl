#!/usr/bin/perl -w
#################################################################
#Convert a clustal multiple sequence alignment file to pir format
#Author: Jianlin Cheng
#Input: input msa file, query name, output pir file
#################################################################
if (@ARGV != 3)
{
	die "need two parameters: clustal msa file, query name, output pir file.\n";
}

$msa_file = shift @ARGV;
$query_name = shift @ARGV;
$pir_file = shift @ARGV;

open(MSA, $msa_file) || die "can't read $msa_file.\n";
@msa = <MSA>;
close MSA;
shift @msa;

%id2seq = (); 
$query_seq = "";
while (@msa)
{
	$msa[0] eq "\n" || die "$msa_file format error: $msa[0].\n";
	shift @msa;
	$msa[0] eq "\n" || die "$msa_file format error: $msa[0]\n";
	shift @msa;	

	while (@msa)
	{
		$record = shift @msa;	

		chomp $record;
		@fields = split(/\s+/, $record); 
		$id = $fields[0];
		$seq = $fields[1]; 
		if ($id eq $query_name)
		{
			$query_seq .= $seq; 
		}
		elsif (exists $id2seq{$id})
		{
			$id2seq{$id} .= $seq; 	
		}	
		else
		{
			$id2seq{$id} = $seq; 	
		}
		if ($msa[0] eq "\n") { last; }; 
	}	

}

$query_seq ne "" || die "query ($query_name) is not found in input multiple sequence alignment file.\n";

open(PIR, ">$pir_file") || die "can't create pir file.\n";

foreach $id (keys %id2seq)
{

	$tname = $id;
	$tseq = $id2seq{$id};
	$org_seq = $tseq;
	$org_seq =~ s/-//g;
	$tlen = length($org_seq); 

	print PIR "C;template; converted from global alignment\n";
	print PIR ">P1;$tname\n";
	print PIR "structureX:$tname";
	print PIR ": 1: :";
	print PIR " $tlen: :";
	print PIR " : : : \n";
	print PIR "$tseq*\n\n";

}

print PIR "C;query; converted from global alignment\n";
print PIR ">P1;$query_name\n";
print PIR " : : : : : : : : : \n";
print PIR "$query_seq*\n";
close PIR;

