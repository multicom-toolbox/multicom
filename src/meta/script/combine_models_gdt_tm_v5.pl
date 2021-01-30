#!/usr/bin/perl -w
##############################################################################
#Inputs:meta dir, model dir, ranked dashboard file, query/target fasta file, 
#       output dir.
#Author: Jianlin Cheng
#if the pairwise tm-score of the top model is >=0.2, using pairwise ranking.
#Otherwise, use SBROD ranking. 
#Re-design: Feb. 5, 2020 
##############################################################################

if (@ARGV != 6)
{
	die "need six parameters: multicom option file, meta dir, model dir, dashboard score file, query/target fasta file, output dir.\n";
}

$option_file = shift @ARGV; 
-f $option_file || die "can't find $option_file.\n";

$meta_dir = shift @ARGV;

$model_dir = shift @ARGV;
-d $model_dir || die "can't find model dir: $model_dir.\n";

$dash_file = shift @ARGV;
-f $dash_file || die "can't find dashboard file: $dash_file.\n";

$fasta_file = shift @ARGV;
open(FASTA, $fasta_file) || die "can't find $fasta_file.\n";
$target_name = <FASTA>;
close FASTA;
chomp $target_name;
$target_name = substr($target_name, 1);
#$target_name = shift @ARGV;

$output_dir = shift @ARGV;
-d $output_dir || `mkdir $output_dir`; 

#read dashboard file
open(DASH, $dash_file) || die "can't find $dash_file.\n";
@dash = <DASH>;
close DASH; 
shift @dash; 

$max_tm = 0; 
foreach $record (@dash)
{
	#fields: Name(0),Method(1),Temp(2),Freq(3),Ident(4),Cov(5),Evalue(6),max(7),gdt(8),tm(9),rcla(10),scla(11)
	@fields = split(/\s+/, $record);
	if ($fields[1] eq "No" && $fields[2] eq "alignment" && $fields[3] eq "information")
	{
		push @rank, {
			name => "$fields[0].pdb",
			method => "ab_initio",
			template => "unknown",
			frequency => 0,
			identity => 0,
			coverage => 0,
			evalue => "unknown",
			max => $fields[4],
			gdt => $fields[5],
			tm => $fields[6],
			rclash => $fields[7],
			sclash => $fields[8],
			sbrod => $fields[9],
			drank => $fields[10],
			AveRank => $fields[11],
			cluster => $fields[14]

		}; 
		if ($fields[6] > $max_tm)
		{
			$max_tm = $fields[6]; 
		}
	
	}
	else
	{	
		push @rank, {
			name => "$fields[0].pdb",
			method => $fields[1],
			template => $fields[2],
			frequency => $fields[3],
			identity => $fields[4],
			coverage => $fields[5],
			evalue => $fields[6],
			max => $fields[7],
			gdt => $fields[8],
			tm => $fields[9],
			rclash => $fields[10],
			sclash => $fields[11],
			sbrod => $fields[12],
			drank => $fields[13],
			AveRank => $fields[14], 
			cluster => $fields[17]
		}; 
		if ($fields[9] > $max_tm)
		{
			$max_tm = $fields[9]; 
		}
	}

}

#sort by different criteria 
@rank = sort {$b->{"coverage"} <=> $a->{"coverage"}} @rank;
@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
@rank = sort {$b->{"sbrod"} <=> $a->{"sbrod"}} @rank;
@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;

$use_sbrod = 0; 
if ($max_tm < 0.2)  #tm score of the top model is too low, using sbrod ranking
{
	print "tm_score of the top one model is too low, using SBROD score to rank models\n";
	@rank = sort {$b->{"sbrod"} <=> $a->{"sbrod"}} @rank;
	$use_sbrod = 1; 
}

#select models considering cluster information
@cluster_rank = (); 
@non_cluster_rank = ();

#representative of top three clusters
@top_three = ();
@non_top_three = (); 

for ($i = 0; $i < @rank; $i++)
{
	$cluster_num = $rank[$i]->{"cluster"};
	$cluster_representative = 1;
	for ($j = 0; $j < @cluster_rank; $j++)
	{
		if ($cluster_num == $cluster_rank[$j]->{"cluster"})
		{
			$cluster_representative = 0; 
		}
	}
	if ($cluster_representative == 1)
	{
		push @cluster_rank, $rank[$i]; 
	}
	else
	{
		push @non_cluster_rank, $rank[$i]; 
	}

	if ($cluster_representative == 1 && @top_three < 3)
	{
		push @top_three, $rank[$i]; 
	}
	else
	{
		push @non_top_three, $rank[$i]; 
	}
}

#create a new ranking list
@new_rank = ();
push @new_rank, @top_three;
push @new_rank, @non_top_three; 


open(OUT, ">$output_dir/consensus.eva");

open(SCORE, ">$output_dir/score");
print SCORE "PFRMAT QA\n";
print SCORE "TARGET \n";
print SCORE "MODEL \n";
print SCORE "QMODE \n";

printf(OUT "%-25s%-10s%-9s%-5s%-6s%-6s%-10s%-6s%-6s%-6s%-6s%-6s%-8s%-8s%-8s%-8s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "rcla", "scla", "sbrod", "drank", "AveRank", "cluster");
for ($i = 0; $i < @new_rank; $i++)
{

	printf(OUT "%-25s",  $new_rank[$i]->{"name"});  		
	printf(OUT "%-10s",  $new_rank[$i]->{"method"});  		
	printf(OUT "%-9s",  $new_rank[$i]->{"template"});  		
	printf(OUT "%-5s",  $new_rank[$i]->{"frequency"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"identity"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"coverage"});  		
	printf(OUT "%-10s",  $new_rank[$i]->{"evalue"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"max"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"gdt"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"tm"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"rclash"});  		
	printf(OUT "%-6s",  $new_rank[$i]->{"sclash"});  		
	printf(OUT "%-8s",  $new_rank[$i]->{"sbrod"});  		
	printf(OUT "%-8s",  $new_rank[$i]->{"drank"});  		
	printf(OUT "%-8s",  $new_rank[$i]->{"AveRank"});  		
	printf(OUT "%-8s\n",  $new_rank[$i]->{"cluster"});  		

	if ($use_sbrod == 0)
	{
		print SCORE $new_rank[$i]->{"name"}, " ", $new_rank[$i]->{"tm"}, "\n"; 
	}
	else
	{
		print SCORE $new_rank[$i]->{"name"}, " ", $new_rank[$i]->{"sbrod"}, "\n"; 
	}


	#copy pir alignment file for analysis
	if ($i < 5)
	{
		$align_name = $new_rank[$i]->{"name"}; 
		if ($align_name =~ /(.+)\.pdb$/)
		{
			$align_name = $1; 
		}		
		$pir_file = "$model_dir/$align_name.pir";
		if (-f $pir_file)
		{
			`cp $pir_file $output_dir`; 
		}
	}
}
print SCORE "END\n";
close SCORE;
close OUT;


#do model refinment and selection (output_dir/cluster and output_dir/refine)
system("$meta_dir/script/global_local_human_coarse_new_v2.pl $option_file $meta_dir $model_dir $fasta_file $output_dir/score $output_dir");

