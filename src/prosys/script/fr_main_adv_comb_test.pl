#!/usr/bin/perl -w
##############################################################################
#The main control script of Fold Recognition using both simple and advanced 
#combination of alignments. (modified from fr_main_simple_comb.pl)
#It does four things: 
#	1)generate query required files
#	2)rank the templates for the query
#	3)generate alignments between query and templates
#       4)Combined alignments using simple/advanced gap driven approach. (New)
#	5)generate stx from the top combined alignments. 
#Inputs:
#	fr option file, query file(fasta), output dir
#Ouputs:
#	ranked templates file, alignment file, pdb files, modeller energy file
#	pairwise dataset(maybe)
#requirements:
#	for each template: template pdb file should be temp_name.atom.gz 
#Author: Jianlin Cheng
#Start Date: 9/15/2005
##############################################################################

if (@ARGV != 3)
{
	die "need 3 parameters: fr option file, query file(fasta), output dir.\n";
}

$option_file = shift @ARGV;
$query_file = shift @ARGV;
$out_dir = shift @ARGV;

-f $option_file || die "option file doesn't exist.\n";
-f $query_file || die "query file doesn't exist.\n";
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
	if ($line =~ /fr_max_linker_size\s*=\s*(\S+)/)
	{
		$fr_max_linker_size = $1; 
	}
	if ($line =~ /fr_align_comb_method\s*=\s*(\S+)/)
	{
		$fr_align_comb_method = $1; 
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

#generate required query files.
print "generate query related files...\n";
#query dir must use absolute path
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

system("$prosys_dir/script/gen_query_files.pl $option_file $query_file $query_dir");
print "done.\n";

#overwrite the option file to add query dir
open(OPTION, ">$option_file.add") || die "can't create a temporary option file.\n";
print OPTION join("", @options);
print OPTION "\nquery_dir=$query_dir\n";

#rank templates for the query
print "rank the templates for query $qname\n";
$rank_file = "$query_dir/$qname.rank";
system("$prosys_dir/script/fr_rank_templates.pl $option_file.add $query_file $fr_template_lib_file $rank_file");
print "done.\n";

#generate profile-profile alignments between query and templates. 
print "generate profile-profile alignments for top $top_num templates...\n";
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
	if ($i < $top_num)
	{
		$record = $rank[$i];
		print SEL $record;
	}
}
close SEL;
$align_file = "$query_dir/$qname.fr.pir";
system("$prosys_dir/script/fr_gen_align.pl $option_file.add $query_file $fr_template_lib_file $select_file $align_file");
print "done.\n";

#combine alignments using gap-driven approach
print "combine alignments using gap driven approach from top to down.\n";

open(ALIGN, $align_file) || die "can't read profile-profile alignment file.\n"; 
@align = <ALIGN>;
close ALIGN;
@candidate_temps = (); 
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
	push @candidate_temps, $temp_pir_file; 
	$tscores{$tname} = $score; 
}

#combine alignments here (stop here....)
open(CANDI, ">$qname.can") || die "can't create candidate file: $qname.can\n";
print CANDI join("\n", @candidate_temps);
close CANDI; 

$output_prefix = "$query_dir/simple_comb"; 
print "combination method: $fr_align_comb_method\n";
if ($fr_align_comb_method eq "simple")
{
	print "use simple combination...\n";
	system("$prosys_dir/script/pir_simple_comb.pl $prosys_dir/script/ $qname.can $fr_min_cover_size $fr_gap_stop_size $fr_stx_num $output_prefix");
}
else #advanced combination
{
	print "use advanced combination...\n";
	system("$prosys_dir/script/pir_adv_comb.pl $prosys_dir/script/ $qname.can $fr_min_cover_size $fr_gap_stop_size $fr_max_linker_size $fr_stx_num $output_prefix");
	
}

#`rm $qname.can`; 
`mv $qname.can $query_dir/$qname.can`; 

#generate tertiary structures from each template.
print "generate structures for combined templates...\n";
open(ENG, ">$query_dir/$qname.energy") || die "can't create energy file.\n";

for ($i = 1; $i <= $fr_stx_num; $i++)
{
	$temp_pir_file = "$output_prefix$i.pir";
	#check if the combined alignment file exist.
	if (! -f $temp_pir_file)
	{
		print "pir alignment file: $temp_pir_file is not found. not structure generated.\n";
		next; 
	}


	#generate structures from the template
	system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $query_dir $temp_pir_file $num_model_simulate > $output_prefix$i.eng 2>/dev/null");

	#generate stx model name
	$model_name = "$query_dir/$qname.pdb";

	if (-f $model_name)
	{

		if (!open(RES, "$output_prefix$i.eng"))
		{
			warn "can't read energy file for stx model $i.\n";
		}
		@res = <RES>;
		close RES;
		$energy = pop @res;
		chomp $energy;
		$a=$b="";
		($a, $b) = split(/=+/, $energy);

		`mv $model_name  $output_prefix$i.pdb`;
		print "model: $output_prefix$i.pdb is generated.\n";
		print ENG "Modeller energy of the model $output_prefix$i.pdb = $b, ";

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
		print "fail to generate structure model from template $output_prefix$i.pir.\n";
		print "run the following modeller command to find out why:\n";
		print("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $query_dir $temp_pir_file $num_model_simulate > $output_prefix$i.eng 2>/dev/null\n\n");
	}

	#`rm $tname.eng`; 
}
close ENG;
print "done.\n";

`rm $option_file.add`; 

#remove modeller temporary files
`rm $query_dir/*.D00000* $query_dir/*.V9999*`; 
