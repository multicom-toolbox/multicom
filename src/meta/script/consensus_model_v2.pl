#!/usr/bin/perl -w
###########################################
#Generate the consensus models of five ranking lists
#Input: prediction output dir, target name, output sub directory (consensus)
if (@ARGV != 3)
{
	die "need three parameters: prediction dir to store all predictions (e.g. /home/casp11/T0700), target name (T0700), output subdirectory name (e.g. consensus)\n";
} 

$target_dir = shift @ARGV;
$target_name = shift @ARGV;
$consensus_name = shift @ARGV;

-d $target_dir || die "hybrid: $target_dir doesn't exist.\n";

$tm_score_program = "/home/jh7x3/multicom_beta1.0/tools/tm_score/TMscore_32";
-f $tm_score_program || die "can't find $tm_score_program.\n";


use Cwd 'abs_path';
$target_dir = abs_path($target_dir);


$model_dir = "$target_dir/full_length/meta";
-d $model_dir || die "hybrid: $model_dir doesn't exist.\n";

$consensus_dir = "$target_dir/$consensus_name";
`mkdir $consensus_dir`; 

#@rank_files = ("$target_dir/full_length.dash", "$target_dir/select/multi_level.eva", "$target_dir/cluster/$target_name.iqa", "$target_dir/compo/compoa.eva", "$target_dir/compo/compob.eva");
@rank_files = ("$target_dir/full_length.dash", "$target_dir/select/multi_level.eva", "$target_dir/cluster/$target_name.iqa", "$target_dir/compo/compoa.eva", "$target_dir/compo/compob.eva", "$target_dir/mcomb/consensus2.eva");

#check if the rank files  exists

foreach $rank_file (@rank_files)
{
	-f $rank_file || die "$rank_file doesn't exist. not consenus model is generated.\n";
	`cp $rank_file $consensus_dir`; 
}

#select five consensus models
@final_list = ();

open(FINAL, ">$consensus_dir/rank.final") || die "can't create rank.final.\n";

chdir $consensus_dir;
for ($i = 1; $i <= 5; $i++)
{
	$selection_dir = "$consensus_dir/model$i";
	`mkdir $selection_dir`; 	

	#copy server models to the selection dir	

	@model_list = ();
	$count = 0;
	foreach $rank_file (@rank_files)
	{
		$count++; 
		if ($rank_file !~ /iqa/)
		{
			open(RANK, $rank_file) || die "can't read $rank_file.\n";	
			@rank = <RANK>;
			close RANK;
			$model_info = $rank[$i];		
			@fields = split(/\s+/, $model_info);
			$model_name = $fields[0];
			if ($model_name =~ /(.+)\.pdb/)
			{	
				$model_file = "$model_dir/$1.pdb";
				
			}
			else
			{
				$model_file = "$model_dir/$model_name.pdb";
			}
			-f $model_file || die "can't find $model_file in consensus ranking\n";
			`cp $model_file $selection_dir/$model_name-$i-$count.pdb`; 
			push @model_list, "$selection_dir/$model_name-$i-$count.pdb";	
		
		}
		else
		{
			open(RANK, $rank_file) || die "can't read $rank_file.\n";	
			@rank = <RANK>;
			close RANK;
			shift @rank; shift @rank; shift @rank;		
			$model_info = $rank[$i];		
			@fields = split(/\s+/, $model_info);
			$model_info = $fields[0];
		
			if ($model_info =~ /(.+)\.pdb$/)
			{
				$model_name = $1;
			}
			else
			{
				die "fail to parse $model_info\n";
			}

			$model_file = "$model_dir/$model_name.pdb";
			-f $model_file || die "can't find $model_file in consensus ranking\n";
			`cp $model_file $selection_dir/$model_name-$i-$count.pdb`; 
			push @model_list, "$selection_dir/$model_name-$i-$count.pdb";	
				
		}

	}	

	#generate a consensus ranking of models in the selection directory
	
	$model_num =  @model_list;
	@ranks_gdt = ();

	for ($k = 0; $k < $model_num; $k++)
	{
		$target_model = $model_list[$k];
		print "selected model in iteration $i: $target_model\n";
		if (! -f $target_model)
		{ 
			die "can't find $target_model.\n";
		}

		$total_gdt = 0;
		$total_tm = 0; 

		for ($j = 0; $j < $model_num; $j++)
		{

			if ($k == $j)
			{
				next;
			}

			$model_file = $model_list[$j];
			-f $model_file || die "$model_file is not found.\n";
	
			#align the model with the first model		
			$align_out = `$tm_score_program $model_file $target_model`;

			@align = split(/\n/, $align_out);



			while (@align)
			{
				$line = shift @align;
				chomp $line;
				if ($line =~ /^Number\s+of\s+residues\s+in\s+common=\s+(\d+)/)
				{
				#$align_length = $1;
				}
				if ($line =~ /^RMSD\s+of\s+the\s+common\s+residues=\s+([\d.]+)/)
				{
					#$rmsd_common = $1; 
				}
				if ($line =~ /^TM-score\s+=\s+([\d.]+)\s+/)
				{
					$tm_score = $1;
				}
				if ($line =~ /^MaxSub-score=\s+([\d.]+)\s+/)
				{
					#$max_sub = $1;
				}
				if ($line =~ /^GDT-score\s+=\s+([\d.]+)\s+/)
				{
					$gdt_ts = $1; 
				}
		
			}

			$total_gdt += $gdt_ts;
			$total_tm += $tm_score;

		}


		push @ranks_gdt, {
			name => $target_model,
			gdt => $total_gdt
		};


	}

	@sorted_gdt = sort {$b->{"gdt"} <=> $a->{"gdt"}} @ranks_gdt;

	#get the final list	
	push @final_list, $sorted_gdt[0]{"name"};
	print "Final model $i: ",  $sorted_gdt[0]{"name"}, " score = ", $sorted_gdt[0]{"gdt"} / 5,  "\n"; 
	print FINAL $sorted_gdt[0]{"name"}, " score = ", $sorted_gdt[0]{"gdt"} / 5,  "\n"; 
	#$pdb2casp2 = "/home/casp13/MULTICOM_package//casp8/meta/script/pdb2casp.pl";
	$pdb2casp2 = "/home/jh7x3/multicom_beta1.0/src/meta/script/pdb2casp.pl";

	$model_file = $sorted_gdt[0]{"name"}; 

	if ($model_file =~ /\/meta_(.+)\.pdb$/)
	{
		$model_name = "meta_$1"; 
		#print "$model_name\n";
	}
	if (-f $model_file)
	{
		#system("/home/casp13/MULTICOM_package//software/scwrl4/Scwrl4 -i $model_file -o $consensus_dir/$model_name-$i.pdb.scw >/dev/null");
		system("/home/jh7x3/multicom_beta1.0/tools/scwrl4/Scwrl4 -i $model_file -o $consensus_dir/$model_name-$i.pdb.scw >/dev/null");
		
		
		#system("/home/casp13/MULTICOM_package//casp8/model_cluster/script/clash_check.pl $model_dir/$target_name.FASTA $consensus_dir/$model_name-$i.pdb.scw > $consensus_dir/clash$i.txt");
		system("/home/jh7x3/multicom_beta1.0/src/meta/model_cluster/script/clash_check.pl $model_dir/$target_name.FASTA $consensus_dir/$model_name-$i.pdb.scw > $consensus_dir/clash$i.txt");
		system("$pdb2casp2 $consensus_dir/$model_name-$i.pdb.scw $i $target_name $consensus_dir/casp$i.pdb");	
	}
	else
	{
		die "$model_file doesn't exist.\n";
	}
}

close FINAL;


  


