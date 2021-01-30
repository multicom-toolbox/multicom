#!/usr/bin/perl -w
#############################################
#Select models for the hybrid server
#Input: prediction dir (/home/casp11/T0700), target name (T0700), output subdirectory name.
#############################################
if (@ARGV != 3)
{
	die "need three parameters: prediction dir to store all predictions (e.g. /home/casp11/T0700), target name (T0700), output subdirectory name (e.g. hybrid)\n";
} 

$target_dir = shift @ARGV;
$target_name = shift @ARGV;
$hybrid_name = shift @ARGV;

-d $target_dir || die "hybrid: $target_dir doesn't exist.\n";

$model_dir = "$target_dir/full_length/meta";
-d $model_dir || die "hybrid: $model_dir doesn't exist.\n";

$rank_file = "$model_dir/$target_name.gdt";
-f $rank_file || die "hybrid: $rank_file doesn't exist.\n";
open(RANK, $rank_file) || die "can't read $rank_file.\n";
@rank = <RANK>;
close RANK;

@servers = ("ss", "hh", "hp", "hhsuite", "psiblast", "multicom", "sam", "com", "blits", "hg", "rapt", "hs", "csiblast", "newblast", "ap");

@numbers = ("1", "2");

$hybrid_dir = "$target_dir/$hybrid_name";
`mkdir $hybrid_dir`; 

$hybrid_rank = "$hybrid_dir/$target_name.rank";
open(HYBRID, ">$hybrid_rank") || die "can't create $hybrid_rank\n";
print HYBRID "Model\tScore\n";

shift @rank;	
shift @rank;	
shift @rank;	
shift @rank;	
pop @rank;

while (@rank)
{

	$model_info = shift @rank;
	chomp $model_info;
	($model_name, $model_score) = split(/\s+/, $model_info);
	
	#check if the model is in the selection list	
	
	foreach $server (@servers)
	{
		foreach $id (@numbers)
		{
			$candidate_name = "meta_$server$id.pdb";	
			$prefix_name = "meta_$server$id.pir";
			if ($model_name eq $candidate_name)
			{
				print "Select $model_name for the hybrid server.\n";
				print HYBRID "$model_name $model_score\n";			
				`cp $model_dir/$model_name $hybrid_dir`;
				`cp $model_dir/$prefix_name $hybrid_dir`; 
				last;
			}
		}	
	}
}

close HYBRID; 
`cp $model_dir/$target_name.FASTA $hybrid_dir/$target_name.fasta`; 

