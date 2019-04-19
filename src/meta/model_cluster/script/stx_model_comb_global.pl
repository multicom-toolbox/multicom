#!/usr/bin/perl -w
###################################################################################################
#Combine fragments of multiple models of the same protein
#this is a global model combination algorithm 
#try to combine core regions
#Basic idea: central star algorithm. take new models 
#that are close to the top model. the overall GDT-TS score is also taken into account
#the overall predicted GDT-TS score may be taken into account as well.
#Input: tm_score program, model_dir, model_rank_list_file, fasta_file, output file, RMSD threshold
# and mininum score (0.5) 
#Output: a pir file with structure alignment information
#Author: Jianlin Cheng
#Date: 11/18/2007
###################################################################################################

##############standard Amino Acids (3 letter <-> 1 letter)#######
%amino=();
$amino{"ALA"} = 'A';
$amino{"CYS"} = 'C';
$amino{"ASP"} = 'D';
$amino{"GLU"} = 'E';
$amino{"PHE"} = 'F';
$amino{"GLY"} = 'G';
$amino{"HIS"} = 'H';
$amino{"ILE"} = 'I';
$amino{"LYS"} = 'K';
$amino{"LEU"} = 'L';
$amino{"MET"} = 'M';
$amino{"ASN"} = 'N';
$amino{"PRO"} = 'P';
$amino{"GLN"} = 'Q';
$amino{"ARG"} = 'R';
$amino{"SER"} = 'S';
$amino{"THR"} = 'T';
$amino{"VAL"} = 'V';
$amino{"TRP"} = 'W';
$amino{"TYR"} = 'Y';
###################################################################
#some special mapping used by Zhang
$amino{"MSE"} = 'M';


if (@ARGV != 8)
{
	die "need 8 parameters: tm_score program, model_dir, model_rank_file, fasta_file, output file, rmsd threshold (2), min_align_percentage (0.8 <-> 80%), minimum gdt ts score (0.5).\n";
}

$tm_score_program = shift @ARGV;
$model_dir = shift @ARGV;
$rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$out_file = shift @ARGV;
$rmsd_thresh = shift @ARGV;
$min_ratio = shift @ARGV;
#mininum gdt-ts score to combine
$min_score = shift @ARGV;

-f $tm_score_program || die "can't find $tm_score_program.\n";
-d $model_dir || die "can't find $model_dir.\n";
-f $rank_file || die "can't find $rank_file.\n";
-f $fasta_file || die "can't find $fasta_file.\n";
$rmsd_thresh >= 0 && $rmsd_thresh <= 4 || die "RMSD must in in [0,4]\n";
$min_score > 0 || die "minimum score of model must > 0.\n";
$min_ratio > 0.7 || die "fragment length must > 0.7.\n";

open(FASTA, $fasta_file) || die "can't find $fasta_file.\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>;
close FASTA;
chomp $seq;

$seq_len = length($seq);

open(RANK, $rank_file) || die "can't open $rank_file.\n";
@rank = <RANK>;
close RANK;


$first = 1;

#record fragments to be combined
@model_names = ();
@fstart = ();
@fend = ();

@tm_scores = ();
@gdt_scores = ();
@maxsub_scores = ();
@eva_scores = ();

@target_ca = ();
@target_x  = ();
@target_y  = ();
@target_z  = ();

$max_num = @rank - 7;

$count = 1;
while (@rank)
{
	$line = shift @rank;
	chomp $line;
	if ($line =~ /^PFRMAT / || $line =~ /^TARGET / || $line =~ /^MODEL / || $line =~ /^QMODE / || $line =~ /^END/ || $line =~ /^AUTHOR/ || $line =~ /^METHOD/)
	{
		next;
	}	

	if ($line =~ /ABIpro/ || $line =~ /3Dpro/)
	{
		#skip ABIpro and 3Dpro models
		next;
	}

	if (@rank <= $max_num / 2)
	{
		#only take the first half
		last;
	}
	
	($model, $score) = split(/\s+/, $line);	
	$model_file = "$model_dir/$model";
	if (! -f $model_file)
	{ 
		warn "can't find $model_file.\n";
		next;
	}
	if ($first == 1)
	{
		$first = 0;
		$first_model = $model_file;

		#read the amino acid sequence and x, y, z coordinates from the model file
		open(MODEL, $model_file) || die "cannot read $model_file.\n"; 
		@model = <MODEL>;
		close MODEL;
	
		while (@model)
		{
			$line = shift @model;
			if ($line =~ /^ATOM/)
			{
				$res = substr($line, 17, 3);
				$res = uc($res);
				$res =~ s/\s+//g;
				if (exists($amino{$res}))
				{
					$res = $amino{$res};
				}
				else
				{
					print "Amino acid $res is unknown.\n";
					$res = "X";
				}
				
				$type = substr($line, 12, 4);	
				$xc = substr($line, 30, 8);
       		                $xc =~ s/\s//g;
				$yc = substr($line, 38, 8);
               		        $yc =~ s/\s//g;
               		        $zc = substr($line, 46, 8);
                       		$zc =~ s/\s//g;
				if ($type =~/CA/)
				{
					push @target_ca, $res;
					push @target_x, $xc;
					push @target_y, $yc;
					push @target_z, $zc;
				}
			}	
		}

		$seq eq join("", @target_ca) || die "the sequence does not match with the first model.\n";
		push @model_names, $model;
		push @fstart, 0;
		push @fend, length($seq) - 1; 

		push @tm_scores, 1;
		push @gdt_scores, 1;
		push @maxsub_scores, 1; 
		push @eva_scores, $score;

		next;
	}
	
	#align the model with the first model		
	system("$tm_score_program $model_file $first_model -o $fasta_file.sup > $fasta_file.align");

	open(ALIGN, "$fasta_file.align") || die "can't open tm_score alignment file.\n";	
	@align = <ALIGN>;
	close ALIGN;
	`rm $fasta_file.align`; 

	while (@align)
	{
		$line = shift @align;
		chomp $line;
		if ($line =~ /^Number\s+of\s+residues\s+in\s+common=\s+(\d+)/)
		{
			$align_length = $1;
		}
		if ($line =~ /^RMSD\s+of\s+the\s+common\s+residues=\s+([\d.]+)/)
		{
			$rmsd_common = $1; 
		}
		if ($line =~ /^TM-score\s+=\s+([\d.]+)\s+/)
		{
			$tm_score = $1;
		}
		if ($line =~ /^MaxSub-score=\s+([\d.]+)\s+/)
		{
			$max_sub = $1;
		}
		if ($line =~ /^GDT-score\s+=\s+([\d.]+)\s+/)
		{
			$gdt_ts = $1; 
		}
		
	}
	if ($gdt_ts < $min_score)
	{
		#no similar topology, skip the model
	#	print "GDT-TS = $gdt_ts, too small\n";
		
		next; 
	}
	#print "GDT-TS = $gdt_ts, to combine\n";

	`rm $fasta_file.sup`; 
	if ($rmsd_common < $rmsd_thresh && $align_length / $seq_len > $min_ratio)
	{
		push @model_names, $model;
		push @fstart, 0;
		push @fend, $seq_len - 1;
		push @tm_scores, $tm_score;
		push @maxsub_scores, $max_sub;
		push @gdt_scores, $gdt_ts;
		push @eva_scores, $score;
			
		$count++;
	}

	if ($count == 20)
	{
		#at most combine 20 models
		last;
	}

}

#convert fragment to PIR alignments
open(MSA, ">$out_file") || die "can't create $out_file.\n";


$len = length($seq);

$id = 1;
$total = @model_names;

print "combine $total models.\n";
while (@model_names)
{
	$model = shift @model_names;
	$start = shift @fstart;	
	$end   = shift @fend;
	$tm_score = shift @tm_scores;
	$gdt_score = shift @gdt_scores;
	$maxsub    = shift @maxsub_scores;
	$score     = shift @eva_scores;

	print MSA "C; model_eva_score=$score, tm_score=$tm_score, gdt_score=$gdt_score, maxsub=$maxsub.\n";		
	print MSA ">P1;$model$id\n";
	print MSA "structureX:";
	print MSA $model;
	print MSA ": ", $start + 1, ": :";
	print MSA " ", $end + 1, ": :";
	print MSA " : : : \n";
	
	for ($i = 0; $i < $len; $i++)
	{
		if ($start <= $i && $i <= $end)
		{
			print MSA $target_ca[$i];
		}	
		else
		{
			print MSA "-";
		}
	}
	print MSA "*\n\n";
}

print MSA "C;total number of template models = $total\n";
print MSA ">P1;$name\n";
print MSA " : : : : : : : : : \n";
print MSA "$seq*\n";
close MSA; 


