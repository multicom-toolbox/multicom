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

	if ($line =~ /^hhsearch_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_dir = $value; 
	}

	if ($line =~ /^hhsearch_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch_option = $value; 
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
-f $hhsearch_option || die "can't find $hhsearch_option.\n";
-d $compass_dir || die "can't find $compass_dir.\n";
-f $compass_option || die "can't find $compass_option.\n";
-d $multicom_dir || die "can't find $multicom_dir.\n";
-f $multicom_option || die "can't find $multicom_option.\n";
-d $rosetta_dir || die "can't find $rosetta_dir.\n";
-d $scwrl_dir || die "can't find $scwrl_dir.\n";
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

@servers = ("sp3", "sp2", "hhsearch", "compass", "multicom", "rosetta"); 

$post_process = 0; 

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
		}

		if ($server eq "sp2")
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
		}

		if ($server eq "hhsearch")
		{
			system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
		}

		if ($server eq "compass")
		{
			system("$compass_dir/script/tm_compass_main.pl $compass_option $query_file $server");
		}

		if ($server eq "multicom")
		{
			system("$multicom_dir/script/multicom_cm.pl $multicom_option $query_file $server");
		}

		if ($server eq "rosetta")
		{
			#run rosetta to generate about 500 models
			if (length($qseq) <= 150)
			{
				system("$meta_dir/script/rosetta.pl $rosetta_dir $query_file $local_model_num $server");
			}
		}
		goto END;

	}
	else
	{
		$thread_ids[$i] = $kidpid;
	}
	

}
###############################################################################
use Fcntl qw (:flock);

if ($i == @servers && $post_process == 0)
{
	$post_process = 1;
	
	for ($i = 0; $i < @thread_ids; $i++)
	{
		if (defined $thread_ids[$i])
		{
			print "wait thread $i ";
			waitpid($thread_ids[$i], 0);
			$thread_ids[$i] = "";
			print "done\n";
		}
	}

}

#call remote Rosetta server if necessary (if no compass model is generated)

#collect all models here

#rank models

###############################################################################
END:
