#!/usr/bin/perl -w
##############################################################################################
#Parse HHSearch alignment output file to generate a template rank list.
#Input: hhsearch result file, output rank file.
#Author: Jianlin Cheng
#Date: 1/3/2008
##############################################################################################


if (@ARGV != 2)
{
	die "need two inputs: hhsearch result file, output rank file.\n";
}

$hhsearch_file = shift @ARGV;

$align_file = shift @ARGV;

open(HHSEARCH, $hhsearch_file) || die "can't read $hhsearch_file.\n";
@hhsearch = <HHSEARCH>;
close HHSEARCH;


$line = shift @hhsearch;
chomp $line;
if ($line =~ /Query\s+(.+)/)
{
	$query_name = $1;
}
else
{
	die "1. hhsearch format error.\n";
}

$line = shift @hhsearch;
chomp $line;
if ($line =~ /Match_columns\s+(\d+)/)
{
	$query_length = $1; 
}

$line = shift @hhsearch;
chomp $line;
if ($line =~ /No_of_seqs\s+(\d+)/)
{
#	$query_seq_num = $1;	
}
else
{
	die "2. hhsearch format error.\n";
}

shift @hhsearch;


$line = shift @hhsearch;
chomp $line;

if ($line =~ /Searched_HMMs\s+(\d+)/)
{
	$db_size = $1; 
}
else
{
	die "3. hhsearch format error.\n";
}

shift @hhsearch;
shift @hhsearch;

if (@hhsearch < 5)
{
	goto END;
}

shift @hhsearch;

#read the hit list
$line = shift @hhsearch; 
if ($line !~ /No Hit/)
{
	die "4. hhsearch format error.\n";
}

@temp_ids = ();
@probs = ();
@evalues = ();


while (@hhsearch)
{
	$line = shift @hhsearch;
	if ($line =~ /^\s*\n$/)
	{
		last;
	}
	               # 1.id   2.name  3.prob     4.evalue  pvalue 5.score   6.ss-score  cols  7.qs-qe 8.ts-te  9.length
	# special case T0355, hit 1OFDA.
	#remove annotation information (for hhpred only)
	if (length($line) > 35)
	{
		$line = substr($line, 0, 10) . "                         " . substr($line, 35);  
	} 
	if ($line =~ /\s*(\d+)\s+(\S+)\s+([\d\.]+)\s+(\S+)\s+\S+\s+([-\d\.]+)\s+([-\d\.]+)\s+\d+\s+(\S+)\s+(\S+)\s*\((\d+)\)/)
	{
		$temp_name = $2;
		$temp_prob = $3;
		$temp_evalue = $4;

		$front = substr($temp_name, 0, 4);
		$end = substr($temp_name, 4);
		$temp_name = lc($front);
		$temp_name .= $end;

		push @temp_ids, $temp_name;
		push @probs, $temp_prob;
		push @evalues, $temp_evalue;

	}
	else
	{
		print "$line\n";
		die "5. hhsearch format error.\n";
	}
}
open(ALIGN, ">$align_file") || die "can't create $align_file.\n";
print ALIGN "Ranked templates for $query_name, query length = $query_length, db size = $db_size\n";
for ($i = 0; $i < @temp_ids; $i++)
{
	print ALIGN $i+1, "\t";
	print ALIGN $temp_ids[$i], "\t", $evalues[$i], "\t", $probs[$i], "\n";
}
close ALIGN;
END:
