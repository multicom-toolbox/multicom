#!/usr/bin/perl -w
#######################################################################
#Cluster a banch of models ranked by model_check or model_energy
#get closet model to the centroid of each cluster
#use closet model as start point to build a combined model using
#global and local alignments
#Input: spicker program, psi-pred dir, model dir file, model rank file
#FASTA sequence, output dir
#Date: 11/15/2007.
#Author: Jianlin Cheng
#######################################################################

if (@ARGV != 6)
{
	die "need six parameters: model cluster script dir, spicker program, model dir file, model rank file (ave ranking score file), FASTA sequence, and output file.\n";
}

$cluster_dir = shift @ARGV;
use Cwd 'abs_path';
$cluster_dir = abs_path($cluster_dir);

$spicker = shift @ARGV;
$model_dir = shift @ARGV;
$model_rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$output_file = shift @ARGV;

$out_dir = "$output_file.dir";
mkdir $out_dir;

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

$cur_dir = `pwd`;
chomp $cur_dir;

chdir $out_dir;

open(RANK, $model_rank_file) || die "can't open $model_rank_file.\n";
@rank = <RANK>;
close RANK;

shift @rank; shift @rank; shift @rank; shift @rank; 
pop @rank;

$record = $rank[0];
chomp $record;
@fields = split(/\s+/, $record);
$highest_score = $fields[1]; 

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
for ($i = 1; $i <= 1; $i++)
{
	if (-f "closc$i.pdb")
	{

		#identify the model
		$model_name = "";
		foreach $model (@selected_models)
		{
			$model_file = "$model_dir/$model";
			#$out = `/home/casp13/MULTICOM_package/software/tm_score/TMscore_32 $model_file closc$i.pdb`;
			$out = `/home/jh7x3/multicom_beta1.0/tools/tm_score/TMscore_32 $model_file closc$i.pdb`;
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

$title1 = shift @rank; 
$title2 = shift @rank; 
$title3 = shift @rank; 
$title4 = shift @rank; 

$found = 0;
$target_model = "";
@tmp = ();
@new_rank = ();
foreach $record (@rank)
{
	if ($record =~ /^$close_models[0]/)
	{
		$found = 1;	
		$target_model = $record;
	}
	else
	{
		push @tmp, $record;
	}
}
if ($found == 1)
{
	push @new_rank, $target_model;
}
push @new_rank, @tmp;

#align each model with top five models
#$tm_score_program = "/home/casp13/MULTICOM_package/software/tm_score/TMscore_32 ";
$tm_score_program = "/home/jh7x3/multicom_beta1.0/tools/tm_score/TMscore_32 ";

@model_scores = ();

opendir(MODEL, $model_dir) || die "can't open $model_dir.\n";
@model_files = readdir MODEL;
closedir MODEL;

sub round
{
	my $value = $_[0];
	$value = int($value * 100 + 0.5);	
	$value /= 100;
	return $value;
}

#for ($i = 0; $i < @new_rank; $i++)
for ($i = 0; $i < @model_files; $i++)
{
	$record = $model_files[$i];
	@fields = split(/\s+/, $record);
	$model_name = $fields[0]; 
	if ($model_name eq "." || $model_name eq "..")
	{
		next;
	}
	$model_file = "$model_dir/$model_name";
	-f $model_file || next;

	$crappy = 0; 
	#check if it is a crappy model
	open(MOD, $model_file);
	while (<MOD>)
	{
		if (/^PARENT\s+/)
		{
			$crappy++; 
		}
	}
	close MOD;
	if ($crappy >= 2)
	{
		next;
	}

	print "handle $model_name...\n";

	#align this model with top 5 models to get average GDT-TS score
	$ave_gdt = 0;
	$count = 0; 
	@local_rmsd = ();
	for ($k = 0; $k < $slen; $k++)
	{
		$local_rmsd[$k] = 0; 	
	}

	$bad = 0; 
	for ($j = 0; $j < 5 && $j < @new_rank; $j++)
	{	
		$record = $new_rank[$j];
		@fields = split(/\s+/, $record);
		$model_name0 = $fields[0]; 
		$model_file0 = "$model_dir/$model_name0";


		#align the model with the first model		

		#system("$tm_score_program $model_file0 $model_file -o $fasta_file.sup > $fasta_file.align");
		system("$tm_score_program $model_file $model_file0 -o $fasta_file.sup > $fasta_file.align");

		open(ALIGN, "$fasta_file.align") || die "can't open tm_score alignment file.\n";	
		@align = <ALIGN>;
		close ALIGN;
		`rm $fasta_file.align`; 

		while (@align)
		{
			$line = shift @align;
			chomp $line;
		#	if ($line =~ /^Number\s+of\s+residues\s+in\s+common=\s+(\d+)/)
		#	{
		#		$align_length = $1;
		#	}
		#	if ($line =~ /^RMSD\s+of\s+the\s+common\s+residues=\s+([\d.]+)/)
		#	{
		#		$rmsd_common = $1; 
		#	}
		#	if ($line =~ /^TM-score\s+=\s+([\d.]+)\s+/)
		#	{
		#		$tm_score = $1;
		#	}
		#	if ($line =~ /^MaxSub-score=\s+([\d.]+)\s+/)
		#	{
		#		$max_sub = $1;
		#	}
			if ($line =~ /^GDT-score\s+=\s+([\d.]+)\s+/)
			{
				$gdt_ts = $1; 
				$ave_gdt += $gdt_ts;
				$count++; 
				last;
			}
		
		}

		if (! -f "$fasta_file.sup")
		{
			$bad = 1; 
			last;
		};

		open(SUP, "$fasta_file.sup") || die "can't read $fasta_file.sup\n";
		@sup = <SUP>;
		close SUP;
		`rm $fasta_file.sup`; 
		$ter = 0;
		%sup_model = ();
		%sup_target = ();
		while (@sup)
		{
			$line = shift @sup;
			if ($line =~ /^TER/)
			{
				$ter = 1; 
			}
			if ($line =~ /^ATOM.+CA\s+/)
			{
				$pos = substr($line, 22, 4);		
				$pos =~ s/\s//g;
				if ($ter == 0)
				{
					$sup_model{$pos} = $line;
				#	print "$pos\n";
				}
				else
				{
					$sup_target{$pos} = $line;
				}
			}
		}

		#generate RMSD
		for ($k = 0; $k < $slen; $k++)
		{
			$pos = $k + 1; 	
			if (exists $sup_model{$pos} && $local_rmsd[$k] >= 0)
			{
				$line1 = $sup_model{$pos};
				$x1 = substr($line1, 30, 8);
				$x1 =~ s/\s//g;
				$y1 = substr($line1, 38, 8);
				$y1 =~ s/\s//g;
				$z1 = substr($line1, 46, 8);
				$z1 =~ s/\s//g;

				$line2 = $sup_target{$pos}; 
				$x2 = substr($line2, 30, 8);
				$x2 =~ s/\s//g;
				$y2 = substr($line2, 38, 8);
				$y2 =~ s/\s//g;
				$z2 = substr($line2, 46, 8);
				$z2 =~ s/\s//g;

				$dist = sqrt( ($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2) );
				$local_rmsd[$k] += $dist;	
			}		
			else
			{
				$local_rmsd[$k] = -1;
			}
		}	
		
	}

	if ($bad == 1)
	{
		next;
	}

	@rmsd_str = ();
	for ($k = 0; $k < $slen; $k++)
	{
		$local_rmsd[$k] /= $count;
		if ($local_rmsd[$k] >= 0)
		{
			push @rmsd_str, &round($local_rmsd[$k]);
		}
		else
		{
			push @rmsd_str, "X";
		}
	}
	#generate rmsd_str
	$rmsd_str = "";
	for ($k = 0; $k < $slen; $k++)
	{
		$rmsd_str .= $rmsd_str[$k];	
		if ($k == $slen - 1)
		{
			$rmsd_str .= "\n";
		} 
		else
		{
			if ( $k!= 0 && ($k % 15) == 0)
			{
				$rmsd_str .= "\n";
			}		
			else
			{
				$rmsd_str .= " ";
			}
		}
	}

	#$rmsd_str = join(" ", @rmsd_str);

	$ave_gdt /= $count; 
	
	#calculate local scores for each residues

	#print "$model_name gdt-ts = $ave_gdt\n";
#	print "$model_name adjust-gdt = ", $ave_gdt * $highest_score, "\n";
	push @model_scores, {
		name => $model_name,
		gdt => $ave_gdt, 
		adjust_gdt => $ave_gdt * $highest_score,
		rmsd => $rmsd_str
	};
}


@sorted_model_scores = sort {$b->{"gdt"} <=> $a->{"gdt"}} @model_scores; 

chdir $cur_dir;

open(OUT, ">$output_file") || die "can't create $output_file.\n";
print OUT "$title1$title2$title3$title4";
for ($i = 0; $i < @sorted_model_scores; $i++)
{
#	print $sorted_model_scores[$i]{"name"};	
	print OUT $sorted_model_scores[$i]{"name"};	
#	print " ";
	print OUT " ";
#	print $sorted_model_scores[$i]{"gdt"};	
	print OUT $sorted_model_scores[$i]{"gdt"};	
	print OUT "\n";
}  
print OUT "END\n";
close OUT; 


`rm -r $out_dir`; 

