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

if (@ARGV != 3 && @ARGV != 4)
{
	die "need three (or four) parameters: option file, sequence file, multiple sequence alignment file (optional), output dir.\n"; 
}
$msa_file = ""; 
if (@ARGV == 3)
{
	$option_file = shift @ARGV;
	$fasta_file = shift @ARGV;
	$work_dir = shift @ARGV;
}
elsif (@ARGV == 4)
{
	$option_file = shift @ARGV;
	$fasta_file = shift @ARGV;
	$msa_file = shift @ARGV;
	$work_dir = shift @ARGV;
}

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
if (-f $msa_file)
{
	`cp $msa_file $work_dir`; 
	$pos = rindex($msa_file, "/");
	if ($pos >= 0)
	{
		$msa_file = substr($msa_file, $pos + 1); 
	}
}
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
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$blast_dir = "";
$modeller_dir = "";
$nr_db = "";
$hhsuite_dir = "";
$hhblits_dir = "";
$atom_dir = "";
$hhsuitedb = "";
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
	if ($line =~ /^nr_db/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_db = $value; 
	}

	if ($line =~ /^hhsuite_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuite_dir = $value; 
	}

	if ($line =~ /^hhblits_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits_dir = $value; 
	}

	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}

	if ($line =~ /^deepmsa_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deepmsa_program = $value; 
	}

	if ($line =~ /^psipred_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psipred_dir = $value; 
	}

	if ($line =~ /^multicom_tool_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$multicom_tool_dir = $value; 
	}

	if ($line =~ /^multicom_database_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$multicom_database_dir = $value; 
	}

	if ($line =~ /^hhsuitedb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuitedb = $value; 
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
		$nr_iteration_num = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		$nr_return_evalue = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		$nr_including_evalue = ""; 
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $hhsuite_dir || die "can't find hhsearch dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $pdb_db_dir || die "can't find $pdb_db_dir.\n";
-d $psipred_dir || die "can't find psipred dir.\n"; 
-f "${hhsuitedb}_hhm.ffdata" || die "can't find hhsearch database.\n";
#-f "${nr_db}_a3m_db" || die "can't find ${nr_db}_a3m_db database.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $meta_common_dir || die "can't find $meta_common_dir.\n";
-d $multicom_tool_dir || die "can't find $multicom_tool_dir.\n";
-d $multicom_database_dir || die "can't find $multicom_database_dir.\n";
-f $deepmsa_program || die "can't find $deepmsa_program.\n";

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

#check if the fasta file and the msa file are consistent
if (-f $msa_file)
{

	if ($msa_file =~ /\.aln$/)
	{
		open(MSA, $msa_file) || die "can't read msa file: $msa_file.\n";
		$msa_seq = <MSA>;
		chomp $msa_seq;
		close MSA;
		$seq eq $msa_seq || die "The sequence in the fasta file is different than that in the msa file:\n$seq\n$msa_seq\n";
		if ($msa_file ne "$name.aln")
		{
			`mv $msa_file $name.aln`; 
			$msa_file = "$name.aln"; 
		}	
	}
	elsif ($msa_file =~ /\.a3m$/)
	{
		open(MSA, $msa_file) || die "can't read msa file: $msa_file.\n";
		<MSA>;
		$msa_seq = <MSA>;
		chomp $msa_seq;
		close MSA;
		$seq eq $msa_seq || die "The sequence in the fasta file is different than that in the msa file:\n$seq\n$msa_seq\n";
		
		if ($msa_file ne "$name.a3m")
		{
			`mv $msa_file $name.a3m`; 
			$msa_file = "$name.a3m"; 
		}	
	}
	else
	{
		die "The format of msa file: $msa_file is not correct. It must be .aln or .a3m. \n";
	}
}


#check if local alignment file exist. 
if (-f "$fasta_file.local")
{
        print "The local alignment file exists, so directly go to alignment refinement and model generation.\n";
        goto MULTICOM;
}

if (! -f $msa_file)
{
	print "Generate multiple sequence alignments using deepmsa...\n";
	system("$deepmsa_program $fasta_file ."); 
	print "Alignments have been generated.\n";
	if (-f "$name.a3m")
	{
		$msa_file = "$name.a3m";
	}
	elsif (-f "$name.aln")
	{
		$msa_file = "$name.aln";
	}
	else
	{
		die "cann't open deep msa alignment file: $name.aln or $name.a3m\n";
	}
}

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
-f $msa_file || die "Deepmsa alignment file does not exist.\n";

#$ENV{HHLIB}="$hhsuite_dir/lib/hh";


if ($msa_file =~ /\.a3m$/)
{
	#check if the msa file has the correct sequence name
	open(MSA, $msa_file) || die "can't read $msa_file.\n";	
	@msa_content = <MSA>;
	close MSA;
	$msa_name = $msa_content[0]; 
	chomp $msa_name;
	$msa_name = substr($msa_name, 1);
	if ($msa_name ne $name)
	{
		print "MSA name: $msa_name is not the same as target name: $name. Change it.\n";
		$msa_content[0] = ">$name\n";
		open(MSA, ">$msa_file") || die "can not write $msa_file.\n";
		print MSA @msa_content;
		close MSA; 
	} 


	#add secondary structure into alignments
	print("$hhblits_dir/scripts/addss_v2020.pl $multicom_tool_dir $multicom_database_dir $msa_file $name.ss.a3m -a3m\n"); 
	system("$hhblits_dir/scripts/addss_v2020.pl $multicom_tool_dir $multicom_database_dir $msa_file $name.ss.a3m -a3m"); 
	#make hmm
	system("$hhsuite_dir/bin/hhmake -i $name.ss.a3m -o $name.hmm"); 

}
elsif ($msa_file =~ /\.aln$/)
{
	system("$prosys_dir/script/msa2gde.pl $fasta_file $msa_file fasta $name.fas");
	system("$hhsuite_dir/bin/hhmake -i $name.fas -o $name.hmm");
}
else
{
	die "The format $msa_file is not correct. Stop.\n";
}

#search shhm against the database
print "Search $name.hmm against $hhsuitedb...\n";

system("$hhsuite_dir/bin/hhsearch -i $name.hmm -d $hhsuitedb -realign -mact 0"); 

if (! -f "$filename.hhr")
{
	sleep(5);
	print "hhsearch did not generate $filename.hhr, try one more time...\n";
	system("$hhsuite_dir/bin/hhsearch -i $name.ss.a3m -d $hhsuitedb -realign -mact 0"); 
	if (-f "$name.ss.hhr")
	{
		`mv $name.ss.hhr $filename.hhr`; 
	}
}

if (! -f "$filename.hhr")
{
	sleep(5);
	print "hhsearch did not generate $filename.hhr, try one more time...\n";
	system("$hhsuite_dir/bin/hhsearch -i $msa_file -d $hhsuitedb -realign -mact 0"); 
}


print "Search is done.\n";

print "generate ranking list...\n";
system("$meta_dir/script/rank_templates.pl $filename.hhr $work_dir/$name.rank");
	
#parse the blast output
print "parse hhsearch output...\n"; 

system("$meta_dir/script/parse_hhsearch.pl $filename.hhr $fasta_file.local");

#validate local alignments
system("$meta_common_dir/script/validate_local.pl $fasta_file.local $atom_dir $fasta_file.local");

#die "stop here...\n";

MULTICOM:

$align_option = "$meta_dir/align_option";
-f $align_option || die "can't find alignment option file: $align_option.\n";

#preprocess local alignments
system("$meta_common_dir/script/local_global_align.pl $align_option $fasta_file.local $fasta_file $fasta_file");

#generate structure from local alignments
system("$meta_common_dir/script/local2model.pl $option_file $fasta_file $fasta_file .");



