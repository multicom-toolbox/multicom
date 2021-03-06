#!/usr/bin/perl -w
##########################################################################
#Evaluate structure models generated by multi-com
#Input: prosys_dir, model dir, output file 
#The following information will be generated:
#model_name, method(cm, fr, ab), top_template name, coverage,
#identity, blast-evalue, svm_score, hhs_score, com_score, 
#ss match score, sa match score, regular clashes, server clashes
#model_check score, model energy score, rank by model_check
#rank by model_energy, average rank
#Author: Jianlin Cheng
#Start date: 1/29/2008
##########################################################################  

sub round
{
	my $value = $_[0];
	$value = int($value * 100) / 100;
	return $value;
}

if (@ARGV != 4)
{
	die "need four parameters: prosys dir, model dir, target name, output file.\n";
}

$prosys_dir = shift @ARGV;
$model_dir = shift @ARGV;
$target_name = shift @ARGV;
$out_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";

#read model check score
$feature_file = "$model_dir/$target_name.mch";
open(MCH, $feature_file) || die "can't read $feature_file\n"; 
@mch = <MCH>;
close MCH;
@pdb2mch = ();
while (@mch)
{
	$line = shift @mch;
	chomp $line;
	($pdb_name, $score) = split(/\s+/, $line);
	$pdb2mch{$pdb_name} = $score;
}

#read model energy
$feature_file = "$model_dir/$target_name.energy";
open(ENERGY, $feature_file) || die "can't read $feature_file\n";
@energy = <ENERGY>;
close ENERGY;
@pdb2energy = ();
while (@energy)
{
	$line = shift @energy;
	chomp $line;
	($pdb_name, $energy) = split(/\s/, $line);
	$pdb2energy{$pdb_name} = $energy;
}

@rank = ();
$rank_file = "$model_dir/$target_name.rank";
open(RANK, $rank_file) || die "can't open $rank_file.\n";
@srank = <RANK>;
close RANK;
shift @srank;
while (@srank)
{
	$line = shift @srank;
	chomp $line;
	@fields = split(/\s+/, $line);
	$rank{$fields[1]} = $fields[2];
}

$svm_file = "$model_dir/$target_name.fsvm";
#hhsearch score
@hhs = ();
#compress
@com = ();
#prc score
@prc = ();
#secondary structure match
@ssm = ();
#solvent acc match
@sam = ();

open(SVM, $svm_file) || die "can't read $svm_file.\n";
while (<SVM>)
{
	$title = $_;
	chomp $title;
	@fields = split(/\s+/, $title);
	$prot = $fields[1];

	$fea = <SVM>;
	chomp $fea;
	@fields = split(/\s+/, $fea);
	@fields == 85 || die "number of features is wrong.\n";

	($hold, $value) = split(/:/, $fields[82]);
	$hhs{$prot} = $value;

	($hold, $value) = split(/:/, $fields[84]);
	$com{$prot} = $value;

	($hold, $value) = split(/:/, $fields[81]);
	$prc{$prot} = $value;

	($hold, $value) = split(/:/, $fields[39]);
	$ssm{$prot} = $value;
	
	($hold, $value) = split(/:/, $fields[40]);
	$sam{$prot} = $value;
}
close SVM;


opendir(MOD, $model_dir) || die "can't read $model_dir.\n";
@files = readdir MOD;
closedir MOD;
@pdb_files = ();
@models = ();
while (@files)
{
	$file = shift @files;
	if ($file =~ /(.+)\.pdb$/)
	{
		$prefix = $1;
	}
	else
	{
		next;
	}
	push @pdb_files, $file;


	if ($file =~ /^cm(\d+)\.pdb/)
	{
		$method = "cm";
	}
	elsif ($file =~ /^ab(\d+)\.pdb/)
	{
		$method = "ab";
	}
	else
	{
		$method = "fr";
	}

	$pir_file = "$model_dir/$prefix.pir";

	if (-f $pir_file)
	{
		open(PIR, $pir_file) || die "can't read $pir_file.\n";
		@pir = <PIR>;
		close PIR;
		if ($method eq "cm")
		{
			$comment = $pir[0];
			@fields = split(/\s+/, $comment);
			$blast_evalue = $fields[11];
		}
		else
		{
			$blast_evalue = "N/A";
		}


		$title = $pir[1];
		chomp $title;
		@fields = split(/;/, $title);
		$temp_name = $fields[1];
		$talign = $pir[3];
		$qalign = $pir[$#pir];

		#get coverage and identity
		chomp $talign;
		chop $talign;

		chomp $qalign;
		chop $qalign;

		$qlen = 0;
		$align_len = 0;
		$coverage = 0;
		$identity = 0;

		$len = length($qalign);
		for ($i = 0; $i < $len; $i++)
		{
			$qaa = substr($qalign, $i, 1);	
			$taa = substr($talign, $i, 1);	

			if ($qaa ne "-")
			{
				$qlen++;
				if ($taa ne "-")
				{
					$align_len++;	
					if ($qaa eq $taa)
					{
						$identity++;
					}
				}
			}
		}

		$coverage = $align_len / $qlen;
		$identity = $identity / $align_len;
	}
	else
	{
		$coverage = "N/A";
		$identity = "N/A";	
	}
	
	if (defined $rank{$temp_name})
	{
		$svm_score = $rank{$temp_name};
	}
	else
	{
		#not found
		$svm_score = "N_F";
	}
	
	if (defined $hhs{$temp_name})
	{
		$hhs_evalue = $hhs{$temp_name};
	}
	else
	{
		#not found
		$hhs_evalue = "N_F";
	}
	
	if (defined $com{$temp_name})
	{
		$com_evalue = $com{$temp_name};
	}
	else
	{
		#not found
		$com_evalue = "N_F";
	}
	
	if (defined $ssm{$temp_name})
	{
		$ssm_score = $ssm{$temp_name};
	}
	else
	{
		#not found
		$ssm_score = "N_F";
	}
	
	if (defined $sam{$temp_name})
	{
		$sam_score = $ssm{$temp_name};
	}
	else
	{
		#not found
		$sam_score = "N_F";
	}
	
	if (defined $pdb2mch{$file})
	{
		$model_check = $pdb2mch{$file};
	}
	else
	{
		#not found
		print "$file model check score is not found.\n";
		$model_check = "0";
	}

	if (defined $pdb2energy{$file})
	{
		$model_energy = $pdb2energy{$file};
	}
	else
	{
		#not found
		print "$file model energy score is not found.\n";
		$model_energy = "10000000";
	}

	#get number of clashes
	$clash = 0;
	$servere = 0;
	$out = `$prosys_dir/script/clash_check.pl $model_dir/$target_name.fasta $model_dir/$file`; 
	if (defined $out)
	{
		@fields = split(/\n/, $out);
		while (@fields)
		{
			$line = shift @fields;
			if ($line =~ /^clash/)
			{
				$clash++;
			}
			if ($line =~ /^servere/ || $line =~ /^overlap/)
			{
				$servere++;
			}
		}
	}
	else
	{
		$clash = 0;
		$servere = 0;
	}

	push @models, {
		name => $file,
		method => $method,
		template => $temp_name,
		coverage => $coverage,
		identity => $identity,
		blast_evalue => $blast_evalue, #valid for comparative models
		svm_score => $svm_score,
		hhs_evalue => $hhs_evalue,
		com_evalue => $com_evalue,
		ssm_score => $ssm_score,
		sam_score => $sam_score,
		reg_clashes => $clash,
		ser_clashes => $servere,
		model_check => $model_check,
		model_energy => $model_energy,
		check_rank => 0, 
		energy_rank => 0,
		average_rank => 0
	} 
			
}

#sort by model check score
@sorted_models = sort {$b->{"model_check"} <=> $a->{"model_check"}} @models;
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

open(OUT, ">$out_file");

#print "name\tmethod\ttemplate\tcoverage\tidentity\tblast_evalue\tsvm_score\thhs_evalue\tcom_evalue\tssm_score\tsam_score\treg_clashes\tser_clashes\tmodel_check\tmodel_energy\tcheck_rank\tenergy_rank\tave_rank\n";
print OUT "name\t\tmethod\ttemp\tcov\tident\tblast_e\tsvm\thhs\tcom\tssm\tsam\tr_cla\ts_cla\tmcheck\tmenergy\t\tcrank\terank\tarank\n";
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
	print $rank_models[$i]{"svm_score"}, "\t";
	print $rank_models[$i]{"hhs_evalue"}, "\t";
	print $rank_models[$i]{"com_evalue"}, "\t";
	print $rank_models[$i]{"ssm_score"}, "\t";
	print $rank_models[$i]{"sam_score"}, "\t";
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
	print OUT &round($rank_models[$i]{"coverage"}), "\t";
	print OUT &round($rank_models[$i]{"identity"}), "\t";
	print OUT $rank_models[$i]{"blast_evalue"}, "\t";
	print OUT &round($rank_models[$i]{"svm_score"}), "\t";
	print OUT &round($rank_models[$i]{"hhs_evalue"}), "\t";
	print OUT &round($rank_models[$i]{"com_evalue"}), "\t";
	print OUT &round($rank_models[$i]{"ssm_score"}), "\t";
	print OUT &round($rank_models[$i]{"sam_score"}), "\t";
	print OUT $rank_models[$i]{"reg_clashes"}, "\t";
	print OUT $rank_models[$i]{"ser_clashes"}, "\t";
	print OUT &round($rank_models[$i]{"model_check"}), "\t";
	print OUT &round($rank_models[$i]{"model_energy"}), "\t";
	print OUT &round($rank_models[$i]{"check_rank"}), "\t";
	print OUT &round($rank_models[$i]{"energy_rank"}), "\t";
	print OUT $rank_models[$i]{"average_rank"}, "\n";
}
		
close OUT;


