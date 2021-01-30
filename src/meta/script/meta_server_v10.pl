#!/usr/bin/perl -w
###############################################################################
#This is the main entry script for protein structure meta server
#Inputs: option file, query file(fasta), output dir
#Currently the following servers are supported:
#multicom_cm, hhsearch, compass, sp3, sp2, rosetta
#ideally, the program needs five processors and the access to a remote server
#models are ranked by two model evaluation tools: model_eval and model_energy
#Author: Jianlin Cheng
#Starting Date: 1/21/2008
#End date: 4/5/2008
#Version 5: add model evaluation and ranking
#verion 7: add sam into the system
#########################################################################

#####################Read Input Parameters###################################
if (@ARGV != 3)
{
	die "need three parameters: meta option file, query file(fasta), output dir\n";
}

$meta_option = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;

#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";
use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
$query_file = abs_path($query_file);
############################################################################

###################Preprocessing of Inputs###################################
#read option file
open(OPTION, $meta_option) || die "can't read option file.\n";

$local_model_num = 50;

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^sparks_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sparks_dir = $value; 
	}

	if ($line =~ /^sparks_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sparks_option = $value; 
	}

	if ($line =~ /^csblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$csblast_dir = $value; 
	}

	if ($line =~ /^csblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$csblast_option = $value; 
	}

	if ($line =~ /^blast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_option = $value; 
	}

	if ($line =~ /^psiblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psiblast_option = $value; 
	}

	if ($line =~ /^hhsearch_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_dir = $value; 
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^hhsearch_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_option = $value; 
	}

	if ($line =~ /^hhsearch15_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch15_dir = $value; 
	}

	if ($line =~ /^hhsearch15_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch15_option = $value; 
	}

	if ($line =~ /^sam_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sam_dir = $value; 
	}

	if ($line =~ /^sam_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sam_option = $value; 
	}

	if ($line =~ /^prc_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prc_dir = $value; 
	}

	if ($line =~ /^prc_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prc_option = $value; 
	}

	if ($line =~ /^hmmer_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer_dir = $value; 
	}

	if ($line =~ /^hmmer_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer_option = $value; 
	}

	if ($line =~ /^compass_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$compass_dir = $value; 
	}

	if ($line =~ /^compass_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$compass_option = $value; 
	}

	if ($line =~ /^multicom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$multicom_dir = $value; 
	}

	if ($line =~ /^multicom_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$multicom_option = $value; 
	}

	if ($line =~ /^rosetta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosetta_dir = $value; 
	}

	if ($line =~ /^rosetta_server1/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosetta_server1 = $value; 
	}

	if ($line =~ /^rosetta_server2/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosetta_server2 = $value; 
	}

	if ($line =~ /^scwrl_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$scwrl_dir = $value; 
	}

	if ($line =~ /^max_wait_time/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$max_wait_time = $value; 
	}


	if ($line =~ /^local_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$local_model_num = $value; 
	}
}

#check the options
-d $meta_dir || die "can't find $meta_dir.\n";
-d $sparks_dir || die "can't find $sparks_dir.\n";
-d $hhsearch_dir || die "can't find $hhsearch_dir.\n";
-d $prosys_dir || die "can't find $prosys_dir.\n";
-f $hhsearch_option || die "can't find $hhsearch_option.\n";
-d $hhsearch15_dir || die "can't find $hhsearch15_dir.\n";
-f $hhsearch15_option || die "can't find $hhsearch15_option.\n";
-d $sam_dir || die "can't find $sam_dir.\n";
-f $sam_option || die "can't find $sam_option.\n";
-d $prc_dir || die "can't find $prc_dir.\n";
-f $prc_option || die "can't find $prc_option.\n";
-d $hmmer_dir || die "can't find $hmmer_dir.\n";
-f $hmmer_option || die "can't find $hmmer_option.\n";
-d $csblast_dir || die "can't find $csblast_dir.\n";
-f $csblast_option || die "can't find $csblast_option.\n";
-f $blast_option || die "can't find $blast_option.\n";
-f $psiblast_option || die "can't find $psiblast_option.\n";
-d $compass_dir || die "can't find $compass_dir.\n";
-f $compass_option || die "can't find $compass_option.\n";
-d $multicom_dir || die "can't find $multicom_dir.\n";
-f $multicom_option || die "can't find $multicom_option.\n";
-d $rosetta_dir || die "can't find $rosetta_dir.\n";
-d $scwrl_dir || die "can't find $scwrl_dir.\n";
-f $sparks_option || die "can't find $sparks_option.\n";
$max_wait_time > 10 && $max_wait_time < 600 || die "waiting time is out of range.\n";

$rosetta_server1 ne "" || die "rosetta server 1 is empty.\n";
$rosetta_server2 ne "" || die "rosetta server 2 is empty.\n";

#get query name and sequence 
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

chdir $output_dir; 

#@servers = ("hhsearch", "compass", "multicom", "sp2", "sp3", "rosetta", "rosetta2", "rosetta3"); 
@servers = ("hhsearch", "compass", "multicom", "sp3", "csblast", "csiblast", "sam", "hmmer", "blast", "psiblast", "hhsearch15", "prc"); 

$post_process = 0; 

$model_dir = "$output_dir/meta";
`mkdir $model_dir`;


$thread_num = @servers;

for ($i = 0; $i < @servers; $i++)
{
	$server = $servers[$i];
	if ( !defined( $kidpid = fork() ) )
	{
		die "can't create process $i\n";
	}
	elsif ($kidpid == 0)
	{
		print "start thread $i\n";
		`mkdir $server`; 	

		if ($server eq "sp3")
		{
			chdir $server; 

			open(FASTA, ">$query_name.fasta");
			print FASTA ">$query_name\n";
			for ($j = 0; $j < length($qseq); $j++)
			{
				print FASTA substr($qseq, $j, 1);
				if ( ($j + 1) % 70 == 0)
				{
					print FASTA "\n";
				}
			}
			print FASTA "\n";
			close FASTA;
			

			#need to convert file into a new format (at most 70 AA each line, to do)
			system("$sparks_dir/bin/scan_sp3.job $query_name.fasta");

			#rank templates
			system("$meta_dir/script/rank_sp3.pl ${query_name}_sp3.out $query_name > $query_name.rank");

			#generate alignments and models
			system("$meta_dir/script/multicom_gen.pl $sparks_option $query_file $query_name.rank .");

		}

		elsif ($server eq "sp2")
		{
	
			chdir $server; 

			open(FASTA, ">$query_name.fasta");
			print FASTA ">$query_name\n";
			for ($j = 0; $j < length($qseq); $j++)
			{
				print FASTA substr($qseq, $j, 1);
				if ( ($j + 1) % 70 == 0)
				{
					print FASTA "\n";
				}
			}
			print FASTA "\n";
			close FASTA;

			system("$sparks_dir/bin/scan_sparks2.job $query_name.fasta");
	
			#rank templates
			system("$meta_dir/script/rank_sp2.pl ${query_name}_spk2.out $query_name > $query_name.rank");

			#generate alignments and models
			system("$meta_dir/script/multicom_gen.pl $sparks_option $query_file $query_name.rank .");
		}

		elsif ($server eq "hhsearch")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server 1>out.log 2>err.log");
		}

		elsif ($server eq "hhsearch15")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$hhsearch15_dir/script/tm_hhsearch1.5_main.pl $hhsearch15_option $query_file $server");
		}

		elsif ($server eq "csblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$csblast_dir/script/multicom_csblast.pl $csblast_option $query_file $server");
		}

		elsif ($server eq "csiblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$csblast_dir/script/multicom_csiblast.pl $csblast_option $query_file $server");
		}

		elsif ($server eq "blast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$prosys_dir/script/main_blast.pl $blast_option $query_file $server");
		}

		elsif ($server eq "psiblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$prosys_dir/script/main_psiblast.pl $psiblast_option $query_file $server");
		}

		elsif ($server eq "compass")
		{
			system("$compass_dir/script/tm_compass_main.pl $compass_option $query_file $server");
		}

		elsif ($server eq "sam")
		{
			system("$sam_dir/script/tm_sam_main.pl $sam_option $query_file $server");
		}

		elsif ($server eq "prc")
		{
			system("$prc_dir/script/tm_prc_main.pl $prc_option $query_file $server");
		}

		elsif ($server eq "hmmer")
		{
			system("$hmmer_dir/script/tm_hmmer_main.pl $hmmer_option $query_file $server");
		}

		elsif ($server eq "multicom")
		{
			system("$multicom_dir/script/multicom_cm.pl $multicom_option $query_file $server");
		}

		exit; 

	}
	else
	{
		$thread_ids[$i] = $kidpid;
		print "The process id of the thread $i is $thread_ids[$i].\n";
	}
	

}
###############################################################################
use Fcntl qw (:flock);

#wait for all the child processes to be done

while (wait() != -1){ print "Wait for all base predictors to finish...\n"; sleep(60); }; 

#if ($i == @servers && $post_process == 0)
if ($i == $thread_num && $post_process == 0)
{
	print "The main process starts to wait for the base predictors to finish...\n";
	$post_process = 1;
	
	#wait for all the threads to finish
	for ($i = 0; $i < $thread_num; $i++)
	{
		if (defined $thread_ids[$i])
		{
			print "wait thread $i (pid = $thread_ids[$i]) ... ";
			waitpid($thread_ids[$i], 0);
			$thread_ids[$i] = "";
			print "done\n";
		}
	}


	#copy files into one common directory
	#@servers = ("hhsearch", "compass", "multicom", "sp2", "sp3", "rosetta", "rosetta2", "rosetta3"); 
	@servers = ("hhsearch", "compass", "multicom", "sp3", "csblast", "csiblast", "sam", "hmmer", "blast", "psiblast", "hhsearch15", "prc"); 
	for ($i = 0; $i < @servers; $i++)
	{
		$server_dir = "$output_dir/$servers[$i]";
		opendir(DIR, $server_dir) || next;
		@files = readdir DIR;	
		closedir DIR;
	
		while (@files)
		{
			$file = shift @files;

			if ($file =~ /^hh\d+\.pdb$/ || $file=~ /^hh\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^ss\d+\.pdb$/ || $file=~ /^ss\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^blast\d+\.pdb$/ || $file=~ /^blast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^psiblast\d+\.pdb$/ || $file=~ /^psiblast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^com\d+\.pdb$/ || $file=~ /^com\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^sam\d+\.pdb$/ || $file=~ /^sam\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^prc\d+\.pdb$/ || $file=~ /^prc\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hmmer\d+\.pdb$/ || $file=~ /^hmmer\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^cm\d+\.pdb$/ || $file=~ /^cm\d+\.pir$/)
			{
				if ($servers[$i] eq "csblast")
				{
					`cp $server_dir/$file $model_dir/meta_csblast_$file`;	
				}
				elsif ($servers[$i] eq "csiblast")
				{

					`cp $server_dir/$file $model_dir/meta_csiblast_$file`;	
				}
				else
				{
					`cp $server_dir/$file $model_dir/meta_$file`;	
				}
			} 

			if ($file =~ /^ab\d+\.pdb$/)
			{
				if ($servers[$i] eq "rosetta")
				{
					`cp $server_dir/$file $model_dir/meta_rose_$file`;	
				}

				if ($servers[$i] eq "rosetta2")
				{
					`cp $server_dir/$file $model_dir/meta_rose2_$file`;	
				}

				if ($servers[$i] eq "rosetta3")
				{
					`cp $server_dir/$file $model_dir/meta_rose3_$file`;	
				}
			} 

			if ($file =~ /^spem.+\.pdb$/ || $file=~ /^spem.+\.pir$/)
			{

				if ($servers[$i] eq "sp2")
				{
					`cp $server_dir/$file $model_dir/meta_sp2_$file`;	
				}

				if ($servers[$i] eq "sp3")
				{
					`cp $server_dir/$file $model_dir/meta_sp3_$file`;	
				}
	
			} 

		}
	}

	#rank models
	system("$multicom_dir/script/score_models.pl $meta_dir/script/eva_option $query_file $model_dir");
	system("$multicom_dir/script/energy_models_proc.pl $meta_dir/script/eva_option $query_file $model_dir");

	open(FASTA, $query_file) || die "can't read $query_file.\n";
	$name = <FASTA>;
	$name = substr($name, 1);
	chomp $name;
	close FASTA;
	system("$meta_dir/script/evaluate_models_meta.pl $multicom_dir $model_dir $name $query_file $model_dir/meta.eva");
}
###############################################################################
END:
