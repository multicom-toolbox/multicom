#!/usr/bin/perl -w

##########################################################################
#The main script of comparative modelling from scratch using combinations
#Modified from cm_ts.pl
#Inputs: option file, fasta file, output dir.
#Outputs: blast output file, local alignment file, combined pir msa file,
#         pdb file (if available), and log file
#Author: Jianlin Cheng
#Date: 10/03/2005
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
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

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
	(-f "$nr_dir/nr.phr" || -f "$nr_dir/nr.pal") || die "can't find the nr database.\n"; 

	#use the old version of cm_psiblast_temp.pl without much options
	#system("$script_dir/cm_psiblast_temp.pl $blast_dir $nr_dir/nr $pdb_db_dir/pdb_cm $fasta_file $fasta_file.blast $cm_blast_evalue"); 

	#use new version: cm_psiblast_temp_opt.pl with many options to tune
	system("$script_dir/cm_psiblast_temp_opt.pl $option_file $fasta_file $fasta_file.blast"); 
}
else
{
	die "can't find NR database. Stop!\n";
	#The following blasting on PDB only is not used anymore because the performance is worse.
	print "blast PDB to find homology templates...\n";
	system("$script_dir/cm_psiblast_temp.pl $blast_dir none $pdb_db_dir/pdb_cm $fasta_file $fasta_file.blast $cm_blast_evalue"); 

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
if ($cm_comb_method eq "blast_comb")
{
	system("$script_dir/cm_align_blast.pl $fasta_file $fasta_file.local $cm_align_evalue $cm_max_gap_size $cm_min_cover_size $fasta_file.pir");
}
else #use a new version of combination
{
	system("$script_dir/blast_align_comb.pl $script_dir $fasta_file $fasta_file.local $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $fasta_file.pir");  
}

open(PIR, "$fasta_file.pir") || die "can't generate pir file from local alignments.\n";
@pir = <PIR>;
close PIR; 
if (@pir <= 4)
{
	die "no pir alignments are generated from target: $name\n"; 
}

print "Use Modeller to generate tertiary structures...\n"; 
#generate tertiary structure from pir msa.
#system("$script_dir/pir2ts.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $model_num");
system("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $cm_model_num");

`mv model.log $fasta_file.log`; 

print "Comparative modelling for $name is done.\n"; 

