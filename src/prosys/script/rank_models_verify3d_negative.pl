#!/usr/bin/perl -w
#######################################################################
#Rank predicted 3D models (cm, fr, and ab)
#Input: script dir, verify 3d dir, dssp dir, target_fasta_file, input_output_dir, reorder best ratio
#reorder best ratio decide if the first model should be exchanged with the best model when v3d score
#ratio is > the ratio. 
#Output: foldpro1.pdb, foldpro2.pdb, foldpro3.pdb .... 
#Author: Jianlin Cheng
#Date: 1/16/2006
#######################################################################
if (@ARGV != 6)
{
	die "need six parameters: script dir, verify 3d dir, dssp dir, target fasta file, input/output dir, reorder best ratio(>1).\n";
}

$script_dir = shift @ARGV;
$verify3d_dir = shift @ARGV;
$dssp_dir = shift @ARGV;
$fasta_file = shift @ARGV;
$output_dir = shift @ARGV; 
$best_ratio = shift @ARGV;

$best_ratio > 1 || die "the reorder best ratio must be bigger than 1.\n";

-d $script_dir || die "can't find script dir: $script_dir\n";

#read fasta file
open(FASTA, $fasta_file) || die "can't read $fasta_file\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>;
chomp $seq;
close FASTA;
$length = length($seq); 


@models = (); 

$sig_match = 0; 

#assign a score to each model

#rule 1: use cmfr model first
$candidate = "$output_dir/cmfr_ab.pdb"; 
if ( -f $candidate )
{
	$sig_match = 1;
	push @models , {
		model => $candidate,
		type => "cmfr_ab",
		align => "cmfr_ab.pir",
		score => 100,
		v3d => -1000
		}; 
}
elsif (-f "$output_dir/cmfr.pdb")
{
	$sig_match = 1;
	push @models , {
		model => "$output_dir/cmfr.pdb",
		type => "cmfr",
		align => "cmfr.pir",
		score => 100,
		v3d => -1000
		}; 
}

#rule 2: use cm model
$candidate = "$output_dir/cm_ab.pdb"; 
if ( -f $candidate )
{
	$sig_match = 1;
	push @models , {
		model => "$output_dir/cm_ab.pdb",
		type => "cm_ab",
		align => "cm_ab.pir",
		score => 90,
		v3d => -1000
		}; 
}
elsif ( -f "$output_dir/cm.pdb")
{
	$sig_match = 1;
	push @models , {
		model => "$output_dir/cm.pdb",
		type => "cm",
		align => "cm.pir",
		score => 90,
		v3d => -1000
		}; 
}

#rule 3: use frcom model
$candidate = "$output_dir/frcom_ab.pdb"; 
if ( -f $candidate )
{
	$sig_match = 1;
	push @models , {
		model => $candidate,
		type => "frcom_ab",
		align => "frcom_ab.pir",
		score => 80,
		v3d => -1000
		}; 
}
elsif ( -f "$output_dir/frcom.pdb")
{
	$sig_match = 1;
	push @models , {
		model => "$output_dir/frcom.pdb",
		type => "frcom",
		align => "frcom.pir",
		score => 80,
		v3d => -1000
		}; 
}

#read svm rank file  and create a template-svm score map
open(RANK, "$output_dir/$name.rank") || die "can't find $output_dir/$name.rank\n";
<RANK>;
@rank = <RANK>;
close RANK;
@temp_svm = ();
while (@rank)
{
	$record = shift @rank;
	chomp $record;
	@fields = split(/\s+/, $record);
	$temp_svm{$fields[1]} = $fields[2]; 
}

#rule 4: take positive fr models
#if svm score > 0, score = 80 - rank 
#if svm score >= -0.6, score = 70 - rank
#if svm score < -0.6, score = 60 - rank
for ($i = 1; $i <= 10; $i++)
{
	if (-f "$output_dir/fr${i}_ab.pdb")
	{
		$candidate = "$output_dir/fr${i}_ab.pdb";	
		$pir = "$output_dir/fr${i}_ab.pir";
	}
	else
	{
		$candidate = "$output_dir/fr$i.pdb";	
		$pir = "$output_dir/fr$i.pir";
	}

	if (-f $candidate)
	{
		open(CANDI, $pir) || die "can't read $pir\n"; 
		<CANDI>;
		$temp_name = <CANDI>;
		close CANDI;
		chomp $temp_name;
		$temp_name = substr($temp_name, 4);
		$svm_score = $temp_svm{$temp_name}; 

		defined $svm_score || die "no svm score for $temp_name\n";

		if ($svm_score >= 0)
		{
			$sig_match = 1;
			$assign_score = 80 - $i; 
		}
		#here set threshold to -0.7
		elsif ($svm_score >= -0.7)
		{
			$assign_score = 70 - $i; 
		}
		else
		{
			$assign_score = 60 - $i; 
		}

		push @models , {
			model => $candidate,
			type => "fr",
			#align => $pir,
			align => "fr$i.pir",
			score => $assign_score,
			v3d => -1000
		}; 
	}
}


#rule 5: if sequence is short, rank ab higher
#otherwise, rank it lower. But use at most two ab models
#check top 2 ab initio model
#if sequence length < 150, score = 61 - rank 
#if sequence length > 150, score = 59 - rank  

for ($i = 1; $i <= 2; $i++)
{
	$candidate = "$output_dir/ab$i.pdb"; 
	#here set length threshold to 300
	if ($length <= 300)
	{
		$assign_score = 61 - $i; 
	}
	else
	{
		$assign_score = 59 - $i; 
	}
	if ( -f $candidate )
	{
		push @models , {
			model => $candidate,
			type => "ab",
			#all ab models using the same alignment file: ab1.pir for model conversion into casp.
			align => "ab1.pir",
			score => $assign_score,
			v3d => -1000
		}; 
	}
}

##################################Generate Verify3d score for each model#######################
#score models using assigned score
@sorted = sort {$b->{"score"} <=> $a->{"score"}} @models; 
$size = @sorted;

$bsuccess = 1; 

for ($i = 0; $i < $size; $i++)
{
	$source_file = $sorted[$i]{"model"};
	if (-f $source_file)
	{
		#generate verify 3d score
		system("$script_dir/verify3d.pl $script_dir/dssp2dataset.pl $verify3d_dir $dssp_dir $source_file $source_file.v3d 1>/dev/null 2>/dev/null");
		#read quality score
		$score = -100000; 
		if (open(SCORE, "$source_file.v3d"))
		{
			while (<SCORE>)
			{
				$line = $_;
				if ($line =~ /^\s+Quality:\s+(\S+)$/)
				{
					$score = $1; 
				}
			}
		}
		else
		{
			$bsuccess = 0;
			last;
		}
		`rm $source_file.v3d`; 
		if ($score > -100000)
		{
			$sorted[$i]{"v3d"} = $score; 
		}
		else
		{
			$bsuccess = 0;
			last;
		}
	}
}

#reorder the model using v3d score when no significant match is found
if ($bsuccess == 1 && $sig_match == 0)
{
	print "reorder models for $name using verify3d scores.\n";
	@sorted = sort {$b->{"v3d"} <=> $a->{"v3d"}} @models; 
}

#select top 5 model and output related information
open(MODEL, ">$output_dir/$name.v3d");

$idx = 0;
for ($i = 0; $i < $size; $i++)
{
	#copy model	
	$source_file = $sorted[$i]{"model"};
	if (-f $source_file)
	{
		$idx++; 
		`cp $source_file $output_dir/vfold$idx.pdb`; 

		#convert foldpro model to casp format
		`$script_dir/pdb2casp.pl $output_dir/vfold$idx.pdb $output_dir/$sorted[$i]{"align"} $idx $output_dir/cafasp$idx.pdb`;

		print MODEL "vfold$idx.pdb\tcafasp$idx.pdb\t", $sorted[$i]{"model"}, "\t", $sorted[$i]{"type"},"\t", $sorted[$i]{"align"},"\t", $sorted[$i]{"score"}, "\t", $sorted[$i]{"v3d"}, "\n";

	}
}
close MODEL;


