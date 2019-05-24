#!/usr/bin/perl -w
#######################################################################
#Use both template-based contacts and dncon contacts to build models
#######################################################################

$TIME_OUT_FREQUENCY = 60;

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, common output dir(full_length dir).\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

-f $fasta_file || die "can't find $fasta_file.\n";

#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

$output_dir = $work_dir . "/confoldtemp/";
`mkdir $output_dir 2>/dev/null`; 
`cp $fasta_file $output_dir 2>/dev/null`; 
`cp $option_file $output_dir 2>/dev/null`; 
chdir $output_dir; 

#check if the other two required directories exist

$construct_dir = $work_dir . "/construct/";
-d $construct_dir || die "construct directory: $construct_dir does not exist. Please run construct first before running confoldtemp.\n";

$confold_dir = $work_dir . "/confold/";
-d $confold_dir || die "confold directory: $confold_dir does not exist. Please run confold first before running confoldtemp.\n";

open(FASTA, $fasta_file);
$query_name = <FASTA>;
chomp $query_name;
$query_name = substr($query_name, 1); 
close FASTA;

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#take only filename from fasta file
$pos = rindex($option_file, "/");
if ($pos >= 0)
{
	$option_file = substr($option_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";

$prosys_dir = "";

#time out in seconds 
$wait_time = 18000; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^confoldtemp_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$confoldtemp_program = $value; 
		-f $confoldtemp_program || die "can't find $confoldtemp_program.\n";
	}

	if ($line =~ /^final_model_number/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$final_model_number = $value; 
	}

	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^wait_time/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$wait_time = $value; 
	}

}

-d $prosys_dir || die "can't find $prosys_dir.\n";
-f $confoldtemp_program || die "can't find $confoldtemp_program.\n";

$wait_time >= $TIME_OUT_FREQUENCY || die "time out is too short.\n";



$rounds = int($wait_time / $TIME_OUT_FREQUENCY); 
$count = 0; 

#if template rank file ready
$is_rank_ready = 0; 
$rank_file = $construct_dir . "/construct.rank";

#if secondary structure prediction ready
$is_ss_ready = 0; 
$ss_file = $confold_dir . "/dncon2/ss_sa/$query_name.ss";

#if contact prediction ready
$is_rr_ready = 0; 
$rr_file = $confold_dir . "/dncon2/$query_name.dncon2.rr";


#wait for three files to be generated for a limited amount of time
while ($count < $rounds)
{
	#sleep one minute
	print "confoldtemp waits for 60 seconds...\n";
	sleep($TIME_OUT_FREQUENCY);

	print "check the existence of $rank_file, $ss_file, and $rr_file.\n";

	if (-f $rank_file)
	{
		$is_rank_ready = 1; 
	}	
	if (-f $ss_file)
	{
		$is_ss_ready = 1; 
	}
	if (-f $rr_file)
	{
		$is_rr_ready = 1; 
	}

	$count++; 
	if ($is_rank_ready == 1 && $is_ss_ready == 1 && $is_rr_ready == 1)
	{
		print "rank, ss, and rr files are ready!\n";
		last;
	}
}
sleep($TIME_OUT_FREQUENCY);


if ($is_rank_ready == 0 || $is_ss_ready == 0 || $is_rr_ready == 0)
{
	die "rank, ss, or rr files do not eixst. Stop confoldtemp model generation.\n";
}

print "Run confoldtemp to generate models from template-based contacts and DNCON2 contacts...\n";

system("$confoldtemp_program $query_name $fasta_file $work_dir $output_dir $rr_file $ss_file");

for ($i = 1; $i <= $final_model_number; $i++)
{
	$output_model = "$output_dir/confoldpro-$i.pdb";
	if (-f $output_model)
	{
		`mv $output_model $output_prefix_name$i.pdb`; 
		print "A model $output_prefix_name$i.pdb is generated.\n";
	}

}

print "confoldtemp prediction is finished.\n";
