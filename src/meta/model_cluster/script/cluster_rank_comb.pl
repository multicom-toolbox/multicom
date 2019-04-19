#!/usr/bin/perl -w
#######################################################################
#Cluster a banch of models ranked by model_check or model_energy
#get closet model to the centroid of each cluster
#use closet model as start point to build a combined model using
#global and local alignments
#Input: spicker program, psi-pred dir, model dir file, model rank file
#FASTA sequence, output dir
#Date: 3/24/2008.
#Author: Jianlin Cheng
#######################################################################

if (@ARGV != 6)
{
	die "need six parameters: model cluster script dir, spicker program, model dir file, model rank file (ave ranking score file), FASTA sequence, and output dir.\n";
}

$cluster_dir = shift @ARGV;
use Cwd 'abs_path';
$cluster_dir = abs_path($cluster_dir);

$spicker = shift @ARGV;
$model_dir = shift @ARGV;
$model_rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$out_dir = shift @ARGV;

-d $cluster_dir || die "can't open $cluster_dir.\n";
-f $spicker || die "$spicker is not found.\n";
-d $model_dir || die "can't find $model_dir.\n";

-f $model_rank_file || die "can't find $model_rank_file.\n";
-f $fasta_file || die "can't find $fasta_file.\n";
-d $out_dir || die "can't find $out_dir.\n";

$pulchar = "$cluster_dir/pulchar";
-f $pulchar || die "can't find $pulchar.\n";
$modeller = "$cluster_dir/pir2ts_energy.pl";
-f $modeller || die "can't find $modeller.\n";
#$clash = "$cluster_dir/clash_check.pl ";

#change to absoluate path
use Cwd 'abs_path';
$spicker = abs_path($spicker);
$model_dir = abs_path($model_dir);
$model_rank_file = abs_path($model_rank_file);
$fasta_file = abs_path($fasta_file);

#create a sequence file for clustering
open(FASTA, $fasta_file) || die "$fasta_file is not found.\n";
@fasta = <FASTA>;
close FASTA;
$name = $fasta[0];
chomp $name;
$name = substr($name, 1);
$seq = $fasta[1];
chomp $seq;
close FASTA;

`cp $fasta_file $out_dir/$name.fasta`;

chdir $out_dir;

open(RANK, $model_rank_file) || die "can't open $model_rank_file.\n";
@rank = <RANK>;
close RANK;

shift @rank; shift @rank; shift @rank; shift @rank; 
pop @rank;

#set the number of models to cluster
$num = int(@rank / 2);

#predict secondary structure
#$idx = rindex($fasta_file, ".");
#if ($idx > 0)
#{
#	$filename = substr($fasta_file, 0, $idx);
#}
#else
#{
#	$filename = $fasta_file;
#}

open(SEQ, ">seq.dat") || die "can't create seq.dat";
$slen = length($seq);

%amino=();
$amino{"A"} = "ALA";
$amino{"C"} = "CYS";
$amino{"D"} = "ASP";
$amino{"E"} = "GLU";
$amino{"F"} = "PHE";
$amino{"G"} = "GLY";
$amino{"H"} = "HIS";
$amino{"I"} = "ILE";
$amino{"K"} = "LYS";
$amino{"L"} = "LEU";
$amino{"M"} = "MET";
$amino{"N"} = "ASN";
$amino{"P"} = "PRO";
$amino{"Q"} = "GLN";
$amino{"R"} = "ARG";
$amino{"S"} = "SER";
$amino{"T"} = "THR";
$amino{"V"} = "VAL";
$amino{"W"} = "TRP";
$amino{"Y"} = "TYR";

for($i = 0; $i < $slen; $i++)
{
		
	$ord = $i+1;
	$aa = substr($seq, $i, 1);
	$aaa = $amino{$aa};

	printf SEQ "%5d%6s%5d%5d\n", $ord, $aaa, "1", 0;
}
close SEQ;

#create rmsinp file
open(RMSINP, ">rmsinp") || die "can't create rmsinp\n";
print RMSINP "1  $slen\n";
print RMSINP "$slen\n";
print RMSINP "$name\n";
close RMSINP; 

#create trajectory file
open(TRA, ">tra.in") || die "can't create trajectory file.\n";
print TRA " 1\n";
print TRA "rep1.tra1\n";
close TRA;

open(REP, ">rep1.tra1");

$idx = 0; 
@selected_models = ();
for ($i = 0; $i < $num; $i++)
{
	$line = $rank[$i];
	chomp $line;
	($model, $score) = split(/\s+/, $line);
	push @selected_models, $model;
	
	$model_file = "$model_dir/$model";
	-f $model_file || next; 
		
	@atoms = ();
	open(MODEL, $model_file) || die "can't read $model_file.\n";
	@atoms = <MODEL>;	
	close MODEL;

	print "process model $model_file...\n";

	@ca_x = ();
	@ca_y = ();
	@ca_z = ();

	while (@atoms)
	{
		$line = shift @atoms;

#		print $line, "\n";
#		print "pressy any key to continue...";
#		<STDIN>;	
	
		if ($line =~ /^ATOM/)
		{
			$type = substr($line, 12, 4);	
			$xc = substr($line, 30, 8);
                        $xc =~ s/\s//g;
                        $yc = substr($line, 38, 8);
                        $yc =~ s/\s//g;
                        $zc = substr($line, 46, 8);
                        $zc =~ s/\s//g;
			if ($type =~/CA/)
			{
				push @ca_x, $xc;
				push @ca_y, $yc;
				push @ca_z, $zc;
			}
		}	
	}

	@ca_x == $slen || die "sequence length does not match with the number of CA atoms.\n";

	#printf REP "%8d%10d%8d%8d\n", $slen, $score*100+0.1, $i+1, $i+1; 
	printf REP "%8d%10d%8d%8d\n", $slen, $score*100+0.1, $idx+1, $idx+1; 

	for ($j = 0; $j < $slen; $j++)
	{
		printf REP "%10.3f%10.3f%10.3f\n", $ca_x[$j], $ca_y[$j], $ca_z[$j]; 
	}
	$idx++;
	
}

close REP;

#cluster models
system("$spicker");

#select the model of the first cluster
@close_models = ();
for ($i = 1; $i <= 5; $i++)
{
	if (-f "closc$i.pdb")
	{

		#identify the model
		$model_name = "";
		foreach $model (@selected_models)
		{
			$model_file = "$model_dir/$model";
			$out = `/home/chengji/software/tm_score/TMscore_32 $model_file closc$i.pdb`;
			@out = split(/\n+/, $out);
			$found = 0; 
			foreach $line (@out)
			{
				if ($line =~ /TM-score\s+=/)
				{
					@fields = split(/\s+/, $line);
					if ($fields[2] >= 1)
					{
						$found = 1;		
						last;
					}
				}
			}
			if ($found == 1)
			{
				$model_name = $model;
				last;	
			}
		}
		if ($model_name ne "")
		{
			push @close_models, $model_name;
		}

	}
} 


open(RANK, $model_rank_file) || die "can't open $model_rank_file.\n";
@rank = <RANK>;
close RANK;

push @new_rank, shift @rank; 
push @new_rank, shift @rank; 
push @new_rank, shift @rank; 
push @new_rank, shift @rank; 

@target_model = ();

$pattern = join(" ", @close_models);

@tmp = ();

foreach $record (@rank)
{
	@fields = split(/\s+/, $record);
	if (@fields eq "END")
	{
		next;
	}
	if ($pattern =~ /$fields[0]/)
	{
		push @target_model, $record;
	}
	else
	{
		push @tmp, $record;
	}
}

push @new_rank, @target_model;

push @new_rank, @tmp;

#create a new rank file
open(RANK, ">$name.rank");
print RANK join("", @new_rank);
close RANK;

#do model combination
system("$cluster_dir/global_local_human_noscwrl.pl $model_dir $fasta_file $name.rank .");




