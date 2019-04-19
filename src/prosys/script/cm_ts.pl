#!/usr/bin/perl -w

#################################################################
#The main script of comparative modelling from scratch
#Inputs: option file, fasta file, output dir.
#Outputs: blast output file, local alignment file, pir msa file,
#         pdb file (if available), and log file
#Author: Jianlin Cheng
#Date: 4/18/2005
#################################################################
#Format of Option file:
#script_dir = value
#blast_dir = value
#modeller_dir = value
#pdb_db_dir = value
#nr_dir = value (none: not use nr)
#atom_dir = value
#blast_evalue = ####
#align_evalue = ####
#max_gap_size = ####
#min_cover_size = ####
#model_num = ####
#other options can be easily added in future. 
#all kinds of comments starting with "#" are allowed. 
#################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
#initialized with default values
$blast_evalue = 1;
$align_evalue = 0.5;
$max_gap_size = 20;
$min_cover_size = 20;

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	#	print "$script_dir\n";
	}
	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}
	if ($line =~ /^blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_evalue = $value; 
	}
	if ($line =~ /^align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$align_evalue = $value; 
	}
	if ($line =~ /^max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$max_gap_size = $value; 
	}
	if ($line =~ /^min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$min_cover_size = $value; 
	}
	if ($line =~ /^model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$model_num = $value; 
	}
}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
if ($nr_dir ne "none")
{
	-d $nr_dir || die "can't find nr dir.\n";
}
-d $atom_dir || die "can't find atom dir.\n";
if ($blast_evalue <= 0 || $blast_evalue >= 10 || $align_evalue <= 0 || $align_evalue >= 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}
#if ($max_gap_size <= 0 || $min_cover_size <= 0)
if ($min_cover_size <= 0)
{
	die "max gap size or min cover size is non-positive. stop.\n"; 
}
if ($model_num < 1)
{
	die "model number should be bigger than 0.\n"; 
}

#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}

################################################################
#blast protein and nr(if necessary) to find homology templates.
#assumption: pdb database name is: pdb_cm
#	     nr database name is: nr
#################################################################

-f "$pdb_db_dir/pdb_cm.phr" || die "can't find the pdb database.\n"; 

if (-d $nr_dir )
{
	print "blast PDB and NR to find homology templates...\n";
	-f "$nr_dir/nr.phr" || die "can't find the nr database.\n"; 

	system("$script_dir/cm_psiblast_temp.pl $blast_dir $nr_dir/nr $pdb_db_dir/pdb_cm $fasta_file $fasta_file.blast $blast_evalue"); 
}
else
{
	print "blast PDB to find homology templates...\n";
	system("$script_dir/cm_psiblast_temp.pl $blast_dir none $pdb_db_dir/pdb_cm $fasta_file $fasta_file.blast $blast_evalue"); 

}

#parse the blast output
print "parse blast output...\n"; 
system("$script_dir/cm_parse_blast.pl $fasta_file.blast $fasta_file.local");
open(LOCAL, "$fasta_file.local") || die "can't read the parsed output results.\n"; 
@local = <LOCAL>;
close LOCAL;
if (@local <= 2)
{
	die "no significant templates are found. stop.\n";
}

print "generate PIR alignments...\n";
#convert local alignments into a pir msa.
system("$script_dir/cm_align_blast.pl $fasta_file $fasta_file.local $align_evalue $max_gap_size $min_cover_size $fasta_file.pir");

open(PIR, "$fasta_file.pir") || die "can't generate pir file from local alignments.\n";
@pir = <PIR>;
close PIR; 
if (@pir <= 4)
{
	die "no pir alignments are generated from target: $name\n"; 
}

print "Use Modeller to generate tertiary structures...\n"; 
#generate tertiary structure from pir msa.
system("$script_dir/pir2ts.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $model_num");

`mv model.log $fasta_file.log`; 

print "Comparative modelling for $name is done.\n"; 

