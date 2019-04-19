#!/usr/bin/perl -w
###################################################################################################
#rank models by pairwise structure comparison (casp1-5.pdb)
#Date: 5/31/2008
###################################################################################################

#if (@ARGV != 3)
if (@ARGV != 2)
{
	#die "need 3 parameters: tm_score program (~/software/tm_score/TMscore_32), model prefix (casp), model number (5)\n";
	die "need 2 parameters: model prefix (casp), model number (5)\n";
}

#$tm_score_program = shift @ARGV;
$prefix = shift @ARGV;
$model_num = shift @ARGV;

$tm_score_program = "/home/chengji/software/tm_score/TMscore_32";

-f $tm_score_program || die "can't find $tm_score_program.\n";

@ranks_gdt = ();
@ranks_tm = ();

for ($i = 1; $i <= $model_num; $i++)
{
	$target_model = "$prefix$i.pdb";
	if (! -f $target_model)
	{ 
		die "can't find $target_model.\n";
	}

	$total_gdt = 0;
	$total_tm = 0; 

	for ($j = 1; $j <= $model_num; $j++)
	{

		if ($i == $j)
		{
			next;
		}

		$model_file = "$prefix$j.pdb";
		-f $model_file || die "$model_file is not found.\n";
	
		#align the model with the first model		
		#system("$tm_score_program $model_file $target_model -o $fasta_file.sup > $fasta_file.align");
		$align_out = `$tm_score_program $model_file $target_model`;

		@align = split(/\n/, $align_out);

#		print join("\n", @align);


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

	#print $target_model, $total_gdt, "\n";

	push @ranks_gdt, {
		name => $target_model,
		gdt => $total_gdt
	};


	push @ranks_tm, {
		name => $target_model,
		tm => $total_tm
	};
}

print "Ranked by GDT scores: \n";
@sorted_gdt = sort {$b->{"gdt"} <=> $a->{"gdt"}} @ranks_gdt;
for ($i = 0; $i < @sorted_gdt; $i++)
{
	print $sorted_gdt[$i]{"name"}, " ", $sorted_gdt[$i]{"gdt"} / ($model_num-1), "\n";
}
	
print "Ranked by TM scores: \n";
@sorted_tm = sort {$b->{"tm"} <=> $a->{"tm"}} @ranks_tm;
for ($i = 0; $i < @sorted_gdt; $i++)
{
	print $sorted_tm[$i]{"name"}, " ", $sorted_tm[$i]{"tm"} / ($model_num-1), "\n";
}


