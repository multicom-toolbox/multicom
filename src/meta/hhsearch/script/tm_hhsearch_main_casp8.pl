#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using hhsearch and combinations
#Inputs: option file, fasta file, output dir.
#Outputs: hhsearch output file, local alignment file, combined pir msa file,
#         pdb file (if available, and log file
#Author: Jianlin Cheng
#Modifided from cm_main_comb_join.pl
#Date: 10/16/2007
##########################################################################

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
$pos = rindex($option_file, "/");
if ($pos > 0)
{
        $option_file = substr($option_file, $pos+1);
}
#
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
$hhsearch_dir = "";
$hhsearchdb = "";
$psipred_dir = "";
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

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
		$script_dir = "$prosys_dir/script";
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
	if ($line =~ /^nrdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nrdb = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^hhsearch_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^psipred_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psipred_dir = $value; 
	}

	if ($line =~ /^hhsearchdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearchdb = $value; 
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
	if ($line =~ /^nr_iteration_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
-d $psipred_dir || die "can't find psipred dir.\n"; 
-f $hhsearchdb || die "can't find hhsearch database.\n";
-d $nr_dir || die "can't find nr dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";

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
#	die "the evalue threshold for alignment combination must be <= 0.\n";
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


$nr_db = "$nr_dir/$nrdb";
print "blast NR: $nr_db to find homology templates...\n";
(-f "$nr_db.pal") || die "can't find the nr database.\n"; 

#use new version: cm_psiblast_temp_opt.pl with many options to tune
system("$blast_dir/blastpgp -i $fasta_file -o $fasta_file.blast -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db"); 

#get file name prefix
$idx = rindex($fasta_file, ".");
if ($idx > 0)
{
	$filename = substr($fasta_file, 0, $idx);
}
else
{
	$filename = $fasta_file; 
}

#convert blast output to raw alignment
print "convert blast output to alignment...\n"; 
system("$meta_dir/script/process-blast.pl $fasta_file.blast $filename.align $fasta_file");
	

#conver raw alignment to hhm
print "convert alignment to HMM...\n";
system("$prosys_dir/script/msa2gde.pl $fasta_file $filename.align fasta $fasta_file.fas");
system("$hhsearch_dir/hhmake -i $fasta_file.fas -o $filename.hhm"); 

#predict secondary structure using psipred
print "predict secondary struture...\n";
system("$psipred_dir/runpsipred $fasta_file");

#combine ss with hhm
print "add secondary structure into HMM...\n";
if (-f "$filename.horiz")
{
	system("$meta_dir/script/addpsipred2hhm.pl $filename.horiz $filename.hhm > $filename.shhm");
}
else
{
	print "psi-pred fails to generate secondary structure for hhsearch.\n";
	`cp $filename.hhm $filename.shhm`;
}

#calibrate the hhm model
print "calibrate HMM model...\n";
system("$hhsearch_dir/hhsearch -cal -i $filename.shhm -d $hhsearch_dir/cal.hhm");

#search shhm against the database
print "search HMM against HMM database...\n";
system("$hhsearch_dir/hhsearch -i $filename.shhm -d $hhsearchdb");
#output file is: name.hhr

print "generate ranking list...\n";
system("$meta_dir/script/rank_templates.pl $filename.hhr $work_dir/$name.rank");
	
#parse the blast output
print "parse hhsearch output...\n"; 
system("$meta_dir/script/parse_hhsearch.pl $filename.hhr $fasta_file.local");
open(LOCAL, "$fasta_file.local") || die "can't read the parsed output results.\n"; 
@local = <LOCAL>;
close LOCAL;
if (@local <= 2)
{
	die "no significant templates are found. stop.\n";
}


print "generate combined PIR alignments...\n";

system("$meta_dir/script/hhsearch_align_comb.pl $script_dir $fasta_file $fasta_file.local $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $adv_comb_join_max_size $cm_evalue_diff $fasta_file.pir");  

open(PIR, "$fasta_file.pir") || die "can't generate pir file from local alignments.\n";
@pir = <PIR>;
close PIR; 
if (@pir <= 4)
{
	die "no pir alignments are generated from target: $name\n"; 
}

#add structure information to pir alignment if necessary
if ($add_stx_info_rm_identical eq "yes")
{
	print "Add structural information to blast pir alignments.\n";
	system("$script_dir/pir_proc_resolution.pl $fasta_file.pir $chain_stx_info $rm_identical_resolution $fasta_file.pir.stx");
	`mv $fasta_file.pir $fasta_file.pir.nostx`;
	`mv $fasta_file.pir.stx $fasta_file.pir`; 

}

if ($cm_clean_redundant_align eq "yes")
{
	#remove redundant in the cm alignment if necessary
	#make a copy first
	`cp $fasta_file.pir $fasta_file.org.pir`;
	print "Remove redundant CM alignments if necessary.\n";
	system("$script_dir/clean_pir.pl $fasta_file.pir");
}

print "Use Modeller to generate tertiary structures...\n"; 
#generate tertiary structure from pir msa.
#system("$script_dir/pir2ts.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $model_num");

#hh0 is redundant of hh1
#system("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $work_dir $fasta_file.pir $cm_model_num");

if (-f "$name.pdb")
{
	`mv $name.pdb hh0.pdb`; 
	`mv $name.pir hh0.pir`; 
}

print "Generate a model from each template...\n";
system("$meta_dir/script/main_hhsearch_easy_casp8.pl $option_file $fasta_file $work_dir");


#`mv model.log $fasta_file.log`; 

print "Comparative modelling for $name is done.\n"; 

