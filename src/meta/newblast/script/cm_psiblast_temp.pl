#! /usr/bin/perl -w
##############################################################################
#use psiblast to search template database to find homology templates
#inputs: blast path, nr db, temp database path, input file(in fasta), output file.
#output format: blastp output 
#Author: Jianlin Cheng
#Date: 3/21/2005
##############################################################################

if (@ARGV != 6)
{
	die "need six parameters: blast path, nr database(none:not used), temp database, seq file(fasta), output file, evalue(1.0)\n";
}

$blast_path = shift @ARGV;
$nr_db = shift @ARGV;
$temp_db = shift @ARGV;
$seq_file = shift @ARGV;
$out_file = shift @ARGV;
$evalue = shift @ARGV;


print "evalue of newblast is $evalue.\n";

if (! -d $blast_path)
{
	die "can't find blast path: $blast_path\n";
}

if ($nr_db ne "none")
{
	if (! -f "$nr_db.pal")
	{
		if ( ! -f "$nr_db.phr" || !-f "$nr_db.pin" || !-f "$nr_db.psq" )
		{
			die "nr database doesn't exist.\n";
		}
	}
}

if (! -f "$temp_db.phr" || !-f "$temp_db.pin" || !-f "$temp_db.psq")
{
	die "template database doesn't exist.\n";
}

if (! -f $seq_file)
{
	die "sequence file does not exist.\n";
}

#first search nr database to construct profile if necessary
{
	#-j: iteration
	#-e: expectation from db
	#-h: p-value for pairwise (we also need to test these parameters) (-e, -h, -j)
	#VERY IMPORTANT: TEST iteration parameters
	#comments: for -j: Rych's paper using 5 iterations, we might test 5 later on. 
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 10 -h 10 -d $temp_db");
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 0.001 -h 0.00001 -d $temp_db");
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 10 -h 10 -d $temp_db");
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 10 -h 1 -d $temp_db");
	system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 10 -h 0.001 -d $temp_db");
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j 3 -e 1 -h 1 -d $temp_db");

	#system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 0.001 -h 0.00001 -d $temp_db"); 
	#system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 10 -h 10 -d $temp_db"); 
	#system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 1 -h 10 -d $temp_db"); 
	#system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 10 -h 1 -d $temp_db"); 
	system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 10 -h 0.001 -d $temp_db"); 
	#system("$blast_path/blastpgp -i $seq_file -R $seq_file.chk -o $out_file -j 3 -e 1 -h 1 -d $temp_db"); 
	`rm $seq_file.tmp $seq_file.chk`; 
}



