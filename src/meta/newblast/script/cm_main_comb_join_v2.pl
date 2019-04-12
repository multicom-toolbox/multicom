#!/usr/bin/perl -w

##########################################################################
#The main script of comparative modelling from scratch using combinations
#Modified from cm_ts.pl
#Inputs: option file, fasta file, output dir.
#Outputs: blast output file, local alignment file, combined pir msa file,
#         pdb file (if available), and log file
#Author: Jianlin Cheng
#Modifided from cm_main_comb.pl
#Date: 11/02/2005
##########################################################################
#Format of Option file:
#script_dir = value
#blast_dir = value
#modeller_dir = value
#pdb_db_dir = value
#nr_dir = value (none: not use nr)
#atom_dir = value
#cm_blast_evalue = ####  (evalue threshold used by psi-blast to choose templates)
#cm_align_evalue = #### (not used any more)
#cm_max_gap_size = #### (max gap size is allowed before stop adding more templates)
#cm_min_cover_size = #### (min gap cover size for template to be chosen)
#cm_model_num = ####  (number of model to be simulated: The model with lowest energy will be chosen)
#cm_comb_method=#### (choose which version of combination is used)
#cm_max_linker_size=###(<0: simple combination; >=0: advanced combination, value is the max linker size at ends)
#cm_evalue_comb=####(threshold to include significant matched templates. templates with evalue lower than
#e^value will always be included no matter how many gaps are filled by the template).
#
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

`cp $fasta_file $work_dir 2>/dev/null`; 
`cp $option_file $work_dir 2>/dev/null`; 
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
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

$adv_comb_join_max_size = -1; 

#options for sorting local alignments
$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "no";
$rm_identical_resolution = 2;

$cm_clean_redundant_align = "no";

$cm_evalue_diff = 1000; 

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

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_blast_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_align = $value; 
	}

	if ($line =~ /^sort_blast_local_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_ratio = $value; 
	}

	if ($line =~ /^sort_blast_local_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_delta_resolution = $value; 
	}

	if ($line =~ /^add_stx_info_rm_identical/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$add_stx_info_rm_identical = $value; 
	}

	if ($line =~ /^rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rm_identical_resolution = $value; 
	}

	if ($line =~ /^cm_clean_redundant_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_clean_redundant_align = $value; 
	}

	if ($line =~ /^cm_evalue_diff/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_diff = $value; 
	}
}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $newblast_dir || die "can't find new blast dir.\n";
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

if ($sort_blast_align eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
	}
}

if ($add_stx_info_rm_identical eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to alignments.\n";
		$add_stx_info_rm_identical = "no";
	}
}

if ($sort_blast_local_ratio <= 1 || $sort_blast_local_delta_resolution <= 0)
{
		warn "sort_blast_local_ratio <= 1 or delta resolution <= 0. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
}
if ($rm_identical_resolution <= 0)
{
	warn "rm_identical_resolution <= 0. Don't add structure information and remove identical alignments.\n";
	$add_stx_info_rm_identical = "no";
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

{
	print "blast PDB to find homology templates...\n";
	system("$newblast_dir/script/cm_psiblast_temp.pl $blast_dir none $pdb_db_dir/pdb_cm $fasta_file $fasta_file.blast $cm_blast_evalue"); 

}

#parse the blast output
print "parse blast output...\n"; 
system("$newblast_dir/script/cm_parse_blast.pl $fasta_file.blast $fasta_file.local");
open(LOCAL, "$fasta_file.local") || die "can't read the parsed output results.\n"; 
@local = <LOCAL>;
close LOCAL;
if (@local <= 2)
{
	die "no significant templates are found. stop.\n";
}

#sort blast local alignments if necessary
if ($sort_blast_align eq "yes")
{
	print "resort blast local alignments according to structure information.\n";
	system("$script_dir/sort_blast_local.pl $fasta_file.local $chain_stx_info $sort_blast_local_ratio $sort_blast_local_delta_resolution $fasta_file.local.sort");
	`mv $fasta_file.local $fasta_file.local.nosort`;
	`mv $fasta_file.local.sort $fasta_file.local`; 
}

print "generate PIR alignments...\n";
#convert local alignments into a pir msa.
if ($cm_comb_method eq "blast_comb")
{
	system("$script_dir/cm_align_blast.pl $fasta_file $fasta_file.local $cm_align_evalue $cm_max_gap_size $cm_min_cover_size $fasta_file.pir");
}
else #use a new version of combination
{
	#system("$script_dir/blast_align_comb_join.pl $script_dir $fasta_file $fasta_file.local $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $adv_comb_join_max_size $fasta_file.pir");  
	system("$script_dir/blast_align_comb_evalue.pl $script_dir $fasta_file $fasta_file.local $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $adv_comb_join_max_size $cm_evalue_diff $fasta_file.pir");  
}

