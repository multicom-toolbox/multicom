#!/usr/bin/perl -w
##############################################################################
#Given a list of consensus templates, generate profile-profile alignments
#do local-global  alignment combination, and generate models
#Author: Jianlin Cheng
#Modifided from casp8/meta/multicom_gen.pl 
#Start Date: 2/22/2010
##############################################################################
use Cwd 'abs_path';

if (@ARGV != 4)
{
	die "need 4 parameters: construct option file, query file(fasta), template list file, output dir.\n";
}

$option_file = shift @ARGV;
$query_file = shift @ARGV;
$rank_file = shift @ARGV;
$out_dir = shift @ARGV;

-f $option_file || die "option file doesn't exist.\n";
-f $query_file || die "query file doesn't exist.\n";
-f $rank_file || die "$rank_file does not exist.\n";
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

$thread_num = 1;

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
	if ($line =~ /^new_hhsearch_dir\s*=\s*(\S+)/)
	{
		$new_hhsearch_dir = $1; 
	}
	if ($line =~ /^psipred_dir\s*=\s*(\S+)/)
	{
		$psipred_dir = $1; 
	}
	if ($line =~ /^num_model_simulate\s*=\s*(\S+)/)
	{
		$num_model_simulate = $1; 
	}

	if ($line =~ /^construct_num\s*=\s*(\S+)/)
	{
		$construct_num = $1; 
	}

	if ($line =~ /^template_num\s*=\s*(\S+)/)
	{
		$template_num = $1; 
	}

	if ($line =~ /^thread_num\s*=\s*(\S+)/)
	{
		$thread_num = $1;
	}
}
-d $prosys_dir || die "prosys dir doesn't exist.\n";
-d $modeller_dir || die "modeller dir doesn't exist.\n";
-d $atom_dir || die "atom dir doesn't exist.\n";
-f $fr_template_lib_file || die "fold recognition template library file doesn't exist.\n";
$num_model_simulate > 0 || die "modeller number of models to simulate should be bigger than 0.\n";

-d $new_hhsearch_dir || die "can't find new hhsearch dir.\n";
-d $psipred_dir || die "can't find $psipred_dir.\n";

$top_num = $template_num; 
$top_num > 0 || die "number of templates to select must be > 0\n";

$fr_stx_num = $construct_num;
$fr_stx_num > 0 && $fr_stx_num <= $top_num || die "number of stx to generate must be <= template number.\n";

@temp_ids = ();
open(TEMP, $fr_template_lib_file) || die "can't read $fr_template_lib_file\n";
while (<TEMP>)
{
	$name = $_;
	chomp $name;
	$name = substr($name, 1);
	<TEMP>;
	push @temp_ids, $name;
}
close TEMP;

#generate profile-profile alignments between query and templates. 
print "generate profile-profile alignments for top $top_num templates...\n";
open(RANK, $rank_file) || die "can't read ranked templates file.\n";
@rank = <RANK>;
close RANK;

#decide how many templates to select
$select_file = "$qname.sel";
open(SEL, ">$select_file") || die "can't create selected templates file.\n";
$title = shift @rank;
print SEL $title;
$count = 0;
for ($i = 0; $i < @rank; $i++)
{
	$line = $rank[$i];
	@fields = split(/\s+/, $line);
	$name = $fields[1];
	$name = uc($name);
	$name =~ s/_/A/g;		

	#check if the name in the template list
	$found = 0;
	foreach $id (@temp_ids)
	{
		if ($id eq $name)
		{
			$found = 1;
			print "find $name\n";
			last;
		}
	}
	$found == 1 || next;

	if ($count < $top_num)
	{
		$record = $rank[$i];
		print SEL $record;
		$count++;
	}
	else
	{
		last;
	}
}
close SEL;

#######################Generate alignments in parallel############################
$query_dir = abs_path($out_dir);
`mv $qname.sel $query_dir 2>/dev/null`; 
$select_file = "$query_dir/$qname.sel";
$query_file = abs_path($query_file);

`cp $query_file $query_dir/$qname.fas`;


####################################################################################################
#generate alignment files using spem, for each template...

#must cd into the query dir contains shhm files
chdir $query_dir;

#generate alignments using spem.............
open(OPTION, ">option_file_tmp.add") || die "can't create a temporary option file.\n";
print OPTION join("", @options);
print OPTION "\nquery_dir=$query_dir\n";
print OPTION "\nalignment_method=spem\n";
close OPTION;
$align_file = "$query_dir/$qname.pir.spem";
print "generate alignments between query and $top_num templates using spem...\n";
system("$prosys_dir/script/gen_query_temp_align_proc.pl option_file_tmp.add $query_file $fr_template_lib_file $select_file $align_file");
print "done.\n";

#print "combine alignments using gap driven approach from top to down.\n";

@suffix = ("spem");

foreach $type (@suffix)
{

	print "combine alignments generated by $type...\n";
	$align_file = "$query_dir/$qname.pir.$type";
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

}
	
#generate tertiary structures from each template.
#print "generate structures for combined templates using multiple threads...\n";

chdir $query_dir;
@suffix = ("spem");

$list_file = "$query_dir/$qname.pir.list";
open(LIST, ">$list_file");
foreach $type (@suffix)
{
	for ($i = 1; $i <= $top_num; $i++)
	{
		$file = "$type$i.pir";
		if (-f $file)
		{
			print LIST $file, "\n";
		}
	}

}
close LIST;

#generate structures from the template
#system("$prosys_dir/script/gen_model_proc.pl $prosys_dir $modeller_dir $atom_dir $query_dir $list_file $num_model_simulate $thread_num $qname");

print "done.\n";

`rm option_file_tmp.add`; 

