#!/usr/bin/perl -w
##############################################################################
#The main alignment script of Fold Recognition using both simple and advanced 
#combination of alignments. (modified from fr_main_simple_comb.pl)
#It does four things: 
#	1)generate alignments between query and templates
#       2)Combined alignments using simple/advanced gap driven approach. (New)
#	3)generate stx from the top combined alignments. 
#Inputs:
#	fr option file, query file(fasta), output dir
#Ouputs:
#	alignment file, pdb files, modeller energy file
#	pairwise dataset(maybe)
#requirements:
#	for each template: template pdb file should be temp_name.atom.gz 
#Modified from fr_main_align.pl
#Author: Jianlin Cheng
#Start Date: 11/2/2005
#
#modified from fr_main_align_join.pl
#Function: generate a structure from a query protein from a specified template (pdb code)
#Start date: 7/16/2006
##############################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: fr option file, query file(fasta), template id(pdb code + chain id), output dir.\n";
}

$option_file = shift @ARGV;
$query_file = shift @ARGV;
$temp_id = shift @ARGV;
$temp_id = uc($temp_id);
$out_dir = shift @ARGV;

-f $option_file || die "option file doesn't exist.\n";
-f $query_file || die "query file doesn't exist.\n";
length($temp_id) == 5 || die "chain id should be five chars.\n";
-d $out_dir || die "output dir doesn't exist.\n";

#read fasta file
open(QUERY, $query_file) || die "can't read query file.\n";
$qname = <QUERY>;
close QUERY;
if ($qname =~ />(\S+)/)
{
	$qname = $1;
}
else
{
	die "query is not in fasta format.\n";
}

`cp $query_file $out_dir/$qname.fas`; 

#read option file

#total number of templates to select.
#correspond to fr_temp_select_num option.
$top_num  = 10;  

#number of structure to generate
$fr_stx_num = 5; 

#minimum cover size for a template to be used in alignment combination
$fr_min_cover_size = 20;

#maximum gap size to stop using more templates in alignment combination
$fr_gap_stop_size = 20; 

#maximum linker size added to the ends of segments of filling gaps.
$fr_max_linker_size=10;

#alignment combination method
$fr_align_comb_method="advanced";

#join max size for advanced combination
$adv_comb_join_max_size = -1; 

#options for sorting local alignments
$sort_svm_rank = "no";
$sort_svm_delta_rvalue = 0.01;
$sort_svm_delta_resolution = 2;
$fr_add_stx_info_rm_identical = "no";
$fr_rm_identical_resolution = 2;

open(OPTION, $option_file) || die "can't read option file.\n";
@options = <OPTION>;
close OPTION;
foreach $line (@options)
{
	if ($line =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($line =~ /^fr_template_lib_file\s*=\s*(\S+)/)
	{
		$fr_template_lib_file = $1; 
	}
	if ($line =~ /^modeller_dir\s*=\s*(\S+)/)
	{
		$modeller_dir = $1; 
	}
	if ($line =~ /^atom_dir\s*=\s*(\S+)/)
	{
		$atom_dir = $1; 
	}
	if ($line =~ /^num_model_simulate\s*=\s*(\S+)/)
	{
		$num_model_simulate = $1; 
	}
	if ($line =~ /^fr_temp_select_num\s*=\s*(\S+)/)
	{
		$top_num = $1; 
	}
	if ($line =~ /^fr_stx_num\s*=\s*(\S+)/)
	{
		$fr_stx_num = $1; 
	}
	if ($line =~ /^fr_min_cover_size\s*=\s*(\S+)/)
	{
		$fr_min_cover_size = $1; 
	}
	if ($line =~ /^fr_gap_stop_size\s*=\s*(\S+)/)
	{
		$fr_min_cover_size = $1; 
	}
	if ($line =~ /^fr_max_linker_size\s*=\s*(\S+)/)
	{
		$fr_max_linker_size = $1; 
	}
	if ($line =~ /^fr_align_comb_method\s*=\s*(\S+)/)
	{
		$fr_align_comb_method = $1; 
	}
	if ($line =~ /^adv_comb_join_max_size\s*=\s*(\S+)/)
	{
		$adv_comb_join_max_size = $1; 
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
}
-d $prosys_dir || die "prosys dir doesn't exist.\n";
-d $modeller_dir || die "modeller dir doesn't exist.\n";
-d $atom_dir || die "atom dir doesn't exist.\n";
-f $fr_template_lib_file || die "fold recognition template library file doesn't exist.\n";
$num_model_simulate > 0 || die "modeller number of models to simulate should be bigger than 0.\n";

$top_num > 0 || die "number of templates to select must be > 0\n";
$fr_stx_num > 0 && $fr_stx_num <= $top_num || die "number of stx to generate must be <= template number.\n";
$fr_min_cover_size > 0 || die "fr: minimum gap cover size must be > 0\n";
$fr_gap_stop_size > 0 || die "fr: gap stop size must be  > 0\n";
$fr_max_linker_size >= 0 || die "fr: gap stop size must be  >= 0\n";

if ($fr_add_stx_info_rm_identical eq "yes")
{
	if (!defined $chain_stx_info || !-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to fr alignments.\n";
		$fr_add_stx_info_rm_identical = "no";
	}
}

$cur_dir = `pwd`;
chomp $cur_dir;
if (substr($out_dir, 0, 1) eq "/")
{
	$query_dir = $out_dir;
}
else
{
	if (substr($out_dir, 0, 2) eq "./")
	{
		$query_dir = "$cur_dir/" . substr($out_dir,2);
	}
	else
	{
		$query_dir = "$cur_dir/" . $out_dir; 
	}
}


#overwrite the option file to add query dir
open(OPTION, ">$option_file.add") || die "can't create a temporary option file.\n";
print OPTION join("", @options);
print OPTION "\nquery_dir=$query_dir\n";

#rank templates for the query
$rank_file = "$query_dir/$qname.rank";
#create a template file
open(RANK, ">$rank_file") || die "can't create rank file.\n";
print RANK "Ranked templates for $qname, total = 1\n";
print RANK "1 $temp_id 0.5\n";
close RANK;

#generate profile-profile alignments between query and templates. 
#print "generate profile-profile alignments for top $top_num templates...\n";
open(RANK, $rank_file) || die "can't read ranked templates file.\n";
@rank = <RANK>;
close RANK;
$select_file = "$query_dir/$qname.sel";
open(SEL, ">$select_file") || die "can't create selected templates file.\n";
$title = shift @rank;
print SEL $title;
$i = 0;
for ($i = 0; $i < @rank; $i++)
{
	$record = $rank[$i];
	print SEL $record;
}
close SEL;
$align_file = "$query_dir/$qname.fr.pir";
system("$prosys_dir/script/fr_gen_align.pl $option_file.add $query_file $fr_template_lib_file $select_file $align_file");
#print "done.\n";

#print "generate profile-profile alignment between query and template.\n";

open(ALIGN, $align_file) || die "can't read profile-profile alignment file.\n"; 
@align = <ALIGN>;
close ALIGN;
%tscores = (); 
while (@align)
{
	#read alignments for one template	
	$title = shift @align;
	@group = ();
	while (@align)
	{
		$line = shift @align;
		if ($line =~ /=====/)
		{
			shift @align;
			#shift @group; 
			pop @group; 
			last;	
		}
		else
		{
			push @group, $line;
		}
	}
	#create  a pir alignment file for the template
	($rank, $tname, $score) = split(/\s+/, $title);
	$temp_pir_file = "$query_dir/$tname.pir";
	open(TEMP, ">$temp_pir_file") || die "can't create pir file for $tname.\n";
	print TEMP join("", @group);
	close TEMP; 
	$tscores{$tname} = $score; 
}

#generate tertiary structures from each template.
print "generate structure from the template...\n";
open(ENG, ">$query_dir/$qname.energy") || die "can't create energy file.\n";

$temp_pir_file = "$query_dir/$temp_id.pir";

#check if the combined alignment file exist.
if (! -f $temp_pir_file)
{
	die "pir alignment file: $temp_pir_file is not found. not structure generated.\n";
}

#remove identical and add structural information into alignments
if ($fr_add_stx_info_rm_identical eq "yes")
{
	system("$prosys_dir/script/pir_proc_resolution.pl $temp_pir_file $chain_stx_info $fr_rm_identical_resolution $temp_pir_file.rmsame");
	`mv $temp_pir_file $temp_pir_file.org`;
	`mv $temp_pir_file.rmsame $temp_pir_file`; 
}


#generate structures from the template
system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $query_dir $temp_pir_file $num_model_simulate > $temp_id.eng 2>/dev/null");

#generate stx model name
$model_name = "$query_dir/$qname.pdb";

if (-f $model_name)
{

	if (!open(RES, "$temp_id.eng"))
	{
		warn "can't read energy file for stx model $i.\n";
	}
	@res = <RES>;
	close RES;
	$energy = pop @res;
	chomp $energy;
	$a=$b="";
	($a, $b) = split(/=+/, $energy);

	print "model: $qname.pdb is generated.\n";
	print ENG "Modeller energy of the model is $b.\n";

	###########################################################################
	#need to read rank and svm_score for the most significant template used.
	#To here: read pir file, find the first template, get its rank and svm score. use $tscores defined
	#in alignment combination region.
	#print ENG "rank = $rank, svm_score = $score\n";
	#############################################################################
	print "Modeller energy of the model = $b\n\n";
}
else
{
	print "fail to generate structure model from template $temp_id.pir.\n";
	print "run the following modeller command to find out why:\n";
	print("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $query_dir $temp_pir_file $num_model_simulate 2>/dev/null\n\n");
}

close ENG;
print "done.\n";

`rm $option_file.add`; 

#remove modeller temporary files
`rm $query_dir/*.D00000* $query_dir/*.V9999* 2>/dev/null`; 
