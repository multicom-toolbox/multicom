#!/usr/bin/perl -w
################################################################################
#Sort qa scores predicted by deep learning
################################################################################

if (@ARGV != 2)
{
	die "need two parameters: input QA file, output QA file.\n";
}

$input_file = shift @ARGV;
$output_file = shift @ARGV;

open(EVA, $input_file) || die "can't read $input_file.\n";
@eva = <EVA>;
close EVA; 


@model_info = (); 
foreach $record (@eva)
{
	chomp $record;
	@fields = split(/\s+/, $record);
	@fields == 2 || die "the format of $input_file is wrong.\n";				
	$model_name = shift @fields;
	$score = shift @fields; 

	push @model_info, {
                name => $model_name,
                score => $score 
        }

}

#rank all the models by max score
@model_info = sort { $b->{"score"} <=> $a->{"score"}} @model_info; 

$num = @model_info; 

open(OUT, ">$output_file") || die "can't create file $output_file.\n";
for ($i = 0; $i < $num; $i++)
{
	print OUT $model_info[$i]->{"name"}, "\t", $model_info[$i]->{"score"}, "\n";  		
}
close OUT; 




