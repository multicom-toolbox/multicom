#! /usr/bin/perl -w
##############################################################################
#use psiblast to search template database to find homology templates
#inputs: blast path, nr db, input file(in fasta), output file.
#output format: blastp output 
#Author: Jianlin Cheng
#Date: 3/21/2005
##############################################################################

if (@ARGV != 4)
{
	die "need four parameters: blast path, nr database, seq file(fasta, can be more than 1), output dir\n";
}

$blast_path = shift @ARGV;
$nr_db = shift @ARGV;
$fasta_file = shift @ARGV;
$out_dir = shift @ARGV;
-d $out_dir || die "can't find output dir.\n";

if (! -d $blast_path)
{
	die "can't find blast path: $blast_path\n";
}

if (! -f "$nr_db.pal")
{
if (! -f "$nr_db.phr" || !-f "$nr_db.pin" || !-f "$nr_db.psq")
{
	die "nr database doesn't exist.\n";
}
}

open(FASTA, $fasta_file) || die "can't read fasta file.\n";
@fasta = <FASTA>;
close FASTA;

while (@fasta)
{
	$name = shift @fasta;
	if ($name !~ /^>/)
	{
		die "fasta format error: $name";
	}
	chomp $name;
	$name = substr($name,1);
	#replace white space, . to _ in the name if there are some
	$name =~ s/[\s\.]/_/g;
	
	$seq = shift @fasta;
	
	#create a temporary file
	$tmp_file = "$out_dir/$name";
	open(TMP, ">$tmp_file") || die "can't create fasta file.\n";
	print TMP ">$name\n";
	print TMP $seq;
	close TMP;

	#-j: iteration
	#-e: expectation from db
	#-h: p-value for pairwise (we also need to test these parameters) (-e, -h, -j)
	system("$blast_path/blastpgp -i $tmp_file -o $tmp_file.tmp -C $tmp_file.chk -j 3 -e 0.001 -h 1e-10 -d $nr_db");

	`rm $tmp_file.tmp`; 
	`rm $tmp_file`; 
}
