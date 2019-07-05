#!/usr/bin/perl -w
###############################################################################
#This is the main entry script for protein structure prediction server
#Inputs: option file, query file(fasta), output dir
#New version: starte date: 1/10/2009
#########################################################################
$GLOBAL_PATH="/home/jh7x3/multicom_beta1.0/";

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


open(FASTA, $query_file);
$query_name = <FASTA>;
chomp $query_name;
$query_name = substr($query_name, 1); 
close FASTA;

#take only filename from fasta file
$pos = rindex($query_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($query_file, $pos + 1); 
}

############################################################################

###################Preprocessing of Inputs###################################
#read option file
open(OPTION, $meta_option) || die "can't read option file.\n";

$local_model_num = 50;

#$tm_score = "/home/casp13/MULTICOM_package//software/tm_score/TMscore_32";
$tm_score = "$GLOBAL_PATH/tools/tm_score/TMscore_32";

#$q_score = "/home/casp13/MULTICOM_package//software/pairwiseQA/q_score";
$q_score = "$GLOBAL_PATH/tools/pairwiseQA/q_score";
#$hhsearch_option_casp8 = "/home/casp13/MULTICOM_package//casp8/hhsearch/hhsearch_option_cluster_used_in_casp8";
$hhsearch_option_casp8 = "$GLOBAL_PATH/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8";

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

	if ($line =~ /^csblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$csblast_option = $value; 
	}

	if ($line =~ /^csiblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$csiblast_option = $value; 
	}

	if ($line =~ /^construct_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$construct_dir = $value; 
	}

	if ($line =~ /^construct_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$construct_option = $value; 
	}

	if ($line =~ /^confoldtemp_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confoldtemp_dir = $value; 
	}

	if ($line =~ /^confoldtemp_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confoldtemp_option = $value; 
	}

	if ($line =~ /^msa_dir/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $msa_dir = $value;
        }

        if ($line =~ /^msa_option/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $msa_option = $value;
        }


	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}

	if ($line =~ /^blast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_option = $value; 
	}

	if ($line =~ /^psiblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psiblast_dir = $value; 
	}

	if ($line =~ /^psiblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$psiblast_option = $value; 
	}

	if ($line =~ /^newblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$newblast_dir = $value; 
	}

	if ($line =~ /^newblast_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$newblast_option = $value; 
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

	if ($line =~ /^hhsearch151_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch151_dir = $value; 
	}

	if ($line =~ /^hhsearch151_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsearch151_option = $value; 
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

	if ($line =~ /^hhpred_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhpred_option = $value; 
	}

	if ($line =~ /^hhpred_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhpred_dir = $value; 
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

	if ($line =~ /^hhsuite3_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuite3_option = $value; 
	}

	if ($line =~ /^hhsuite3_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hhsuite3_dir = $value; 
	}

	if ($line =~ /^confold_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confold_option = $value; 
	}

	if ($line =~ /^confold_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confold_dir = $value; 
	}

	if ($line =~ /^rosettacon_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosettacon_option = $value; 
	}

	if ($line =~ /^rosettacon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosettacon_dir = $value; 
	}

	if ($line =~ /^fusioncon_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fusioncon_option = $value; 
	}

	if ($line =~ /^fusioncon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fusioncon_dir = $value; 
	}

	if ($line =~ /^unicon3d_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$unicon3d_option = $value; 
	}

	if ($line =~ /^unicon3d_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$unicon3d_dir = $value; 
	}

	if ($line =~ /^fugue_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fugue_option = $value; 
	}

	if ($line =~ /^fugue_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fugue_dir = $value; 
	}

	if ($line =~ /^raptorx_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$raptorx_option = $value; 
	}

	if ($line =~ /^raptorx_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$raptorx_dir = $value; 
	}

	if ($line =~ /^ffas_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$ffas_option = $value; 
	}

	if ($line =~ /^ffas_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$ffas_dir = $value; 
	}

	if ($line =~ /^muster_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$muster_option = $value; 
	}

	if ($line =~ /^muster_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$muster_dir = $value; 
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

	if ($line =~ /^hmmer3_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer3_dir = $value; 
	}

	if ($line =~ /^hmmer3_option/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer3_option = $value; 
	}

	if ($line =~ /^compass_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$compass_dir = $value; 
	}

        if ($line =~ /^novel_dir/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $novel_dir = $value;
        }

        if ($line =~ /^novel_option/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $novel_option = $value;
        }

        if ($line =~ /^deepsf_dir/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $deepsf_dir = $value;
        }

        if ($line =~ /^deepsf_option/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $deepsf_option = $value;
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
-d $prosys_dir || die "can't find $prosys_dir.\n";
#-d $sparks_dir || die "can't find $sparks_dir.\n";
#-f $sparks_option || die "can't find $sparks_option.\n";
-d $hhsearch_dir || die "can't find $hhsearch_dir.\n";
-f $hhsearch_option || die "can't find $hhsearch_option.\n";
-d $hhsearch15_dir || die "can't find $hhsearch15_dir.\n";
-f $hhsearch15_option || die "can't find $hhsearch15_option.\n";
-d $hhsearch151_dir || die "can't find $hhsearch151_dir.\n";
-f $hhsearch151_option || die "can't find $hhsearch151_option.\n";
-d $sam_dir || die "can't find $sam_dir.\n";
-f $sam_option || die "can't find $sam_option.\n";
-d $prc_dir || die "can't find $prc_dir.\n";
-f $prc_option || die "can't find $prc_option.\n";
-d $hhpred_dir || die "can't find $hhpred_dir.\n";
-f $hhpred_option || die "can't find $hhpred_option.\n";
-d $hhblits_dir || die "can't find $hhblits_dir.\n";
-f $hhblits_option || die "can't find $hhblits_option.\n";
-d $hhblits3_dir || die "can't find $hhblits3_dir.\n";
-f $hhblits3_option || die "can't find $hhblits3_option.\n";
-d $hhsuite_dir || die "can't find $hhsuite_dir.\n";
-f $hhsuite_option || die "can't find $hhsuite_option.\n";
-d $hhsuite3_dir || die "can't find $hhsuite3_dir.\n";
-f $hhsuite3_option || die "can't find $hhsuite3_option.\n";
-d $confold_dir || die "can't find $confold_dir.\n";
-f $confold_option || die "can't find $confold_option.\n";
-d $rosettacon_dir || die "can't find $rosettacon_dir.\n";
-f $rosettacon_option || die "can't find $rosettacon_option.\n";
-d $unicon3d_dir || die "can't find $unicon3d_dir.\n";
-f $unicon3d_option || die "can't find $unicon3d_option.\n";
-d $fugue_dir || die "can't find $fugue_dir.\n";
-f $fugue_option || die "can't find $fugue_option.\n";
-d $raptorx_dir || die "can't find $raptorx_dir.\n";
-f $raptorx_option || die "can't find $raptorx_option.\n";
-d $ffas_dir || die "can't find $ffas_dir.\n";
-f $ffas_option || die "can't find $ffas_option.\n";
-d $muster_dir || die "can't find $muster_dir.\n";
-f $muster_option || die "can't find $muster_option.\n";
-d $hmmer_dir || die "can't find $hmmer_dir.\n";
-f $hmmer_option || die "can't find $hmmer_option.\n";
-d $hmmer3_dir || die "can't find $hmmer3_dir.\n";
-f $hmmer3_option || die "can't find $hmmer3_option.\n";

-d $deepsf_dir || die "can't find $deepsf_dir.\n";
-f $deepsf_option || die "can't find $deepsf_option.\n";
-d $novel_dir || die "can't find $novel_dir.\n";
-f $novel_option || die "can't find $novel_option.\n";

-d $csblast_dir || die "can't find $csblast_dir.\n";
-f $csblast_option || die "can't find $csblast_option.\n";
-f $csiblast_option || die "can't find $csiblast_option.\n";
-f $blast_option || die "can't find $blast_option.\n";
-d $blast_dir || die "can't find $blast_dir.\n";
-f $psiblast_option || die "can't find $psiblast_option.\n";
-d $psiblast_dir || die "can't find $psiblast_dir.\n";
-f $newblast_option || die "can't find $newblast_option.\n";
-d $newblast_dir || die "can't find $newblast_dir.\n";
-d $compass_dir || die "can't find $compass_dir.\n";
-f $compass_option || die "can't find $compass_option.\n";
-d $multicom_dir || die "can't find $multicom_dir.\n";
-f $multicom_option || die "can't find $multicom_option.\n";
-d $construct_dir || die "can't find $construct_dir.\n";
-f $construct_option || die "can't find $construct_option.\n";
-d $confoldtemp_dir || die "can't find $confoldtemp_dir.\n";
-f $confoldtemp_option || die "can't find $confoldtemp_option.\n";
-d $msa_dir || die "can't find $msa_dir.\n";
-f $msa_option || die "can't find $msa_option.\n";
-d $rosetta_dir || die "can't find $rosetta_dir.\n";
-d $scwrl_dir || die "can't find $scwrl_dir.\n";
$max_wait_time > 10 && $max_wait_time < 600 || die "waiting time is out of range.\n";

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

@servers = ("hhsearch", "compass", "raptorx", "csiblast", "sam", "hmmer", "hmmer3", "psiblast", "newblast", "blast", "hhsearch15", "prc", "construct", "hhpred", "hhblits", "hhblits3", "ffas", "muster", "hhsearch151", "hhsuite3", "msa", "confold", "rosettacon", "fusioncon", "unicon3d", "novel", "deepsf", "confoldtemp", "rosetta2", "rosetta3", "rosetta4", "rosetta5", "rosetta6", "rosetta7");


$post_process = 0; 

$model_dir = "$output_dir/meta";
`mkdir $model_dir`;

-d $model_dir || die "can't create $model_dir.\n";


$thread_num = @servers;

for ($i = 0; $i < @servers; $i++)
{
	$server = $servers[$i];
	sleep(1); #sleep a while so that rosetta will start at different time points

	if ($server eq "rosetta2")
	{
		#generate fragments files for all ab initio modeling 
		print "generate fragment files for rosetta ab initio modeling...\n";
		`mkdir $output_dir/rosetta_common`; 
		chdir "$output_dir/rosetta_common"; 
		system("$meta_dir/script/make_rosetta_fragment.sh $query_file abini $output_dir/rosetta_common $local_model_num >/dev/null");

		chdir "$output_dir"; 
	}

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

			#remodel sp3 models
			for ($iii = 1; $iii <= 10; $iii++)
			{
				if (-f "${query_name}_sp3_$iii.pdb")
				{
					system("$meta_dir/script/threading.pl $query_file ${query_name}_sp3_$iii.pdb sthread$iii.pir sthread$iii.pdb"); 

					if (-f "spem$iii.pir")
					{
						`mv sthread$iii.pir sthread$iii.pir.org`;
						`cp spem$iii.pir sthread$iii.pir`; 
				
					}
				}
			}

			#run sp3 addition
			$sp3_add_dir = "$output_dir/sp3_add";
			`mkdir $sp3_add_dir`; 
			`cp $query_name.fasta $sp3_add_dir`; 
			chdir $sp3_add_dir;  
			system("$sparks_dir/bin/scan_sp3_add.job $query_name.fasta");
			system("$meta_dir/script/rank_sp3.pl ${query_name}_sp3.out $query_name > $query_name.rank");
			system("$meta_dir/script/multicom_gen.pl $sparks_option $query_file $query_name.rank .");
			for ($iii = 1; $iii <= 10; $iii++)
			{
				if ($iii <= 5)  #only use top five
				{
					`mv spem$iii.pir spar$iii.pir`; 
					`mv spem$iii.pdb spar$iii.pdb`; 
				}
				else
				{
					`mv spem$iii.pir spar$iii.pir1`; 
					`mv spem$iii.pdb spar$iii.pdb1`; 
				}
			}

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
			system("$hhsearch_dir/script/tm_hhsearch_main_v2.pl $hhsearch_option $query_file $server 1>out.log 2>err.log");
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;
		}

		elsif ($server eq "hhsearch15")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$hhsearch15_dir/script/tm_hhsearch1.5_main_v2.pl $hhsearch15_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;
		}

		elsif ($server eq "hhsearch151")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$hhsearch151_dir/script/tm_hhsearch151_main.pl $hhsearch151_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}

		elsif ($server eq "csblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$csblast_dir/script/multicom_csblast_v2.pl $csblast_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;

		}

		elsif ($server eq "csiblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$csblast_dir/script/multicom_csiblast_v2.pl $csiblast_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;
	
			#call fugue predictor
			#`mkdir fugue`; 
			#system("$fugue_dir/script/tm_fugue_main.pl $fugue_option $query_file fugue");
		}

		elsif ($server eq "blast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$blast_dir/script/main_blast_v2.pl $blast_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.easy.local" || `touch $server/$fasta_file.easy.local`;
			system("$hhsearch_dir/script/tm_hhsearch_main_casp8.pl $hhsearch_option_casp8 $query_file $server 1>out.log 2>err.log");
		}

		elsif ($server eq "psiblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$psiblast_dir/script/main_psiblast_v2.pl $psiblast_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.easy.local" || `touch $server/$fasta_file.easy.local`;
		}

		elsif ($server eq "newblast")
		{
			#system("$hhsearch_dir/script/tm_hhsearch_main.pl $hhsearch_option $query_file $server");
			system("$newblast_dir/script/newblast.pl $newblast_option $query_file $server");
		}

		elsif ($server eq "compass")
		{
			system("$compass_dir/script/tm_compass_main_v2.pl $compass_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;
		}
		elsif ($server eq "raptorx")
		{
			system("$raptorx_dir/script/tm_raptorx_main.pl $raptorx_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}

		elsif ($server eq "sam")
		{
			system("$sam_dir/script/tm_sam_main_v2.pl $sam_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}

		elsif ($server eq "prc")
		{
			system("$prc_dir/script/tm_prc_main_v2.pl $prc_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.prank" || `touch $server/$query_name.prank`;
		}

		elsif ($server eq "hhpred")
		{
			system("$hhpred_dir/script/tm_hhpred_main.pl $hhpred_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.filter.rank" || `touch $server/$query_name.filter.rank`;
		}

		elsif ($server eq "hhblits")
		{
			system("$hhblits_dir/script/tm_hhblits_main.pl $hhblits_option $query_file $server");
			system("$hhblits_dir/script/filter_identical_hhblits.pl hhblits"); 
			chdir $output_dir; 
			-e "$server/$query_name.filter.rank" || `touch $server/$query_name.filter.rank`;
		}

		elsif ($server eq "hhblits3")
		{
			system("$hhblits3_dir/script/tm_hhblits3_main.pl $hhblits3_option $query_file $server");
			system("$hhblits3_dir/script/filter_identical_hhblits.pl hhblits3"); 
			chdir $output_dir; 
			-e "$server/$query_name.filter.rank" || `touch $server/$query_name.filter.rank`;
		}

		elsif ($server eq "ffas")
		{
			system("$ffas_dir/script/tm_ffas_main.pl $ffas_option $query_file $server");

			#call hhsuite predictor
			`mkdir hhsuite`; 
			system("$hhsuite_dir/script/tm_hhsuite_main.pl $hhsuite_option $query_file hhsuite");

			#call hhsuite with super_option
			$super_option = "$hhsuite_dir/super_option";
			system("$hhsuite_dir/script/tm_hhsuite_main_simple.pl $super_option $query_file hhsuite"); 
			system("$hhsuite_dir/script/filter_identical_hhsuite.pl hhsuite"); 
			
			chdir $output_dir; 
			-e "$server/$fasta_file.local" || `touch $server/$fasta_file.local`;
			-e "hhsuite/$query_name.rank" || `touch hhsuite/$query_name.rank`;
		}
		elsif ($server eq "hhsuite3")
		{
			system("$hhsuite3_dir/script/tm_hhsuite3_main.pl $hhsuite3_option $query_file $server"); 
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}
		elsif ($server eq "deepsf")
		{

				system("$deepsf_dir/script/tm_deepsf_main.pl $deepsf_option $query_file $server");
		}
		elsif ($server eq "novel")
		{

				system("$novel_dir/script/tm_novel_main.pl $novel_option $query_file $server");
		}
		elsif ($server eq "confold")
		{
			system("$confold_dir/script/tm_confold2_main.sh $confold_option $query_file $server"); 
		}
		elsif ($server eq "rosettacon")
		{
			if (length($qseq) <= 400)
			{
				$dncon_check = "$output_dir/confold/dncon2/$query_name.dncon2.rr";
				`echo "checking $dncon_check" > $output_dir/$server/dncon2.waiting`;
				$minutes = 240; 
				$wait_min = 0; 
				while($wait_min < $minutes) # added by jie on 2018/04/09
				{
					if(-e $dncon_check)
					{
						last;
					}
					sleep(60); 
					$wait_min++; 
				}
				`mv  $output_dir/$server/dncon2.waiting  $output_dir/$server/dncon2.done`;
				system("$rosettacon_dir/script/tm_rosettacon_main.pl $rosettacon_option $query_file $server $dncon_check"); 
			}
		}
		elsif ($server eq "fusioncon")
		{
			if (length($qseq) <= 400)
			{
				$dncon_check = "$output_dir/confold/dncon2/$query_name.dncon2.rr";
				`echo "checking $dncon_check" > $output_dir/$server/dncon2.waiting`;
				$minutes = 240; 
				$wait_min = 0; 
				while($wait_min < $minutes) # added by jie on 2018/04/09
				{
					if(-e $dncon_check)
					{
						last;
					}
					sleep(60); 
					$wait_min++; 
				}
				`mv  $output_dir/$server/dncon2.waiting  $output_dir/$server/dncon2.done`;
				system("$fusioncon_dir/script/tm_fusioncon_main.pl $fusioncon_option $query_file $server $dncon_check"); 
			}
		}
		elsif ($server eq "unicon3d")
		{
			$dncon_check = "$output_dir/confold/dncon2/$query_name.dncon2.rr";
			`echo "checking $dncon_check" > $output_dir/$server/dncon2.waiting`;
			$minutes = 240; 
			$wait_min = 0; 
			while($wait_min < $minutes) # added by jie on 2018/04/09
			{
				if(-e $dncon_check)
				{
					last;
				}
				sleep(60); 
				$wait_min++; 
			}
			`mv  $output_dir/$server/dncon2.waiting  $output_dir/$server/dncon2.done`;
			system("$unicon3d_dir/script/tm_unicon3d_main.pl $unicon3d_option $query_file $server $dncon_check"); 
			#system("$unicon3d_dir/script/tm_unicon3d_main.pl $unicon3d_option $query_file $server"); 
		}

		elsif ($server eq "muster")
		{
			system("$muster_dir/script/tm_muster_main.pl $muster_option $query_file $server");
	#		system("$muster_dir/script/tm_lomets_main.pl $muster_option $query_file $server");
	#		system("$muster_dir/script/tm_NNNd_main.pl $muster_option $query_file $server");
			#filter out redundant models
			system("$muster_dir/script/filter_identical_muster.pl $server"); 
			chdir $output_dir; 
			-e "$server/$query_name.filter.rank" || `touch $server/$query_name.filter.rank`;
		}

		elsif ($server eq "hmmer")
		{
			system("$hmmer_dir/script/tm_hmmer_main_v2.pl $hmmer_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}

		elsif ($server eq "hmmer3")
		{
			system("$hmmer3_dir/script/tm_hmmer3_main.pl $hmmer3_option $query_file $server");
			chdir $output_dir; 
			-e "$server/$query_name.rank" || `touch $server/$query_name.rank`;
		}

		elsif ($server eq "multicom")
		{
			system("$multicom_dir/script/multicom_cm_v2.pl $multicom_option $query_file $server");
		}

		elsif ($server eq "rosetta")
		{
			if (length($qseq) <= 250)
			{
				print "$query_name is a hard, short target. Start to run Rosetta 1.\n";
				#since old rosetta is twice faster than new one. so we can increase simulation num
				#my $sim_num = $local_model_num * 2; 
				my $sim_num = int($local_model_num / 2); 
				#system("$meta_dir/script/rosetta_seed.pl $rosetta_dir $query_file $local_model_num 22222 $server");
				system("$meta_dir/script/rosetta_seed.pl $rosetta_dir $query_file $sim_num 22222 $server");

				#self model rosetta models
				system("$meta_dir/script/self_dir.pl $meta_dir/script/self.pl $server");
			}
		}

		elsif ($server eq "rosetta2" || $server eq "rosetta3" || $server eq "rosetta4" || $server eq "rosetta5" || $server eq "rosetta6" || $server eq "rosetta7")
		{
			if (length($qseq) > 200)
			{
				$local_model_num = int($local_model_num / 2) + 10;
			}
			if (length($qseq) > 300)
			{
				$local_model_num = int($local_model_num / 3) + 10;
				#next;
			}
			if (length($qseq) > 400)
			{
				$local_model_num = int($local_model_num / 4) + 10;
				#next;
			}
			if (length($qseq) > 500)
			{
				$local_model_num = int($local_model_num / 5) + 10;
				#next;
			}
			if (length($qseq) > 600)
			{
				$local_model_num = int($local_model_num / 6) + 10;
				#next;
			}

		#	if (length($qseq) <= 200) #only generate models for less than 180 residues
		#	{
				use Cwd;
				$server_dir = abs_path($server); 	
	
				chdir $server_dir; 

				print "$query_name is a hard, short target. Start to run Rosetta 2.\n";

				#copy fragment files
				`cp -r $output_dir/rosetta_common/abini $server_dir`; 
				system("$meta_dir/script/run_rosetta_no_fragment.sh $query_file abini $server_dir $local_model_num >/dev/null");
				#evaluate these models using ModelEvaluator
				#select at most top 10 models for further 
				#analysis
				print "Evaluate ab initio models using ModelEvaluator...\n";
				#the score is stored in $query_name.mch
				`cp $query_file $query_name.fasta`; 
				system("$prosys_dir/script/score_models.pl $meta_dir/script/eva_option $query_name.fasta $server_dir/abini");
				#sort models by scores 
				open(MCH, "$server_dir/abini/$query_name.mch") || die "can't read Rosetta 2 score file.\n";
				@mch = <MCH>;
				close MCH; 	
				my @model2score = (); 
				while (@mch)
				{
					my $line = shift @mch; 
					chomp $line; 
					@fields = split(/\s+/, $line); 
					push @model2score, {
						"name" => $fields[0], 
						"score" => $fields[1]
					}; 	

				}

				my @sorted_model2score	= (); 
				if (@model2score > 0)
				{	
					@sorted_model2score = sort {$b->{"score"} <=> $a->{"score"}} @model2score; 
				}
				#select up to 10 models with highest scores	
				my $i = 0; 
				open(SEL, ">$server_dir/selected_models"); 
				#for ($i = 0; $i < 5 && $i < @sorted_model2score; ++$i)
				#increased the number of selected ab initio models
				for ($i = 0; $i < 8 && $i < @sorted_model2score; ++$i)
				{
					my $model_name = $sorted_model2score[$i]->{"name"}; 
					my $score = $sorted_model2score[$i]->{"score"}; 
					`cp $server_dir/abini/$model_name $server_dir/denovo$i.pdb`; 

					###########Chain chain id from "A" to " "#################### 	
					open(AB, "$server_dir/denovo$i.pdb"); 
					@ab = <AB>;
					close AB;
					open(AB, ">$server_dir/denovo$i.pdb"); 
					while (@ab)
					{
						$line = shift @ab;
						if ($line =~ /^ATOM/)
						{
							$left = substr($line, 0, 21);
							$right = substr($line, 22);
							$record = "$left $right";
							print AB $record;
						}
					}		
					close AB;
					###############################################################

					print SEL "$model_name\tdenovo$i\t$score\n";		

				}
				close SEL; 

				#self model rosetta models
				system("$meta_dir/script/self_dir.pl $meta_dir/script/self.pl $server_dir");

		#	}
		}
		elsif ($server eq "construct")
		{
			system("$construct_dir/script/construct_hard_v9.pl $construct_option $query_file $output_dir");
		}
		elsif ($server eq "confoldtemp")
		{
			if (length($qseq) <= 400)
			{
				system("$confoldtemp_dir/script/tm_confoldtemp_main.pl $confoldtemp_option $query_file $output_dir");
			}
		}

		elsif ($server eq "msa")
		{
				system("$msa_dir/script/msa4.pl $msa_option $query_file $output_dir");
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
	@servers = ("hhsearch", "compass", "csiblast", "sam", "hmmer", "hmmer3", "psiblast", "newblast", "blast", "hhsearch15", "prc", "rosetta2", "rosetta3", "rosetta4", "rosetta5", "rosetta6", "rosetta7", "construct", "hhpred", "hhblits", "hhblits3", "ffas", "muster", "hhsearch151", "hhsuite", "hhsuite3", "raptorx", "msa", "confold", "rosettacon", "fusioncon", "unicon3d", "deepsf", "novel", "confoldtemp"); 


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

			#for casp8 hhsearch
			if ($file =~ /^hs\d+\.pdb$/ || $file=~ /^hs\d+\.pir$/)
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

			if ($file =~ /^newblast\d+\.pdb$/ || $file=~ /^newblast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

                        if ($file =~ /^novel\d+\.pdb$/ || $file=~ /^novel\d+\.pir$/)
                        {
                                `cp $server_dir/$file $model_dir/meta_$file`;
                        }
                        if ($file =~ /^deepsf\d+\.pdb$/ || $file=~ /^deepsf\d+\.pir$/)
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

			if ($file =~ /^hp\d+\.pdb$/ || $file=~ /^hp\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^contemp\d+\.pdb$/ || $file=~ /^contemp\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^ff\d+\.pdb$/ || $file=~ /^ff\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^muster\d+\.pdb$/ || $file=~ /^muster\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^lomets\d+\.pdb$/ || $file=~ /^lomets\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^Unicon3d.+\.pdb$/ || $file=~ /^Unicon3d.+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^confold2.+\.pdb$/ || $file=~ /^confold2.+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^uniconfold\d+\.pdb$/ || $file=~ /^uniconfold\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^nnnd\d+\.pdb$/ || $file=~ /^nnnd\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^blits\d+\.pdb$/ || $file=~ /^blits\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^rocon\d+\.pdb$/ || $file=~ /^rocon\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^fusicon\d+\.pdb$/ || $file=~ /^fusicon\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hhbl\d+\.pdb$/ || $file=~ /^hhbl\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^gbli\d+\.pdb$/ || $file=~ /^gbli\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hmmer\d+\.pdb$/ || $file=~ /^hmmer\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^jackhmmer\d+\.pdb$/ || $file=~ /^jackhmmer\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^ap\d+\.pdb$/ || $file=~ /^ap\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hg\d+\.pdb$/ || $file=~ /^hg\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^csblast\d+\.pdb$/ || $file=~ /^csblast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^csiblast\d+\.pdb$/ || $file=~ /^csiblast\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^multicom\d+\.pdb$/ || $file=~ /^multicom\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^construct\d+\.pdb$/ || $file=~ /^construct\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

                        if ($file =~ /^msaprobs\d+\.pdb$/ || $file=~ /^msaprobs\d+\.pir$/)
                        {
                                `cp $server_dir/$file $model_dir/meta_$file`;
                        }

                        if ($file =~ /^compro\d+\.pdb$/ || $file=~ /^compro\d+\.pir$/)
                        {
                                `cp $server_dir/$file $model_dir/meta_$file`;
                        }

                        if ($file =~ /^promals\d+\.pdb$/ || $file=~ /^promals\d+\.pir$/)
                        {
                                `cp $server_dir/$file $model_dir/meta_$file`;
                        }



			if ($file =~ /^center\d+\.pdb$/ || $file=~ /^center\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^star\d+\.pdb$/ || $file=~ /^star\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^hstar\d+\.pdb$/ || $file=~ /^hstar\d+\.pir$/)
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
			if ($file =~ /^rapt\d+\.pdb$/ || $file=~ /^rapt\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 
			if ($file =~ /^super\d+\.pdb$/ || $file=~ /^super\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 

			if ($file =~ /^fugue\d+\.pdb$/ || $file=~ /^fugue\d+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`;	
			} 



			if ($file =~ /^ab\d+\.pdb$/)
			{
				`cp $server_dir/$file $model_dir/meta_rose_$file`;	
			}

			if ($file =~ /^denovo\d+\.pdb$/)
			{
				if ($servers[$i] eq "rosetta2")
				{
					`cp $server_dir/$file $model_dir/meta_abi2_$file`;	
				}
				if ($servers[$i] eq "rosetta3")
				{
					`cp $server_dir/$file $model_dir/meta_abi3_$file`;	
				}
				if ($servers[$i] eq "rosetta4")
				{
					`cp $server_dir/$file $model_dir/meta_abi4_$file`;	
				}
				if ($servers[$i] eq "rosetta5")
				{
					`cp $server_dir/$file $model_dir/meta_abi5_$file`;	
				}
				if ($servers[$i] eq "rosetta6")
				{
					`cp $server_dir/$file $model_dir/meta_abi6_$file`;	
				}
				if ($servers[$i] eq "rosetta7")
				{
					`cp $server_dir/$file $model_dir/meta_abi7_$file`;	
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
			if ($file =~ /^spar.+\.pdb$/ || $file=~ /^spar.+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_spar_$file`; 	
			}

			if ($file =~ /^sthread.+\.pdb$/ || $file=~ /^sthread.+\.pir$/)
			{
				`cp $server_dir/$file $model_dir/meta_$file`; 	
			}
			

		}
	}

	#rank models
	system("$prosys_dir/script/score_models.pl $meta_dir/script/eva_option $query_file $model_dir");
#	system("$prosys_dir/script/energy_models_proc.pl $meta_dir/script/eva_option $query_file $model_dir");

	open(FASTA, $query_file) || die "can't read $query_file.\n";
	$name = <FASTA>;
	$name = substr($name, 1);
	chomp $name;
	close FASTA;
	system("$meta_dir/script/evaluate_models_meta_v2.pl $prosys_dir $model_dir $name $query_file $model_dir/meta.eva");

	#do pairwise QA evaluation
	system("$meta_dir/script/pairwise_model_eva.pl $model_dir $query_file $q_score $tm_score $name $model_dir"); 
}
###############################################################################
END:
