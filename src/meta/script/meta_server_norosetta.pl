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
@servers = ("hhsearch", "compass", "multicom", "sp3"); 

$post_process = 0; 

$model_dir = "$output_dir/meta";
`mkdir $model_dir`;


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
	
			#rank templates
			system("$meta_dir/script/rank_sp2.pl ${query_name}_spk2.out $query_name > $query_name.rank");

			#generate alignments and models
			system("$meta_dir/script/multicom_gen.pl $sparks_option $query_file $query_name.rank .");
		}

		if ($server eq "hhsearch")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server 1>out.log 2>err.log");
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

			#check if it is necessary to run rosetta
			$easy  = 0;
			$count = 0;
			while (1)
			{
				sleep(60);
				$blast_file = "$output_dir/multicom/$query_name.local";
				if ( -f $blast_file)
				{
					open(BLAST, $blast_file);
					@blast = <BLAST>;
					if (@blast > 4)
					{
						$easy = 1;
					}
					close BLAST;
					last;
				}
				$count++;
				if ($count > 30)
				{
					last;
				} 
			}
			if ($easy == 1)
			{
				print "The target is too easy to run Rosetta.\n";
				next;
			}

			#run rosetta to generate about 100 models
			if (length($qseq) <= 160)
			{
				system("$meta_dir/script/rosetta.pl $rosetta_dir $query_file $local_model_num $server");
			}
		}

		if ($server eq "rosetta2")
		{

			#check if it is necessary to run rosetta
			$easy  = 0;
			$count = 0;
			while (1)
			{
				sleep(60);
				$blast_file = "$output_dir/multicom/$query_name.local";
				if ( -f $blast_file)
				{
					open(BLAST, $blast_file);
					@blast = <BLAST>;
					if (@blast > 4)
					{
						$easy = 1;
					}
					close BLAST;
					last;
				}
				$count++;
				if ($count > 30)
				{
					last;
				} 
			}
			if ($easy == 1)
			{
				print "The target is too easy to run Rosetta.\n";
				next;
			}
			#run rosetta to generate about 500 models
			if (length($qseq) <= 160)
			{
				print "$query_name is a hard, short target. Start to run Roseta.\n";
				system("$meta_dir/script/rosetta_seed.pl $rosetta_dir $query_file $local_model_num 22222 $server");
			}
		}

		if ($server eq "rosetta3")
		{

			#check if it is necessary to run rosetta
			$easy  = 0;
			$count = 0;
			while (1)
			{
				sleep(60);
				$blast_file = "$output_dir/multicom/$query_name.local";
				if ( -f $blast_file)
				{
					open(BLAST, $blast_file);
					@blast = <BLAST>;
					if (@blast > 4)
					{
						$easy = 1;
					}
					close BLAST;
					last;
				}
				$count++;
				if ($count > 30)
				{
					last;
				} 
			}
			if ($easy == 1)
			{
				print "The target is too easy to run Rosetta.\n";
				next;
			}
			#run rosetta to generate about 500 models
			if (length($qseq) <= 160)
			{
				print "$query_name is a hard, short target. Start to run Roseta.\n";
				system("$meta_dir/script/rosetta_seed.pl $rosetta_dir $query_file $local_model_num 33333 $server");
			}
		}

		if ($server eq "rosetta4")
		{

			#check if it is necessary to run rosetta
			$easy  = 0;
			$count = 0;
			while (1)
			{
				sleep(60);
				$blast_file = "$output_dir/multicom/$query_name.local";
				if ( -f $blast_file)
				{
					open(BLAST, $blast_file);
					@blast = <BLAST>;
					if (@blast > 4)
					{
						$easy = 1;
					}
					close BLAST;
					last;
				}
				$count++;
				if ($count > 30)
				{
					last;
				} 
			}
			if ($easy == 1)
			{
				print "The target is too easy to run Rosetta.\n";
				next;
			}
			#run rosetta to generate about 500 models
			if (length($qseq) <= 160)
			{
				print "$query_name is a hard, short target. Start to run Roseta.\n";
				system("$meta_dir/script/rosetta_seed.pl $rosetta_dir $query_file $local_model_num 44444 $server");
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


#copy files into one common directory
#@servers = ("hhsearch", "compass", "multicom", "sp2", "sp3", "rosetta", "rosetta2", "rosetta3"); 
@servers = ("hhsearch", "compass", "multicom", "sp3", "rosetta", "rosetta2", "rosetta3"); 
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

		if ($file =~ /^com\d+\.pdb$/ || $file=~ /^com\d+\.pir$/)
		{
			`cp $server_dir/$file $model_dir/meta_$file`;	
		} 

		if ($file =~ /^cm\d+\.pdb$/ || $file=~ /^cm\d+\.pir$/)
		{
			`cp $server_dir/$file $model_dir/meta_$file`;	
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

###############################################################################
END:
