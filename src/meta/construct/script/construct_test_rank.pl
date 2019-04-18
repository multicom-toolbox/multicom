#!/usr/bin/perl -w
########################################################################
#Generate a consensus template list from hits found by blast, csblast, 
#csiblat, psi-blast, sam, hmmer, hhsearch, hhsearch15, prc, and
#compass. And then build consenus multiple structure alignments and use
#them to alignment with query profile for model generation.
#In addition, spem will be used to align top templates not found by sp3
#to generate global alignments between the top templates and the query.
#Author: Jianlin Cheng
#Start Date: 2/17/2010
#Input parameters: input dir (search results of other components), 
#option file, output dir 
#Output: two groups of models. Group 1 - spem, Group - construct
#The system will be tested on T0487, T0446 (we will use multiple alignment methods
#to see which one gives us the best results) 
#
#######################################################################
#Version 2 (added 4/25/2010): add new alignment: hhsearch profile-profile to align centers
#The local alignments will be complemented by spem global-global alignment
#new models are named as star0-4. 
#######################################################################

$TIME_OUT_FREQUENCY = 60;
#$TIME_OUT_FREQUENCY = 1;
$LOCAL_WAIT_TIME = 5; 
#$LOCAL_WAIT_TIME = 1; 

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, common output dir(full_length dir).\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

-f $fasta_file || die "can't find $fasta_file in construct.\n";

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

$output_dir = $work_dir . "/construct/";
`mkdir $output_dir 2>/dev/null`; 
`cp $fasta_file $output_dir 2>/dev/null`; 
`cp $option_file $output_dir 2>/dev/null`; 
chdir $output_dir; 

open(FASTA, $fasta_file);
$query_name = <FASTA>;
chomp $query_name;
$query_name = substr($query_name, 1); 
close FASTA;

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#take only filename from fasta file
$pos = rindex($option_file, "/");
if ($pos >= 0)
{
	$option_file = substr($option_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";

$prosys_dir = "";
$modeller_dir = "";
$atom_dir = "";
$spem_dir = "";
$lobster_dir = ""; #diretory for muscle and lobster
$meta_dir = "";
$construct_dir = "";
$tm_align = "";

#time out time is set to 20 hours (60 * 60 * 20)
$time_out = 18000; 
$thread_num = 1; 
$template_num = 10; 
$sim_num = 10; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}

	if ($line =~ /^num_model_simulate/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sim_num = $value; 
	}

	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^spem_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$spem_dir = $value; 
	}

	if ($line =~ /^hhblits_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^lobster_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$lobster_dir = $value; 
	}

	if ($line =~ /^construct_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$construct_dir = $value; 
	}
	if ($line =~ /^tm_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_align = $value; 
	}

	if ($line =~ /^time_out/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$time_out = $value; 
	}

	if ($line =~ /^template_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$template_num = $value; 
	}

	if ($line =~ /^construct_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$construct_num = $value; 
	}

	if ($line =~ /^thread_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$thread_num = $value; 
	}
}

-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
#-d $spem_dir || die "can't find $spem_dir.\n";
-d $lobster_dir || die "can't find $lobster_dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $construct_dir || die "can't find $construct_dir.\n";
-f $tm_align || die "can't find $tm_align.\n";
-d $hhblits_dir || die "can't find $hhblits_dir.\n";

$time_out >= $TIME_OUT_FREQUENCY || die "time out is too short.\n";



#@source_dir = ("blast", "csblast", "psiblast", "csiblast", "hhsearch", "hhsearch15", "hmmer", "compass", "sam", "prc", "sp3"); #six are based pdb_cm, four are based on sort90
#@source_dir = ("blast", "csblast", "psiblast", "csiblast", "hhsearch", "hhsearch15", "hmmer", "compass", "sam", "prc", "sp3", "ffas", "hhsearch12"); #six are based pdb_cm, four are based on sort90
#@source_dir = ("blast", "csblast", "psiblast", "csiblast", "hhsearch", "hhsearch15", "hmmer", "compass", "sam", "prc", "sp3", "ffas", "hhsearch12", "hhsearch151", "hhblits", "muster", "hhpred", "hhsuite", "fugue"); #six are based pdb_cm, four are based on sort90
@source_dir = ("psiblast", "csiblast", "hhsearch", "hhsearch15", "hmmer", "compass", "sam", "prc", "sp3", "ffas", "hhsearch151", "hhblits", "muster", "hhpred", "hhsuite", "fugue"); #six are based pdb_cm, four are based on sort90
@source_dir = ("psiblast", "csiblast", "hhsearch", "hhsearch15", "hmmer", "compass", "sam", "prc", "ffas", "hhsearch151", "hhblits", "hhblits3", "muster", "hhpred", "hhsuite", "raptorx"); #six are based pdb_cm, four are based on sort90


$rounds = int($time_out / $TIME_OUT_FREQUENCY); 
$count = 0; 
$first = 1; 

#frequencies of templates
%temp2freq = (); 

$psiblast_local_file = "";
$hhsearch_local_file = ""; 
$query_msa_file = "";
while (1)
{
	#sleep one minute
#	print "Construct waits for 60 seconds...\n";
#	sleep($TIME_OUT_FREQUENCY);
	if ($first == 1)
	{
		$first = 0; 
		#get a list of source directories
		foreach $sub (@source_dir)
		{

			$sub_dir = $work_dir . "/" . $sub;

			#########################################################
			#old version of hhsearch, it shares directory with blast
			if ($sub eq "hhsearch12")
			{
				`ln -f -s $work_dir/blast $sub_dir`; 	
			}
			#########################################################

			if (-d $sub_dir)
			{
				push @input_dirs, $sub_dir;	
				push @flags, 0; 
			}
		}

	}	

	#check if template information is available in each directory
	$finished = 0; 	
	$to_do = @input_dirs; 
	for ($i = 0; $i < $to_do; $i++)
	{
		$sub_dir = $input_dirs[$i];
		if ($flags[$i] == 1)
		{
			$finished++; 
			next;
		}	

		$local_file = ""; 
		if ($sub_dir =~ /csiblast$/)
		{
			$local_file = "$sub_dir/$fasta_file.local";	
		}
		elsif ($sub_dir =~ /csblast$/)
		{
			$local_file = "$sub_dir/$fasta_file.local";	
		}
		elsif ($sub_dir =~ /psiblast$/)
		{
			$local_file = "$sub_dir/$fasta_file.easy.local";	
			$psiblast_local_file = $local_file; 
		}
		elsif ($sub_dir =~ /blast$/)
		{
			$local_file = "$sub_dir/$fasta_file.easy.local";	
		}
		elsif ($sub_dir =~ /compass$/)
		{
			$local_file = "$sub_dir/$fasta_file.local";	
		}		
		elsif ($sub_dir =~ /hhsearch15$/)
		{
			$local_file = "$sub_dir/$fasta_file.local";	
			$hhsearch_local_file = $local_file; 
		}
		elsif ($sub_dir =~ /hhsearch$/)
		{
			$local_file = "$sub_dir/$fasta_file.local";	
			$query_msa_file = "$sub_dir/$query_name.align";
		}
		elsif ($sub_dir =~ /hmmer$/)
		{
			$local_file = "$sub_dir/$query_name.rank";	
		}
		elsif ($sub_dir =~ /sam$/)
		{
			$local_file = "$sub_dir/$query_name.rank";	
		}
		elsif ($sub_dir =~ /prc$/)
		{
			$local_file = "$sub_dir/$query_name.prank";	
		}
		elsif ($sub_dir =~ /sp3$/)
		{
			$local_file = "$sub_dir/$query_name.rank";
		}
		elsif ($sub_dir =~ /hhsearch12/)
		{
			$local_file = "$sub_dir/$query_name.rank";
		}
		elsif ($sub_dir =~ /hhsearch151/)
		{
			$local_file = "$sub_dir/$query_name.rank";
		}
		elsif ($sub_dir =~ /hhblits/)
		{
			$local_file = "$sub_dir/$query_name.filter.rank";
		}
		elsif ($sub_dir =~ /hhblits3/)
		{
			$local_file = "$sub_dir/$query_name.filter.rank";
		}
		elsif ($sub_dir =~ /hhpred/)
		{
			$local_file = "$sub_dir/$query_name.filter.rank";
		}
		elsif ($sub_dir =~ /muster/)
		{
			$local_file = "$sub_dir/$query_name.filter.rank";
		}
		elsif ($sub_dir =~ /fugue/)
		{
			$local_file = "$sub_dir/$query_name.filter.rank";
		}
		elsif ($sub_dir =~ /raptorx/)
		{
			$local_file = "$sub_dir/$query_name.rank";
		}
		elsif ($sub_dir =~ /hhsuite/)
		{
			$local_file = "$sub_dir/$query_name.rank";
		}
		elsif ($sub_dir =~ /ffas/)
		{
			$local_file = "$sub_dir/$fasta_file.rank";
		}

		if (-f $local_file)
		{
			#select top 10 unique templates
			$flags[$i] = 1; 
			$finished++; 
			if ($local_file =~ /local$/)
			{
				#get up to 10 templates
				
				open(LOCAL, $local_file) || die "can't read local alignment file: $local_file.\n";  
				@local = <LOCAL>;
				shift @local;
				shift @local;
				close LOCAL;

				@templates = (); 
			
				$tnum = 1; 
				while ($tnum <= $template_num && @local >= 4)
				{

					if ($tnum == 1)
					{
						#try to rank the first one higher
						$weight = 2; 
					}	
					else
					{
						$weight = 1; 
					}

					$temp_info = shift @local;
					shift @local; shift @local; shift @local; shift @local;

					@fields = split(/\s+/, $temp_info); 
					$temp_name = $fields[0]; 
				
					#check if the template is found before	
					$bFound = 0; 
					foreach $entry (@templates)
					{
						if ($entry eq $temp_name)
						{
							$bFound = 1;
							last;
						}
					}
					if ($bFound == 0)
					{
						$tnum++; 
						push @templates, $temp_name;


						if (exists $temp2freq{$temp_name})
						{
							$temp2freq{$temp_name} += $weight;
						}
						else
						{
							$temp2freq{$temp_name} = $weight;
						}

					}
				}

			}
			elsif ($local_file =~ /rank$/)
			{
				#sp3 case
			#	sleep($LOCAL_WAIT_TIME); 
				open(RANK, $local_file);  
				@rank = <RANK>;
				close RANK; 

				shift @rank;
				
				$tnum = 1; 
				while ($tnum <= $template_num && @rank > 0)
				{

					if ($tnum == 1)
					{
						#try to rank the first one higher
						$weight = 2; 
					}	
					else
					{
						$weight = 1; 
					}
					$temp_info = shift @rank;
					@fields = split(/\s+/, $temp_info); 
					$temp_name = $fields[1]; 
					if (exists $temp2freq{$temp_name})
					{
						$temp2freq{$temp_name} += $weight;
					}
					else
					{
						$temp2freq{$temp_name} = $weight;
					}
					$tnum++; 
				}


			}
		}


	}

	print "number of finished tasks: $finished, number of tasks to do: $to_do\n";

	if ($finished == $to_do)
	{
		last; 
	}

	$count++;
	if ($count >= $rounds)
	{
		last;
	}
}

#General alignment quality: (blast = csblast = csiblast = psiblast) = hhsearch.
#if can't find local alignments from above, then COM, SAM, PRC, HMMER
#then finally global alignment from spem
foreach $id (keys %temp2freq)
{
	push @select_temp, {
		name => $id,
		frequency => $temp2freq{$id}
	}; 	

}

@select_temp = sort {$b->{"frequency"} <=> $a->{"frequency"}} @select_temp;

@select_temp > 0 || die "No templates are ranked. Construct stops.\n";

$construct_file = $output_dir . "/construct.rank";
open(CONSTRUCT, ">$construct_file") || die "can't create $construct_file.\n";
print CONSTRUCT "Template\tFrequency\n";

for ($i = 0; $i < @select_temp; $i++)
{
	$order = $i + 1; 
	print CONSTRUCT $order, "\t", $select_temp[$i]->{"name"}, "\t", $select_temp[$i]->{"frequency"}, "\n";
}
close CONSTRUCT; 

