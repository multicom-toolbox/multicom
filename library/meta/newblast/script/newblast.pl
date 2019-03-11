#!/usr/bin/perl -w
#########################################################################
#This is the main entry script for template-based protein structure
#prediction (CM and FR). 
#Inputs: cm option file, fr option file, query file(fasta), output dir
#Author: Jianlin Cheng
#Modified from main_cm_fr.pl
#Starting Date: 11/2/2005
#Re-start date: 12/08/2007
#########################################################################

#####################Read Input Parameters###################################
if (@ARGV != 3)
{
	die "need three parameters: cm option file, query file(fasta), output dir\n";
}

$cm_option = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;

#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";
use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
$cm_option = abs_path($cm_option);
############################################################################

###################Preprocessing of Inputs###################################
#read option file
open(OPTION, $cm_option) || die "can't read option file.\n";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
#initialized with default values
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb"; #redundant: we always use new simple or advanced combination
$cm_model_num = 5; #number of model to simulate. One with the lowest energy will be chosen.

$cm_max_linker_size=10; #<0: simple comb; >=0: advanced comb 
$cm_evalue_comb= 0;

$adv_comb_join_max_size = -1; 

$newblast_dir = "";

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

	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}
	
	if ($line =~ /^newblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$newblast_dir = $value; 
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
	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_align_evalue = $value; 
	}
	if ($line =~ /^cm_max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_gap_size = $value; 
	}
	if ($line =~ /^cm_min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_min_cover_size = $value; 
	}
	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

	if ($line =~ /^cm_max_linker_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_linker_size = $value; 
	}

	if ($line =~ /^cm_evalue_comb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_comb = $value; 
	}

	if ($line =~ /^cm_comb_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_comb_method = $value; 
	}

	if ($line =~ /^adv_comb_join_max_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$adv_comb_join_max_size = $value; 
	}
}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $meta_common_dir || die "can't find meta_common dir.\n";
-d $newblast_dir || die "can't find newblast dir.\n";
if ($nr_dir ne "none")
{
	-d $nr_dir || die "can't find nr dir.\n";
}
-d $atom_dir || die "can't find atom dir.\n";
if ($cm_blast_evalue <= 0 || $cm_blast_evalue >= 10 || $cm_align_evalue <= 0 || $cm_align_evalue >= 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}
#if ($cm_max_gap_size <= 0 || $cm_min_cover_size <= 0)
if ($cm_min_cover_size <= 0)
{
	die "max gap size or min cover size is non-positive. stop.\n"; 
}
if ($cm_model_num < 1)
{
	die "model number should be bigger than 0.\n"; 
}

if ($cm_evalue_comb > 0)
{
	die "the evalue threshold for alignment combination must be <= 0.\n";
}

#check fasta file format
open(FASTA, $query_file) || die "can't read fasta file.\n";
$query_name = <FASTA>;
chomp $query_name; 
$qseq = <FASTA>;
chomp $qseq;
close FASTA;

#Enter into the work dir
`cp $query_file $output_dir 2>/dev/null`; 
chdir $output_dir; 
#take only filename from fasta file
$pos = rindex($query_file, "/");
if ($pos >= 0)
{
	$query_file = substr($query_file, $pos + 1); 
}

#rewrite fasta file if it contains lower-case letter
if ($qseq =~ /[a-z]/)
{
	print "There are lower case letters in the input file. Convert them to upper case.\n";
	$qseq = uc($qseq);
	open(FASTA, ">$query_file") || die "can't rewrite fasta file.\n";
	print FASTA "$query_name\n$qseq\n";
	close FASTA;
}

if ($query_name =~ /^>/)
{
	$query_name = substr($query_name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}
####################End of Preprocessing of Inputs#############################

#check if local alignment file exist. 
if (-f "$query_file.local")
{
	print "The local alignment file exists, so directly go to alignment refinement and model generation.\n";
	goto MULTICOM; 
}
####################End of Preprocessing of Inputs#############################

#################Step 1: Do Comparative Modeling##################################
#It will produce the following four important files in $output_dir:
#query_file.blast (blast alignment file) (this query_file doesn't include path)
#query_file.local (formated local alignment file)
#query_file.pir (combined pir alignment file)
#query_name.pdb (model)
print "Do comparative modeling using multicom...\n";
system("$newblast_dir/script/cm_main_comb_join_v2.pl $cm_option $query_file $output_dir");

MULTICOM:

$align_option = "$meta_common_dir/script/align_option";
-f $align_option || die "can't find alignment option file: $align_option.\n";

#preprocess local alignments
system("$newblast_dir/script/local_global_align.pl $align_option $query_file.local $query_file $query_file"); 

#generate structure from local alignments
system("$meta_common_dir/script/local2model.pl $cm_option $query_file $query_file .");

print "Comparative modelling for $query_file is done.\n"; 

