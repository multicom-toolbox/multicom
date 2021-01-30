#!/usr/bin/perl -w
###############################################################################
#This is the main entry script for protein structure prediction server
#Inputs: option file, query file(fasta), output dir
#New version: 2020
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
$tm_score = "/storage/htc/bdm/tianqi/MULTICOM2/tools/tm_score/TMscore_32";
$q_score = "/storage/htc/bdm/tianqi/MULTICOM2/tools/pairwiseQA/q_score";
$prediction_type = "easy";

$dfold_threshold = 700;

$tr_lower_threshold = 0.03;
$tr_upper_threshold = 0.52; 
$tr_interval_size = 0.02;
$tr_process_num = 10; 

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

	if ($line =~ /^dfold_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$dfold_threshold = $value; 
	}

	if ($line =~ /^tm_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_score = $value; 
	}

	if ($line =~ /^q_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$q_score = $value; 
	}

	if ($line =~ /^signalp/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$signalp = $value; 
	}

	if ($line =~ /^tmhmm/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tmhmm = $value; 
	}

	if ($line =~ /^prediction_type/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prediction_type = $value; 
	}

	if ($line =~ /^deepmsa_src/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deepmsa_src = $value; 
	}

	if ($line =~ /^deepdist/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deepdist = $value; 
	}

	if ($line =~ /^deephbond/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephbond = $value; 
	}

	if ($line =~ /^pspro_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pspro_dir = $value; 
	}

	if ($line =~ /^betacon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$betacon_dir = $value; 
	}

	if ($line =~ /^maxcluster_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$maxcluster_dir = $value; 
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^trrosetta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$trrosetta_dir = $value; 
	}

	if ($line =~ /^self_model/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$self_model = $value; 
	}

	if ($line =~ /^deep_rank/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deep_rank = $value; 
	}

	if ($line =~ /^tr_lower_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_lower_threshold = $value; 
	}

	if ($line =~ /^tr_upper_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_upper_threshold = $value; 
	}

	if ($line =~ /^tr_interval_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_interval_size = $value; 
	}

	if ($line =~ /^tr_process_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_process_num = $value; 
	}

	if ($line =~ /^main_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$main_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^sbrod_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sbrod_dir = $value; 
	}

	if ($line =~ /^distrank_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$distrank_dir = $value; 
	}

	if ($line =~ /^disrank_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$disrank_dir = $value; 
	}

	if ($line =~ /^psiblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psiblast_dir = $value; 
	}

	if ($line =~ /^predisorder_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$predisorder_dir = $value; 
	}

	if ($line =~ /^psiblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psiblast_option = $value; 
	}

	if ($line =~ /^hhblits3_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits3_option = $value; 
	}

	if ($line =~ /^hhblits3_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits3_dir = $value; 
	}

	if ($line =~ /^hhblits_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits_option = $value; 
	}

	if ($line =~ /^hhblits_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhblits_dir = $value; 
	}

	if ($line =~ /^hhsuite_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuite_option = $value; 
	}

	if ($line =~ /^hhsuite_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuite_dir = $value; 
	}

	if ($line =~ /^hhsu_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsu_option = $value; 
	}

	if ($line =~ /^hhsu_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsu_dir = $value; 
	}

	if ($line =~ /^hhsu_hhbl_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsu_hhbl_option = $value; 
	}

	if ($line =~ /^hhsu_hhbl_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsu_hhbl_dir = $value; 
	}

	if ($line =~ /^simple_hhsuite_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$simple_hhsuite_option = $value; 
	}

	if ($line =~ /^simple_hhsuite_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$simple_hhsuite_dir = $value; 
	}

	if ($line =~ /^sbl_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sbl_option = $value; 
	}

	if ($line =~ /^sbl_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sbl_dir = $value; 
	}

	if ($line =~ /^hmmer3_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer3_option = $value; 
	}

	if ($line =~ /^hmmer3_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer3_dir = $value; 
	}

	if ($line =~ /^deephhsuite_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephhsuite_option = $value; 
	}

	if ($line =~ /^deephhsuite_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephhsuite_dir = $value; 
	}


	if ($line =~ /^deephhblits3_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephhblits3_option = $value; 
	}

	if ($line =~ /^deephhblits3_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephhblits3_dir = $value; 
	}


	if ($line =~ /^deephybrid_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephybrid_option = $value; 
	}

	if ($line =~ /^deephybrid_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deephybrid_dir = $value; 
	}

	if ($line =~ /^dfold2_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$dfold2_dir = $value; 
	}


	if ($line =~ /^confold_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confold_dir = $value; 
	}


	if ($line =~ /^confold_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confold_option = $value; 
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
-d $main_dir || die "can't find $main_dir.\n";
-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $hhblits3_dir || die "can't find $hhblits3_dir.\n";
-f $hhblits3_option || die "can't find $hhblits3_option.\n";
#-d $hhblits_dir || die "can't find $hhblits_dir.\n";
#-f $hhblits_option || die "can't find $hhblits_option.\n";
-d $hhsuite_dir || die "can't find $hhsuite_dir.\n";
-f $hhsuite_option || die "can't find $hhsuite_option.\n";
#-d $hhsu_dir || die "can't find $hhsu_dir.\n";
#-f $hhsu_option || die "can't find $hhsu_option.\n";
-f $psiblast_option || die "can't find $psiblast_option.\n";
-d $psiblast_dir || die "can't find $psiblast_dir.\n";
-d $predisorder_dir || die "can't find $predisorder_dir.\n";
#-d $scwrl_dir || die "can't find $scwrl_dir.\n";
-d $deepmsa_src || die "can't find $deepmsa_src.\n";
-f $deepdist || die "can't find $deepdist.\n";
-f $deephbond || die "can't find $deephbond.\n";
-d $deephhsuite_dir || die "can't find $deephhsuite_dir.\n";
-f $deephhsuite_option || die "can't find $deephhsuite_option.\n";
-d $deephhblits3_dir || die "can't find $deephhblits3_dir.\n";
-f $deephhblits3_option || die "can't find $deephhblits3_option.\n";
-d $dfold2_dir || die "can't find $dfold2_dir.\n";
-d $deephybrid_dir || die "can't find $deephybrid_dir.\n";
-d $pspro_dir || die "can't find $pspro_dir.\n";
-d $trrosetta_dir || die "can't find $trrosetta_dir.\n";
-f $self_model || die "can't find $self_model.\n";
#-d $betacon_dir || die "can't find $betacon_dir.\n";
-d $maxcluster_dir || die "can't find $maxcluster_dir.\n";
-f $deephybrid_option || die "can't find $deephybrid_option.\n";
-d $distrank_dir || die "can't find $distrank_dir.\n";
-d $disrank_dir || die "can't find $disrank_dir.\n";
-d $sbrod_dir || die "can't find $sbrod_dir.\n";
#-d $hhsu_hhbl_dir || die "can't find $hhsu_hhbl_dir.\n";
#-f $hhsu_hhbl_option || die "can't find $hhsu_hhbl_option.\n";
-d $simple_hhsuite_dir || die "can't find $simple_hhsuite_dir.\n";
-f $simple_hhsuite_option || die "can't find $simple_hhsuite_option.\n";
#-d $confold_dir || die "can't find $confold_dir.\n";
#-f $confold_option || die "can't find $confold_option.\n";
#-d $sbl_dir || die "can't find $sbl_dir.\n";
#-f $sbl_option || die "can't find $sbl_option.\n";
-d $hmmer3_dir || die "can't find $hmmer3_dir.\n";
-f $hmmer3_option || die "can't find $hmmer3_option.\n";

$tr_lower_threshold >= 0 && $tr_lower_threshold <= 1 || die "The lower threshold of trRosetta is out of range.\n";
$tr_upper_threshold >= 0 && $tr_upper_threshold <= 1 || die "The upper threshold of trRosetta is out of range.\n";
$tr_lower_threshold <= $tr_upper_threshold || die "The lower threshold is greater than the upper threshold.\n";
$tr_interval_size >= 0 && $tr_interval_size <= 1 || die "The threshold interval size of trRosetta is out of range.\n";
$tr_process_num >= 1 && $tr_process_num <= 50 || die "The number of processes is out of range.\n";


$max_wait_time > 10 && $max_wait_time < 600 || die "waiting time is out of range.\n";

#get query name and sequence 
open(FASTA, $query_file) || die "can't read fasta file.\n";
$query_name = <FASTA>;
chomp $query_name; 
$qseq = <FASTA>;
chomp $qseq;
close FASTA;
$query_length = length($qseq);

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

#if ($prediction_type eq "easy")
#{
#	@servers = ("psiblast", "hhblits3", "hhsuite", "pspro"); 
#}
#else
#{
	#@servers = ("psiblast", "hhblits3", "hhsuite", "pspro", "disthbond", "shh", "betacon"); 
	#@servers = ("psiblast", "hhblits3", "hhblits", "hhsuite", "hhsu", "disthbond", "shh", "betacon", "sbl", "hmmer3");
    @servers = ("psiblast", "hhblits3", "hhsuite", "disthbond", "hmmer3");   #####Tianqi modification for simplicity
#}

$post_process = 0; 

$model_dir = "$output_dir/meta";

$model_generation = 1; 
if (! -d $model_dir)
{
	`mkdir $model_dir`;

	-d $model_dir || die "can't create $model_dir.\n";
}
else
{
	print "Output model directory: $model_dir exists. Check if pdb models have been generated.\n";
	opendir(MODELS, $model_dir) || die "can't open directory: $model_dir.\n";
	@m_files = readdir(MODELS);
	closedir MODELS;
	foreach $m_file (@m_files)
	{
		if ($m_file =~ /\.pdb$/)
		{
			print "Structural models have been generated. No Model Generation, only model ranking. \n";
			$model_generation = 0;
			last;
		}
	}
}


$thread_num = @servers;

$start_time = `date`; 
if ($model_generation == 1)
{
	print "MULTICOM predictoin start time: $start_time\n";
}

for ($i = 0; $i < @servers; $i++)
{
	if ($model_generation == 0)
	{
		next; 
	}
	$server = $servers[$i];

        if ( !defined( $kidpid = fork() ) )
        {
                die "can't create process $i\n";
        }
        elsif ($kidpid == 0)
        {
                print "start thread $i: $server predictor\n";
                `mkdir $server`;


		if ($server eq "psiblast")
		{
			print("$i. $psiblast_dir/script/tm_psiblast_main.pl $psiblast_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$psiblast_dir/script/tm_psiblast_main.pl $psiblast_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
		}

		elsif ($server eq "hhblits3")
		{
			print("$i. $hhblits3_dir/script/tm_hhblits3_main.pl $hhblits3_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$hhblits3_dir/script/tm_hhblits3_main.pl $hhblits3_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $hhblits3_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
		}

		elsif ($server eq "hhblits")
		{
			print("$i. $hhblits_dir/script/tm_hhblits_main.pl $hhblits_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$hhblits_dir/script/tm_hhblits_main.pl $hhblits_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $hhblits_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
		}

		elsif ($server eq "hhsu")
		{
			print("$i. $hhsu_dir/script/tm_hhsuite_main.pl $hhsu_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$hhsu_dir/script/tm_hhsuite_main.pl $hhsu_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $hhsu_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
		}

		elsif ($server eq "shh")
		{
			print("$i. $simple_hhsuite_dir/script/tm_simple_hhsuite_main.pl $simple_hhsuite_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$simple_hhsuite_dir/script/tm_simple_hhsuite_main.pl $simple_hhsuite_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $simple_hhsuite_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
		}

		elsif ($server eq "sbl")
		{
			print("$i. $sbl_dir/script/tm_sbl_main.pl $sbl_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$sbl_dir/script/tm_sbl_main.pl $sbl_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $sbl_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
		}

		elsif ($server eq "hmmer3")
		{
			print("$i. $hmmer3_dir/script/tm_hmmer3_main.pl $hmmer3_option $query_file $server...... (see $server/log.txt for details)\n");
			system("$hmmer3_dir/script/tm_hmmer3_main.pl $hmmer3_option $query_file $server >$server/log.txt 2>&1");
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
		}

		elsif ($server eq "hhsuite")
		{
			print("$i. $hhsuite_dir/script/tm_hhsuite_main_v2.pl $hhsuite_option $query_file $server...... (see $server/log.txt for details)\n"); 
			system("$hhsuite_dir/script/tm_hhsuite_main_v2.pl $hhsuite_option $query_file $server >$server/log.txt 2>&1"); 
			$current_time = `date`; 
			print "$server prediction ends at $current_time.\n";
			system("perl $hhsuite_dir/script/domain_identification_from_hhsearch15.pl $query_file $server >$server/domain_log.txt 2>&1");
			print "In $server, make disorder prediction.\n";
			system("$predisorder_dir/bin/predict_diso.sh $query_file $output_dir/$server/$query_name.fasta.disorder >$server/disorder_log.txt 2>&1");

			#run the hhblits version of hhsuite
			# `mkdir hhh`; 
			# `cp $server/$query_name.hmm hhh`; 
			# print("$hhsu_hhbl_dir/script/tm_hhsu_hhbl_main.pl $hhsu_hhbl_option $query_file hhh >hhh/log.txt 2>&1\n"); 
			# system("$hhsu_hhbl_dir/script/tm_hhsu_hhbl_main.pl $hhsu_hhbl_option $query_file hhh >hhh/log.txt 2>&1"); 
			# system("perl $hhsu_hhbl_dir/script/domain_identification_from_hhsearch15.pl $query_file hhh >hhh/domain_log.txt 2>&1");
			# print("hhh prediction ends.\n"); 
		}
		elsif ($server eq "disthbond")
		{
			print("$i. $deephbond -f $query_file -o $output_dir/$server >$server/${server}_log.txt 2>&1\n"); 
			system("python $deephbond -f $query_file -o $output_dir/$server >$server/${server}_log.txt 2>&1");
			print("$i. $deepdist -f $query_file -o $output_dir/$server >$server/${server}_log.txt 2>&1\n");  
			system("python $deepdist -f $query_file -o $output_dir/$server >$server/${server}_log.txt 2>&1"); 
			$current_time = `date`; 
			print "$server deepdist and deephbond end at $current_time.\n";
		}
		elsif ($server eq "pspro")
		{
			chdir $server;
			print("$i. $pspro_dir/bin/predict_ssa.sh $query_file $query_name.ssa >log.txt 2>&1\n");
			system("$pspro_dir/bin/predict_ssa.sh $query_file $query_name.ssa >log.txt 2>&1");
			print "Secondary structure prediction by pspro is done.\n";
			
		}
		elsif ($server eq "betacon")
		{
			chdir $server;
			print("$i. $betacon_dir/bin/beta_contact_map.sh $query_file . >log.txt 2>&1\n");
			system("$betacon_dir/bin/beta_contact_map.sh $query_file . >log.txt 2>&1");
			print "Contact prediction by betacon is done.\n";

			#predict signal peptides and transmembrane helices
			system("$signalp -f short $query_file > $query_name.signal"); 
			system("$tmhmm $query_file > $query_name.tmhelix"); 
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
#

#if ($i == @servers && $post_process == 0)
if ($i == $thread_num && $post_process == 0)
{
	if ($model_generation == 1)
	{
		print "The main process starts to wait for the base predictors to finish...\n";
	}
	$post_process = 1;
	
	#wait for all the threads to finish
	for ($i = 0; $i < $thread_num; $i++)
	{
		if ($model_generation == 0)
		{
			next; 
		}
		if (defined $thread_ids[$i])
		{
			print "wait thread $i (pid = $thread_ids[$i]) ... ";
			waitpid($thread_ids[$i], 0);
			$thread_ids[$i] = "";
			print "done\n";
		}
	}

	$deepmsa_dir = "$output_dir/disthbond/full_length/msa/alignment/";
	#$deepmsa_src = "/exports/store2/casp14/tools/deepmsa";
	#Extract deepmsa a3m file
    if ($prediction_type eq "hard"){
            if (-f "$deepmsa_dir/$query_name.aln") {
                system("python $deepmsa_src/aln2a3m_v2.py -d $deepmsa_dir");
            } else {
                print("DeepMSA failed to generate MSA, pls check $deepmsa_dir/$query_name.aln....\n");
            }
            $deepmsa_file = "$deepmsa_dir/$query_name.a3m";
    }


	############################The second round of modelling for hard targets#################################
	if ($prediction_type eq "hard" && -f $deepmsa_file)
	{
		if ($model_generation == 1)
		{
			print "Run hard template-based and ab initio preditio for $query_name\n";
		}
		@servers = ("deephhblits3", "deephhsuite", "deephybrid","dfold2_r","dfold2_m", "disrank", "trrosetta"); 

		$thread_num = @servers;
		$hard_post_process = 0; 

		$start_time = `date`; 
		if ($model_generation == 1)
		{
			print "MULTICOM hard predictoin start time: $start_time\n";
		}

		for ($j = 0; $j < @servers; $j++)
		{
			if ($model_generation == 0)
			{
				next; 
			}
			$server = $servers[$j];

		        if ( !defined( $kidpid = fork() ) )
		        {
               			 die "can't create process $j\n";
      			}
     			elsif ($kidpid == 0)
    			{
		                print "start hard thread $j: $server predictor\n";
               			 `mkdir $server`;


				if ($server eq "deephhsuite")
				{
					print("$j. $deephhsuite_dir/script/tm_deephhsuite_main_v2.pl $deephhsuite_option $query_file $deepmsa_file $server...... (see $server/log.txt for details)\n");
					system("$deephhsuite_dir/script/tm_deephhsuite_main_v2.pl $deephhsuite_option $query_file $deepmsa_file $server >$server/log.txt 2>&1");
					$current_time = `date`; 
					print "$server prediction ends at $current_time.\n";
				}



				if ($server eq "deephhblits3")
				{
					print("$j. $deephhblits3_dir/script/tm_deephhblits3_main.pl $deephhblits3_option $query_file $deepmsa_file $server...... (see $server/log.txt for details)\n");
					system("$deephhblits3_dir/script/tm_deephhblits3_main.pl $deephhblits3_option $query_file $deepmsa_file $server >$server/log.txt 2>&1");
					$current_time = `date`; 
					print "$server prediction ends at $current_time.\n";
				}


				if ($server eq "deephybrid")
				{
					print("$j. $deephybrid_dir/script/tm_deephybrid_main_v2.pl $deephybrid_option $query_file $deepmsa_file $server...... (see $server/log.txt for details)\n");
					system("$deephybrid_dir/script/tm_deephybrid_main_v2.pl $deephybrid_option $query_file $deepmsa_file $server >$server/log.txt 2>&1");
					$current_time = `date`; 
					print "$server prediction ends at $current_time.\n";
				}

				if ($server eq "disrank")
				{
					if (-d "$output_dir/hhsuite")
					{
						print("$disrank_dir/run_disrank.sh $query_name $query_file $output_dir/hhsuite/ $output_dir/disthbond/full_length/ensemble/pred_map_ensem/real_dist/$query_name.txt $output_dir/$server >$server/log.txt 2>&1\n");
						system("$disrank_dir/run_disrank.sh $query_name $query_file $output_dir/hhsuite/ $output_dir/disthbond/full_length/ensemble/pred_map_ensem/real_dist/$query_name.txt $output_dir/$server >$server/log.txt 2>&1");
						$current_time = `date`; 
						print "$server prediction ends at $current_time.\n";
					}
					else
					{
						print "$output_dir/hhsuite does not exist. disrank prediction is skipped.\n";
					}
			
				}

				if ($server eq "dfold2_r")
				{
					if ($query_length < $dfold_threshold)
					{
						print("$j. python $dfold2_dir/src/DFOLD_v3.py -f $query_file -d $output_dir/disthbond/real_dist/$query_name.dist.rr -b $output_dir/disthbond/$query_name.hbond.tbl -n $output_dir/disthbond/$query_name.ssnoe.tbl -p $output_dir/disthbond/full_length/msa/psipred/$query_name.ss2 -mout 10 -out $server...... (see $server/log.txt for details)\n");
						system("python $dfold2_dir/src/DFOLD_v3.py -f $query_file -d $output_dir/disthbond/real_dist/$query_name.dist.rr -b $output_dir/disthbond/$query_name.hbond.tbl -n $output_dir/disthbond/$query_name.ssnoe.tbl -p $output_dir/disthbond/full_length/msa/psipred/$query_name.ss2 -mout 10 -out $server >$server/log.txt 2>&1");
                 				   system("rename \"$query_name\" \"$server\" $server/*.pdb");
                  				  system("rename \"_model\" \"\" $server/*.pdb");
						$current_time = `date`; 
						print "$server prediction ends at $current_time.\n";
					}
					else
					{
						print "The target is too long. DFold moldeing is skipped.\n";
					}
				}

				if ($server eq "dfold2_m")
				{
					if ($query_length < $dfold_threshold)
					{
						print("$j. python $dfold2_dir/src/DFOLD_v3.py -f $query_file -d $output_dir/disthbond/mul_class/$query_name.dist.rr -b $output_dir/disthbond/$query_name.hbond.tbl -n $output_dir/disthbond/$query_name.ssnoe.tbl -p $output_dir/disthbond/full_length/msa/psipred/$query_name.ss2 -mout 10 -out $server...... (see $server/log.txt for details)\n");
						system("python $dfold2_dir/src/DFOLD_v3.py -f $query_file -d $output_dir/disthbond/mul_class/$query_name.dist.rr -b $output_dir/disthbond/$query_name.hbond.tbl -n $output_dir/disthbond/$query_name.ssnoe.tbl -p $output_dir/disthbond/full_length/msa/psipred/$query_name.ss2 -mout 10 -out $server >$server/log.txt 2>&1");
                   				 system("rename \"$query_name\" \"$server\" $server/*.pdb");
                   				 system("rename \"_model\" \"\" $server/*.pdb");
							$current_time = `date`; 
							print "$server prediction ends at $current_time.\n";
					}
					else
					{
						print "The target is too long. DFold moldeing is skipped.\n";
					}
				}

				if ($server eq "trrosetta")
				{
					
					#print("$trrosetta_dir/run_trRosetta_v2.sh $query_name $query_file $output_dir/disthbond/ $server >$server/log.txt\n");   	
					#system("$trrosetta_dir/run_trRosetta_v2.sh $query_name $query_file $output_dir/disthbond/ $server >$server/log.txt 2>&1");   	
					print("$trrosetta_dir/run_trRosetta_v3.sh $query_name $query_file $tr_lower_threshold $tr_upper_threshold $tr_interval_size $tr_process_num $output_dir/disthbond/ $server >$server/log.txt 2>&1\n");   	
					system("$trrosetta_dir/run_trRosetta_v3.sh $query_name $query_file $tr_lower_threshold $tr_upper_threshold $tr_interval_size $tr_process_num $output_dir/disthbond/ $server >$server/log.txt 2>&1");   	
					$current_time = `date`; 
					print "$server prediction ends at $current_time.\n";
				}


				if ($server eq "confold")
				{

					#check if need to run confold on contacts predicted from non-covolution features
					$align_stat = "$output_dir/disthbond/full_length/aln/alnstat/$query_name.colstats";
					$effective_num = 10000; 
					if (-f $align_stat)
					{
						open(STAT, $align_stat);
						<STAT>;
						<STAT>;
						$effective_num = <STAT>;	
						chomp $effective_num; 
						close STAT;
					}	
					
					if ($effective_num <= 5 && $query_length <= 120)
					{
						print("$j. sh $confold_dir/run_confold2.sh $query_file $output_dir/disthbond/$query_name.rr $output_dir/disthbond/$query_name.ss2 $server >$server/log.txt 2>&1\n");
						system("sh $confold_dir/run_confold2.sh $query_file $output_dir/disthbond/$query_name.rr $output_dir/disthbond/$query_name.ss2 $server >$server/log.txt 2>&1");
						$current_time = `date`; 
						print "$server prediction ends at $current_time.\n";
					}
					else
					{
						print "The number of effective sequences ($effective_num) is high. Skip confold modeling.\n";
					}


					if ($effective_num <= 5 && $query_length <= 120)
					{
						
						print "Run confold on contact predictions based on non-coevolution features.\n";	
						$betacon_output = "$output_dir/betacon";	
						$contact_file = "$betacon_output/$query_name.rr";
						$ss_file = "$betacon_output/$query_name.ss";
						opendir(BETA, $betacon_output);
						@cfiles = readdir(BETA);
						closedir BETA;	

						while (@cfiles)
						{       
						        $file = shift @cfiles;
						        if ($file =~ /\.rr1$/)
						        {       
						                `cp $betacon_output/$file $contact_file`;
						        }
						        if ($file =~ /\.cm8a$/)
						        {       
						                open(CFILE, "$betacon_output/$file");
						                <CFILE>;
						                <CFILE>;
						                $ss = <CFILE>;
						                close CFILE;             
						                open(SS, ">$ss_file") || die "can't read $ss_file\n";
						                print SS ">$query_name\n$ss";
						                close SS;
						        }
						}

						if (-f $contact_file && -f $ss_file)
						{
							print("$confold_dir/run_confold2_single.pl $confold_option $query_file $contact_file $ss_file $betacon_output\n");
							system("$confold_dir/run_confold2_single.pl $confold_option $query_file $contact_file $ss_file $betacon_output >$betacon_output/log.txt 2>&1");

						}
						else
						{
							print "Contact file ($contact_file) or secondary structure file ($ss_file) is not found. No confold2 modeling for betacon.\n";
						}



					}
				}


				exit;
			}
			else
			{
				$hard_thread_ids[$j] = $kidpid;
				print "The process id of the hard thread $j is $hard_thread_ids[$j].\n";
			}


		}


		#wait for the hard prediction processes to finish
		if ($j == $thread_num && $hard_post_process == 0 && $model_generation == 1)
		{
			print "The main process starts to wait for the hard base predictors to finish...\n";
			$hard_post_process = 1;
	
			#wait for all the threads to finish
			for ($j = 0; $j < $thread_num; $j++)
			{
				if (defined $hard_thread_ids[$j])
				{
					print "wait hard thread $j (pid = $hard_thread_ids[$j]) ... ";
					waitpid($hard_thread_ids[$j], 0);
					$hard_thread_ids[$j] = "";
					print "done\n";
				}
			}
		}


	}
	##########################The end of the second round modeling for hard targets###########################


	#copy files into one common directory
	#@servers = ("psiblast", "hhblits3", "hhsuite", "deephhsuite", "deephybrid", "deephhblits3","dfold2_r","dfold2_m", "hhh", "shh", "sbl", "disrank", "confold", "betacon", "trrosetta", "hhblits", "hhsu", "hmmer3"); 
    @servers = ("psiblast", "hhblits3", "hhsuite", "deephhsuite", "deephybrid", "deephhblits3","dfold2_r","dfold2_m", "disrank", "trrosetta", "hhblits", "hmmer3"); 
	for ($i = 0; $i < @servers; $i++)
	{
		if ($model_generation == 0)
		{
			next; 
		}
		$server_dir = "$output_dir/$servers[$i]";
		opendir(DIR, $server_dir) || next;
		@files = readdir DIR;	
		closedir DIR;
	
		while (@files)
		{
			$file = shift @files;

			if ($file =~ /^psiblast\d+\.pdb$/ || $file=~ /^psiblast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hhbl\d+\.pdb$/ || $file=~ /^hhbl\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^blits\d+\.pdb$/ || $file=~ /^blits\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hhsuite\d+\.pdb$/ || $file=~ /^hhsuite\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^hhsu\d+\.pdb$/ || $file=~ /^hhsu\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^dhhbl\d+\.pdb$/ || $file=~ /^dhhbl\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^hhh\d+\.pdb$/ || $file=~ /^hhh\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^shh\d+\.pdb$/ || $file=~ /^shh\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^sbl\d+\.pdb$/ || $file=~ /^sbl\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^jhmmer\d+\.pdb$/ || $file=~ /^jhmmer\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^disrank\d+\.pdb$/ || $file=~ /^disrank\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^dhhsu\d+\.pdb$/ || $file=~ /^dhhsu\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^dhybrid\d+\.pdb$/ || $file=~ /^dhybrid\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
      		        if ($file =~ /^dhybrid\d+\.pdb$/ || $file=~ /^dhybrid\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
                        if ($file =~ /^dfold2_r\d+\.pdb$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
                        if ($file =~ /^dfold2_m\d+\.pdb$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
                        if ($file =~ /^confold\d+\.pdb$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
                        if ($file =~ /^betacon\d+\.pdb$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
                        if ($file =~ /^trRosetta(\d+)\.pdb$/)
			{
				#replace chain id "A" with a space character
				system("$meta_dir/script/process_trrosetta_chain_id.pl $server_dir/$file"); 

				#do self modeling
				use Cwd; 
				$cwd = getcwd;
				chdir $server_dir;
				system("$self_model $file self$1");
				if (-f "self$1.pdb")
				{
					`mv $file $file.org`; 
					`mv self$1.pdb $file`; 
				}
				else
				{
					print "failed to remodel $file\n";
				}
				chdir $cwd; 
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
		}
	}

        open(FASTA, $query_file) || die "can't read $query_file.\n";
        $name = <FASTA>;
        $name = substr($name, 1);
        chomp $name;
        close FASTA;

	#do pairwise QA evaluation

	print("Using pairwise comparison to rank models: $meta_dir/script/pairwise_model_eva.pl $model_dir $query_file $q_score $tm_score $name $model_dir\n"); 
	system("$meta_dir/script/pairwise_model_eva.pl $model_dir $query_file $q_score $tm_score $name $model_dir"); 

	#generate clash information of the models
   	system("$meta_dir/script/evaluate_models_meta_v3.pl $prosys_dir $model_dir $name $query_file $model_dir/$name.eva >/dev/null 2>&1");

	#rank the models using sbrod
	print("Using SBROD to rank models...\n");
	system("python $sbrod_dir/run_sbrod.py -s $sbrod_dir -in $model_dir -out $model_dir/$query_name.sbrod");		
	#rank the models using distance map
	$model_list_file = "$output_dir/$query_name.list";
	$dist_dir = "$model_dir/dist_rank";
	if (-f $model_list_file)
	{
		`mkdir $dist_dir`; 
		print("Rank models using distance maps...\n");

		$distance_map_file = "$output_dir/disthbond/full_length/ensemble/pred_map_ensem/real_dist/$query_name.txt";
		system("$meta_dir/script/rank_models_by_distance.sh $distrank_dir $model_list_file $distance_map_file $query_file $dist_dir >$model_dir/$query_name.drank.log 2>&1");
		$rank_file = "$dist_dir/rank.txt";
		if (-f $rank_file)
		{
			$final_rank_file = "$model_dir/$query_name.drank";  	
			open(DRANK, $rank_file) || die "can't read $rank_file.\n";
			@drank = <DRANK>;
			close DRANK; 
			open(FINAL, ">$final_rank_file") || die "can't create $final_rank_file.\n";
			foreach $model_score (@drank)
			{
				chomp $model_score; 
				@fields = split(/\s+/, $model_score);
				print FINAL "$fields[0].pdb";
				if (@fields > 2)
				{
					print FINAL "\t$fields[1]\t$fields[2]\t$fields[3]\t$fields[4]\t$fields[5]\n";
				}
				else
				{
					print FINAL "\t$fields[1]\n";
				}
			}
			close FINAL; 
		}
		else
		{
			warn "The ranking of models by distance: $rank_file does not exist.\n";
		}
		`rm -rf $dist_dir`; 
	}
	else
	{
		print "Warning: can't find $model_list_file for ranking models by distrank.\n";
	}

	#call deep learning ranking if it is specificed
	if (-f $deep_rank)
	{
		print "Generate deep learning ranking of the models...\n";	
		system("$prosys_dir/script/deep_rank.pl $deep_rank $query_name $query_file $model_dir $output_dir/disthbond/ $model_dir");  
	}
	
	#generate average rankings
	print "Generate the average ranking of clustering ranking, SBROD ranking, and distance-based ranking.\n";
	system("$prosys_dir/script/gen_average_rank_v2.pl $model_dir $query_name >$model_dir/$query_name.ave.log 2>&1");

	#cluster models
	system("$maxcluster_dir/maxcluster64bit -l $model_list_file -is 20 >$model_dir/$query_name.cluster.tmp");
	$centroid_file = "$model_dir/$query_name.centroids";
	$cluster_file = "$model_dir/$query_name.cluster";
	open(CTMP, "$model_dir/$query_name.cluster.tmp") || die "can't read model clustering results.\n";	
	@ctmp = <CTMP>;
	close CTMP;	
	
	while (@ctmp)
	{
		$entry = shift @ctmp;
		chomp $entry;
		if ($entry =~ /Cluster\s+Centroid\s+Size/)
		{
			open(CENT, ">$centroid_file") || die "can't create $centroid_file\n";
			print CENT "Cluster\tSize\tCentroid\n";
			while (@ctmp)
			{
				$entry = shift @ctmp;
				chomp $entry;
				if ($entry =~ /===/)
				{
					last;
				}
				@fields = split(/\s+/, $entry);	
				$model_name = $fields[7];
				$model_name = substr($model_name, rindex($model_name, "/") + 1); 
				print CENT "$fields[2]\t$fields[5]\t$model_name\n";
			}
			close CENT; 
		}
		if ($entry =~ /Item\s+Cluster/)
		{
			open(CLUS, ">$cluster_file") || die "can't create $cluster_file\n";
			print CLUS "Model\tCluster\n";
			while (@ctmp)
			{
				$entry = shift @ctmp;
				chomp $entry;
				if ($entry =~ /===/)
				{
					last;
				}
				@fields = split(/\s+/, $entry);	

				$cluster_num = $fields[4];
				$model_name = $fields[5];
				$model_name = substr($model_name, rindex($model_name, "/") + 1); 

				print CLUS "$model_name\t$cluster_num\n";
				
			}	
			close CLUS; 
		}
		
	}

}
###############################################################################
END:
