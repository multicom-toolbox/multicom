#!/usr/bin/perl -w

##########################################################################################################
#Compute the hightest sequence identity of one sequence against  a fasta dataset.
#Inputs: script dir, blast dir, query file (fasta), target dataset(fasta) 
#Output: highest identity score, and qeury id and target id.
#identity = number of identical residues / length of query. 
#Author: Jianlin Cheng
#Date: 8/3/2005
###########################################################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: script_dir, blast dir, query file (fasta), target dataset file (fasta)\n";
}

$script_dir = shift @ARGV;
$blast_dir = shift @ARGV;
$query_file = shift @ARGV;
$target_file = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";

-d $blast_dir || die "can't find alignment tool dir.\n"; 

-f $query_file || die "can't find query file.\n";

-f $target_file || die "can't find target file.\n"; 

#format the target dataset
system("$blast_dir/formatdb -i $target_file"); 

#blast against target dataset
system("$blast_dir/blastall -i $query_file -d $target_file -p blastp -F F > $query_file.blast"); 

#parse local alignment 
#system("$script_dir/cm_parse_blast.pl $query_file.blast $query_file.local"); 
system("$script_dir/cm_parse_blast_all.pl $query_file.blast $query_file.local"); 

#extract identity
if (!open(LOCAL, "$query_file.local"))
{
	`rm formatdb.log  $query_file.blast $target_file.phr $target_file.pin $target_file.psq`; 
	die "can't read local alignment file: $query_file\n"; 
}
@local = <LOCAL>;
close LOCAL; 

$max_ind = 0; 
$name = ""; 
$temp_name = ""; 
$max_ind_ratio = 0; 
$select_temp = ""; 
if (@local > 2)
{
	$title = shift @local;
	($name, $length, @other) = split(/\s+/, $title); 
	shift @local;

	while (@local)
	{

		$info = shift @local;
		$evalue=$score=$temp_length=$align_len="";
		($temp_name, $temp_length, $score, $evalue, $align_len, $iden, @other) = split(/\s+/, $info);
		shift @local; 
		$align1 = shift @local;
		chomp $align1; 
		$align2 = shift @local; 
		chomp $align2; 

		$real_len = 0; 
		#align_len including gap length. so need to compute real length
		for ($i = 0; $i < length($align1); $i++)
		{
			#if (substr($align1, $i, 1) ne "-" && substr($align2, $i, 1))
			if (substr($align1, $i, 1) ne "-")
			{
				$real_len++; 
			}
		}

		$max_ind = $iden * $real_len / $length;  

		if ($max_ind > $max_ind_ratio)
		{
			$max_ind_ratio = $max_ind; 
			$select_temp = $temp_name;  
		}

		if (@local)
		{
			shift @local;
		}
	}
}

print "highest identity=$max_ind_ratio\n";
print "query=$name target=$select_temp\n"; 
#warn "query=$name target=$temp_name\n"; 

`rm formatdb.log  $query_file.blast $query_file.local $target_file.phr $target_file.pin $target_file.psq`; 
