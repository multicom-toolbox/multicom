#!/usr/bin/perl -w
#########################################################################
#This is the main alignment script for template-based protein structure
#prediction (CM and FR). This script do all kinds of alignment/combination.
#Inputs: cm option file, fr option file, query file(fasta), output dir
#the output dir should include all cm and fr fold recognition results.
#Modified from main_cm_fr.pl
#Author: Jianlin Cheng
#Starting Date: 10/28/2005
#########################################################################

#####################Read Input Parameters###################################
if (@ARGV != 4)
{
	die "need four parameters: cm option file, fr option file, query file(fasta), output dir\n";
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
if ($query_name =~ /^>/)
{
	$query_name = substr($query_name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}
####################End of Preprocessing of Inputs#############################

#################Step 1: Processing Comparative Modeling Results##################################
#It will produce the following four important files in $output_dir:
#query_file.blast (blast alignment file) (this query_file doesn't include path)
#query_file.local (formated local alignment file)
#query_file.pir (combined pir alignment file)
#query_name.pdb (model)

#get relative file name of query_file
$pos = rindex($query_file, "/");
if ($pos >= 0)
{
	$query_file_prefix = substr($query_file, $pos + 1);
}
else
{
	$query_file_prefix = $query_file; 
}

#check if a comparative model is generated.
if ( -f "$output_dir/cm.pir" && -f "$output_dir/cm.pdb")
{
	print "A CM model: $query_name.pdb is created.\n";
	$cm_flag = 1; 
}
else
{
	print "No CM model is created (probably no significant hit).\n";
	$cm_flag = 0; 
}
###############End of Comparative Modeling#################################


#################Step 2: Do Fold Recognition#####################################
#It will produce the following important files in the output dir
#query_name.rank  (the list of ranked templates name and its svm score)
#query_name.fr.pir (a file including all prof-prof alignments between selected templates and query.
#template_name.pir (prof-prof alignment between template_name and query
#query_name.can (the list of absolute path of all prof-prof aligment files)
#simple_comb#.pir: # is in [1,5]. top five combined fr alignments.
#simple_comb#.eng: # is in [1,5]. the modeller energy of top five models.
#simple_comb#.pdb: # is in [1,5]. the top five pdb models. (may not existed if problem happens)

print "Do Profile-Profile Alignment...\n";
system("$script_dir/fr_main_align.pl $fr_option $query_file $output_dir");
print "Done.\n";

#Read the number of models to be generated.
open(OPTION, $fr_option) || die "can't read $fr_option file.\n";
$fr_stx_num = 5; 
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
}
#rename the models and alignment files
for ($i = 1; $i <= $fr_stx_num; $i++)
{
	if (-f "$output_dir/simple_comb$i.pdb")
	{
		`mv $output_dir/simple_comb$i.pdb $output_dir/fr$i.pdb`; 
		`mv $output_dir/simple_comb$i.pir $output_dir/fr$i.pir`; 
		`mv $output_dir/simple_comb$i.eng $output_dir/fr$i.eng`; 
	}
}
################End of Fold Recogniton######################################



###############Step 3: Combine CM and FR if necessary##############################
$cm_align_file = "$output_dir/cm.pir";
#here, we might add more constraints to decide if we need to do combination.
#Right now, just use gap-drive condition

$cm_fr_flag = 0; #whether or not cm and fr is combined.

if ($cm_flag == 1 && -f $cm_align_file) #cm alignment file exists
{
	#check the coverage string of cm alignment file
	system("$script_dir/analyze_pir_align.pl $cm_align_file > $cm_align_file.bit");

	#do combination
	system("$script_dir/pir_comb_cm_fr.pl $script_dir $cm_align_file $output_dir/$query_name.can $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $output_dir/cmfr.pir");

	#check if new alignment is added.
	system("$script_dir/analyze_pir_align.pl $output_dir/cmfr.pir > $output_dir/cmfr.bit");
	open(BIT1, "$cm_align_file.bit");
	$bit1 = <BIT1>;
	close BIT1; 
	open(BIT2, "$output_dir/cmfr.bit");
	$bit2 = <BIT2>;
	close BIT2; 
	close BIT1; 
	if ($bit1 ne $bit2) #means: some new alignment is added.
	{
		#generate structure 
		system("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $output_dir $output_dir/cmfr.pir $cm_model_num > $output_dir/cmfr.eng 2>/dev/null");

		$model_name = "$output_dir/$query_name.pdb";

		if (-f $model_name)
		{

			if (!open(RES, "$output_dir/cmfr.eng"))
			{
				warn "can't read energy file for stx model generated in cm_fr combination.\n";
			}
			@res = <RES>;
			close RES;
			$energy = pop @res;
			chomp $energy;
			$a=$b="";
			($a, $b) = split(/=+/, $energy);

			`mv $model_name  $output_dir/cmfr.pdb`;
			print "CM and FR combined model: cmfr.pdb is generated.\n";
			$cm_fr_flag = 1; 
		}
		else
		{
			print "fail to generate structure model from cm and fr combination.\n";
			print "run the following modeller command to find out why:\n";
			print("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $output_dir $output_dir/cmfr.pir $cm_model_num > $output_dir/cmfr.eng 2>/dev/null\n");
		}
	}
	else
	{
		print "No new FR alignment is added into CM alignment. So no new cmfr structure is generated.\n"; 
	}
}
else
{
	print "No CM alignment is found. No CM and FR combination is created. \n";
}
###############################End of CM and FR combination#################################


###############Step 4: Combine cm or cmfr or fr1 with AB-Intio if necessary############################
# To do ... 
#
######################End of CM/FR/AB Combination######################################################



###############Step 5: Model Selection#################################################
#Rank models using Verify3D 
#Check if there is Ca clashes (it is important to avoid clashes)
#generate five models 
################End of Model Selection#################################################
