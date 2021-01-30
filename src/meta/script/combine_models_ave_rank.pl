#!/usr/bin/perl -w
##############################################################################
#Inputs:meta dir, model dir, ranked dashboard file, query/target fasta file, 
#       output dir.
#Author: Jianlin Cheng
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
			ave => $fields[11]	
		}; 
	
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
			ave => $fields[14]	
		}; 
	}

}

#sort by different criteria 
@rank = sort {$b->{"coverage"} <=> $a->{"coverage"}} @rank;
@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;
@rank = sort {$a->{"ave"} <=> $b->{"ave"}} @rank;

open(OUT, ">$output_dir/average_rank.eva");

open(SCORE, ">$output_dir/ave_score");
print SCORE "PFRMAT QA\n";
print SCORE "TARGET \n";
print SCORE "MODEL \n";
print SCORE "QMODE \n";

printf(OUT "%-25s%-10s%-9s%-5s%-6s%-6s%-10s%-6s%-6s%-6s%-6s%-6s%-8s%-8s%-8s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "rcla", "scla", "sbrod", "drank", "AveRank");
for ($i = 0; $i < @rank; $i++)
{

	printf(OUT "%-25s",  $rank[$i]->{"name"});  		
	printf(OUT "%-10s",  $rank[$i]->{"method"});  		
	printf(OUT "%-9s",  $rank[$i]->{"template"});  		
	printf(OUT "%-5s",  $rank[$i]->{"frequency"});  		
	printf(OUT "%-6s",  $rank[$i]->{"identity"});  		
	printf(OUT "%-6s",  $rank[$i]->{"coverage"});  		
	printf(OUT "%-10s",  $rank[$i]->{"evalue"});  		
	printf(OUT "%-6s",  $rank[$i]->{"max"});  		
	printf(OUT "%-6s",  $rank[$i]->{"gdt"});  		
	printf(OUT "%-6s",  $rank[$i]->{"tm"});  		
	printf(OUT "%-6s",  $rank[$i]->{"rclash"});  		
	printf(OUT "%-6s",  $rank[$i]->{"sclash"});  		
	printf(OUT "%-8s",  $rank[$i]->{"sbrod"});  		
	printf(OUT "%-8s",  $rank[$i]->{"drank"});  		
	printf(OUT "%-8s\n",  $rank[$i]->{"ave"});  		

	print SCORE $rank[$i]->{"name"}, " ", $rank[$i]->{"ave"}, "\n"; 


	#copy pir alignment file for analysis and copy/covert models
	if ($i < 5)
	{
		$align_name = $rank[$i]->{"name"}; 

		#copy the model
		$count = $i + 1; 
		`cp $model_dir/$align_name $output_dir/ave$count-$align_name`;
		system("$meta_dir/script/clash_check.pl $fasta_file $output_dir/ave$count-$align_name > $output_dir/ave$count-clash.txt");
        	system("$meta_dir/script/pdb2casp.pl $output_dir/ave$count-$align_name $count $target_name $output_dir/ave$count-casp.pdb");

		if ($align_name =~ /(.+)\.pdb$/)
		{
			$align_name = $1; 
		}		
		$pir_file = "$model_dir/$align_name.pir";
		if (-f $pir_file)
		{
			`cp $pir_file $output_dir/ave$count-casp.pir`; 
		}
	}
}
print SCORE "END\n";
close SCORE;
close OUT;


#do model refinment and selection (output_dir/cluster and output_dir/refine)
#system("$meta_dir/script/global_local_human_coarse_new_v2.pl $option_file $meta_dir $model_dir $fasta_file $output_dir/ave_score $output_dir");

