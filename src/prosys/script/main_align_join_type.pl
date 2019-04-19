#!/usr/bin/perl -w
#########################################################################
#This is the main alignment script for template-based protein structure
#prediction (CM and FR). This script do all kinds of alignment/combination.
#Inputs: cm option file, fr option file, query file(fasta), output dir
#the output dir should include all cm and fr fold recognition results.
#Modified from main_cm_fr.pl
#Author: Jianlin Cheng
#Modified from main_align.pl
#Starting Date: 11/2/2005
#########################################################################

#####################Read Input Parameters###################################
if (@ARGV != 4)
{
	die "need five parameters: cm option file, fr option file, query file(fasta), output dir\n";
}

$cm_option = shift @ARGV;
$fr_option = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;

#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";
use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
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


#################Step 2: Do Fold Recognition#####################################
#It will produce the following important files in the output dir
#query_name.rank  (the list of ranked templates name and its svm score)
#query_name.fr.pir (a file including all prof-prof alignments between selected templates and query.
#template_name.pir (prof-prof alignment between template_name and query
#query_name.can (the list of absolute path of all prof-prof aligment files)
#simple_comb#.pir: # is in [1,5]. top five combined fr alignments.
#simple_comb#.eng: # is in [1,5]. the modeller energy of top five models.
#simple_comb#.pdb: # is in [1,5]. the top five pdb models. (may not existed if problem happens)

#options for sorting local alignments
$sort_svm_rank = "no";
$sort_svm_delta_rvalue = 0.01;
$sort_svm_delta_resolution = 2;
$fr_add_stx_info_rm_identical = "no";
$fr_rm_identical_resolution = 2;

#Read the number of models to be generated.
open(OPTION, $fr_option) || die "can't read $fr_option file.\n";
$fr_stx_num = 5; 
$svm_comb_threshold = 100;
$align_type = "lobster";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^fr_stx_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_stx_num = $value; 
	}
	if ($line =~ /^alignment_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$align_type = $value; 
	}

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_svm_rank/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_svm_rank = $value; 
	}

	if ($line =~ /^sort_svm_delta_rvalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_svm_delta_rvalue = $value; 
	}

	if ($line =~ /^sort_svm_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_svm_delta_resolution = $value; 
	}

	if ($line =~ /^fr_add_stx_info_rm_identical/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_add_stx_info_rm_identical = $value; 
	}

	if ($line =~ /^fr_rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_rm_identical_resolution = $value; 
	}

	if ($line =~ /^svm_comb_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$svm_comb_threshold = $value; 
	}

}

if ($sort_svm_rank eq "yes")
{
	if (!defined $chain_stx_info || !-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't resort svm rankings.\n";
		$sort_svm_rank = "no";
	}
}

if ($fr_add_stx_info_rm_identical eq "yes")
{
	if (!defined $chain_stx_info || !-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to fr alignments.\n";
		$fr_add_stx_info_rm_identical = "no";
	}
}

if ($sort_svm_delta_rvalue <= 0 || $sort_svm_delta_resolution <= 0)
{
		warn "sort_svm_delta_rvalue <= 0 or delta resolution <= 0. Don't sort blast local alignments.\n";
		$sort_svm_rank = "no";
}
if ($fr_rm_identical_resolution <= 0)
{
	warn "fr_rm_identical_resolution <= 0. Don't add structure information and remove identical fr alignments.\n";
	$fr_add_stx_info_rm_identical = "no";
}

print "Do Profile-Profile Alignment...\n";
system("$script_dir/fr_main_align_join.pl $fr_option $query_file $output_dir");
print "Done.\n";

#rename the models and alignment files
for ($i = 1; $i <= $fr_stx_num; $i++)
{
	if (-f "$output_dir/simple_comb$i.pdb")
	{
		`mv $output_dir/simple_comb$i.pdb $output_dir/$align_type$i.pdb`; 
		`mv $output_dir/simple_comb$i.pir $output_dir/$align_type$i.pir`; 
		`mv $output_dir/simple_comb$i.eng $output_dir/$align_type$i.eng`; 
	}
}

#combine the significant svm templates if necessary
#system("$script_dir/combine_sig_svm.pl $script_dir $output_dir $output_dir/$query_name.rank $svm_comb_threshold $output_dir/frcom.pir 2>/dev/null");
system("$script_dir/combine_sig_svm_full.pl $script_dir $output_dir $output_dir/$query_name.rank $svm_comb_threshold $output_dir/${align_type}com.pir 2>/dev/null");
#generate structure from the combination if necessary
if (-f "$output_dir/${align_type}com.pir")
{
	print "generate a structure from the combined significant FR templates.\n";
	system("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $output_dir $output_dir/${align_type}com.pir $cm_model_num > $output_dir/${align_type}com.eng 2>/dev/null");
	`mv $output_dir/$query_name.pdb $output_dir/${align_type}com.pdb`; 
}
################End of Fold Recogniton######################################

