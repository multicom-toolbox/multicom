#!/usr/bin/perl -w
##############################################################################
#A program to refine and cluster the models generated by cmfr, rank, and meta
#Inputs:model_cluster dir, output dir
#Author: Jianlin Cheng
##############################################################################

if (@ARGV != 3)
{
	die "need three parameters: model cluster dir, target fasta file, output dir.\n";
}

$model_cluster_dir = shift @ARGV;
$fasta_file = shift @ARGV;
open(FASTA, $fasta_file) || die "can't find $fasta_file.\n";
$target_name = <FASTA>;
close FASTA;
chomp $target_name;
$target_name = substr($target_name, 1);
#$target_name = shift @ARGV;
$output_dir = shift @ARGV;

$cmfr_dir = "/home/chengji/casp_home/casp8_cmfr/";
-d $cmfr_dir || die "can't find cmfr_dir.\n";
$rank_dir = "/home/chengji/casp8_rank/";
-d $rank_dir || die "can't find rank_dir.\n";
$meta_dir = "/home/chengji/casp8_meta/";
-d $meta_dir || die "can't find meta_dir.\n";

#time out is set to 24 hours. (most likely it only requires several hours)
$time_out = 3600 * 24;

$cmfr_yes = 0;
$rank_yes = 0;
$meta_yes = 0;

$time = 1; 

#record process id and time
$process_id = "$output_dir/process_id";
open(PROC, ">$process_id");
print PROC "Process id = $$\n";

#set the start time
$sdate = `date`; 
print "start date: $sdate";
print PROC $sdate;

#open(PROC, ">>$process_id") || die "can't append $process_id\n";

$cmfr_eva = "$cmfr_dir/$target_name/$target_name.fr.eva";

$rank_eva = "$rank_dir/$target_name/$target_name.fr.eva";

$meta_eva = "$meta_dir/$target_name/meta.eva";

while ($time < $time_out)
{
	#check if cmfr eva file there		
	if (-f "$cmfr_dir/$target_name/$target_name.fr.eva")
	{
		print "find cmfr models.\n";
		$cmfr_yes = 1;
	}
	if (-f "$rank_dir/$target_name/$target_name.fr.eva")
	{
		print "find rank models.\n";
		$rank_yes = 1; 
	}
	if (-f "$meta_dir/$target_name/meta.eva")
	{
		print "find meta models.\n";
		$meta_yes = 1; 
	}
	
	#check if rank eva file there
	#check if meta eva file there
	if ($cmfr_yes == 1 && $rank_yes == 1 && $meta_yes == 1)
	{
		print "find cmfr, rank, and meta models.\n";
		sleep(10);
		last;
	}
	
	sleep(1);
	$time++;

	if ($time % 60 == 0)
	{
		$min = $time / 60;
		print PROC $min, " ";
		print ".";
	}
}

#create a new ranking list

$max = 100; 

@rank = ();
if ($cmfr_yes == 1)
{
	print "cmfr_yes\n";
	print PROC "cmfr = yes\n";
	open(EVA, $cmfr_eva) || die "can't read $cmfr_eva\n";
	@eva = <EVA>;
	close EVA;
	shift @eva;
	$count = 1;
	while (@eva && $count <= $max)
	{
		$line = shift @eva;
		@fields = split(/\s+/, $line);		
		$name = $fields[0];
		$idx = rindex($name, ".");
		$prefix = substr($name, 0, $idx);
		
		$orig_file = "$cmfr_dir/$target_name/$name";
		if (-f $orig_file)
		{
			`cp $orig_file $output_dir/cmfr_$prefix.pdb`;

			push @rank, {
				name => "cmfr_$prefix.pdb",
				method => $fields[1],
				template => $fields[2],
				coverage => $fields[3],
				identity => $fields[4],
				blast_evalue => $fields[5],
				reg_clashes => $fields[11],
				ser_clashes => $fields[12],
				model_check => $fields[13],
				model_energy => $fields[14],
				check_rank => $fields[15],
				energy_rank => $fields[16],
				average_rank => $fields[17]		
			
				};

		}
		if (-f "$cmfr_dir/$target_name/$prefix.pir")
		{
			`cp $cmfr_dir/$target_name/$prefix.pir $output_dir/cmfr_$prefix.pir`;
		}
		$count++;
	}
}
else
{
	print PROC "cmfr = no\n";
}

if ($rank_yes == 1)
{
	print PROC "rank = yes\n";
	print "rank_yes\n";
	open(EVA, $rank_eva) || die "can't read $cmfr_eva\n";
	@eva = <EVA>;
	close EVA;
	shift @eva;
	$count = 1;
	while (@eva && $count <= $max)
	{
		$line = shift @eva;
		@fields = split(/\s+/, $line);		
		$name = $fields[0];
		$idx = rindex($name, ".");
		$prefix = substr($name, 0, $idx);
		
		$orig_file = "$rank_dir/$target_name/$name";
		if (-f $orig_file)
		{
			`cp $orig_file $output_dir/rank_$prefix.pdb`;

			push @rank, {
				name => "rank_$prefix.pdb",
				method => $fields[1],
				template => $fields[2],
				coverage => $fields[3],
				identity => $fields[4],
				blast_evalue => $fields[5],
				reg_clashes => $fields[11],
				ser_clashes => $fields[12],
				model_check => $fields[13],
				model_energy => $fields[14],
				check_rank => $fields[15],
				energy_rank => $fields[16],
				average_rank => $fields[17]		
				};

		}
		if (-f "$rank_dir/$target_name/$prefix.pir")
		{
			`cp $rank_dir/$target_name/$prefix.pir $output_dir/rank_$prefix.pir`;
		}
		$count++;
	}
}
else
{
	print PROC "rank = no\n";
}
	

if ($meta_yes == 1)
{
	print PROC "rank = yes\n";
	print "meta = yes\n";
	open(EVA, $meta_eva) || die "can't read $meta_eva\n";
	@eva = <EVA>;
	close EVA;
	shift @eva;
	$count = 1;
	while (@eva && $count <= $max)
	{
		$line = shift @eva;
		@fields = split(/\s+/, $line);		
		$name = $fields[0];
		$idx = rindex($name, ".");
		$prefix = substr($name, 0, $idx);
		
		$orig_file = "$meta_dir/$target_name/$name";
		if (-f $orig_file)
		{
			`cp $orig_file $output_dir/$prefix.pdb`;

			push @rank, {
				name => "$prefix.pdb",
				method => $fields[1],
				template => $fields[2],
				coverage => $fields[3],
				identity => $fields[4],
				blast_evalue => $fields[5],
				reg_clashes => $fields[6],
				ser_clashes => $fields[7],
				model_check => $fields[8],
				model_energy => $fields[9],
				check_rank => $fields[10],
				energy_rank => $fields[11],
				average_rank => $fields[12]		
				};
		}
		if (-f "$meta_dir/$target_name/$prefix.pir")
		{
			`cp $meta_dir/$target_name/$prefix.pir $output_dir/$prefix.pir`;
		}
		$count++;
	}
}
else
{
	print PROC "meta = no\n";
}

#rank pdb files using average ranking.    

#sort by model check score
@sorted_models = sort {$b->{"model_check"} <=> $a->{"model_check"}} @rank;
for ($i = 0; $i < @sorted_models; $i++)
{
	$sorted_models[$i]{"check_rank"} = $i + 1;
}

#sort by model energy
@energy_models = sort {$a->{"model_energy"} <=> $b->{"model_energy"}} @sorted_models;
for ($i = 0; $i < @energy_models; $i++)
{
	$energy_models[$i]{"energy_rank"} = $i + 1;
	$energy_models[$i]{"average_rank"} = ($energy_models[$i]{"check_rank"} + $energy_models[$i]{"energy_rank"}) / 2;
}

@rank_models = sort {$a->{"average_rank"} <=> $b->{"average_rank"}} @energy_models;

open(OUT, ">$output_dir/consensus.eva");

open(SCORE, ">$output_dir/score");
print SCORE "PFRMAT QA\n";
print SCORE "TARGET \n";
print SCORE "MODEL \n";
print SCORE "QMODE \n";

print OUT "name\t\tmethod\ttemp\tcov\tident\tblast_e\tr_cla\ts_cla\tmcheck\tmenergy\t\tcrank\terank\tarank\n";
for ($i = 0; $i < @rank_models; $i++)
{

	if (0)
	{
	print $rank_models[$i]{"name"}, "\t";
	print $rank_models[$i]{"method"}, "\t";
	print $rank_models[$i]{"template"}, "\t";
	print $rank_models[$i]{"coverage"}, "\t";
	print $rank_models[$i]{"identity"}, "\t";
	print $rank_models[$i]{"blast_evalue"}, "\t";
	print $rank_models[$i]{"reg_clashes"}, "\t";
	print $rank_models[$i]{"ser_clashes"}, "\t";
	print $rank_models[$i]{"model_check"}, "\t";
	print $rank_models[$i]{"model_energy"}, "\t";
	print $rank_models[$i]{"check_rank"}, "\t";
	print $rank_models[$i]{"energy_rank"}, "\t";
	print $rank_models[$i]{"average_rank"}, "\n";
	}


	print OUT $rank_models[$i]{"name"}, "\t";
	print OUT $rank_models[$i]{"method"}, "\t";
	print OUT $rank_models[$i]{"template"}, "\t";
	print OUT $rank_models[$i]{"coverage"}, "\t";
	print OUT $rank_models[$i]{"identity"}, "\t";
	print OUT $rank_models[$i]{"blast_evalue"}, "\t";
	print OUT $rank_models[$i]{"reg_clashes"}, "\t";
	print OUT $rank_models[$i]{"ser_clashes"}, "\t";
	print OUT &round($rank_models[$i]{"model_check"}), "\t";
	print OUT &round($rank_models[$i]{"model_energy"}), "\t";
	print OUT &round($rank_models[$i]{"check_rank"}), "\t";
	print OUT &round($rank_models[$i]{"energy_rank"}), "\t";
	print OUT $rank_models[$i]{"average_rank"}, "\n";

	print SCORE $rank_models[$i]{"name"}, " ", $rank_models[$i]{"model_check"}, "\n"; 
}
print SCORE "END\n";
close SCORE;
		
close OUT;


sub round
{
	my $value = $_[0];
	$value = int($value * 100) / 100;
	return $value;
}


#do model refinment and selection (output_dir/cluster and output_dir/refine)

`mkdir $output_dir/refine`;
system("$model_cluster_dir/script/global_local_human_coarse_new.pl $output_dir $fasta_file $output_dir/score $output_dir/refine");

`mkdir $output_dir/cluster`;
system("$model_cluster_dir/script/cluster_comb_only.pl $model_cluster_dir/script /home/chengji/software/spicker/spicker $output_dir $output_dir/score $fasta_file $output_dir/cluster");


`mkdir $output_dir/con`;
system("$model_cluster_dir/script/consensus_global_local.pl $model_cluster_dir/script/ /home/chengji/software/spicker/spicker $output_dir $fasta_file $output_dir/score $output_dir/con");


#set the end time
close PROC;
`date >> $process_id`; 

