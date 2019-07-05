#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using raptorx
#Inputs: option file, fasta file, output dir.
#Outputs: raptorx output file, pir alignment file, pdb models 
#Author: Jianlin Cheng
#Date: 4/9/2014
##########################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

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

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
$pos = rindex($option_file, "/");
if ($pos > 0)
{
	$option_file = substr($option_file, $pos+1); 
}
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$blast_dir = "";
$modeller_program = "";
$raptorx_dir = "";
$atom_dir = "";
#initialized with default values
$cm_model_num = 5; 
$meta_dir = ""; #raptorx main program

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	#	print "$script_dir\n";
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
		$script_dir = "$prosys_dir/script";
	#	print "$script_dir\n";
	}

	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^modeller_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_program = $value; 
	}
	if ($line =~ /^raptorx_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$raptorx_dir = $value; 
	}


	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}


	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-f $modeller_program || die "can't find $modeller_program.\n";
-d $raptorx_dir || die "can't find hhsearch dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $pdb_db_dir || die "can't find $pdb_db_dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $meta_common_dir || die "can't find $meta_common_dir.\n";


#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}

$query_length = length($seq);


print "Generate models using raptorx...\n";
use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);
#print("$raptorx_dir/runRaptorX.pl $fasta_file $work_dir $raptorx_dir $modeller_program $name $cm_model_num\n"); 

#system("$raptorx_dir/runRaptorX.pl $fasta_file $work_dir $raptorx_dir $modeller_program $name $cm_model_num"); 

### link the software to output folder 

chdir $work_dir; 

if(-d "$work_dir/Raptorx")
{
	`rm $work_dir/Raptorx/*`;
}else{
	`mkdir $work_dir/Raptorx`;
}


`ln -s $raptorx_dir/buildFeature $work_dir/Raptorx/buildFeature`;
`ln -s $raptorx_dir/build3Dmodel $work_dir/Raptorx/build3Dmodel`;
`ln -s $raptorx_dir/buildTopModels $work_dir/Raptorx/buildTopModels`;
`ln -s $raptorx_dir/CNFalign_lite $work_dir/Raptorx/CNFalign_lite`;
`ln -s $raptorx_dir/CNFsearch $work_dir/Raptorx/CNFsearch`;
`ln -s $raptorx_dir/runRaptorX.pl $work_dir/Raptorx/runRaptorX.pl`;
`ln -s $raptorx_dir/databases $work_dir/Raptorx/databases`;
`ln -s $raptorx_dir/TGT $work_dir/Raptorx/TGT`;
`ln -s $raptorx_dir/setup.pl $work_dir/Raptorx/setup.pl`;

`mkdir $work_dir/Raptorx/tmp`;
`cp -ar  $raptorx_dir/util $work_dir/Raptorx/`;

chdir("$work_dir/Raptorx/");
`perl setup.pl`;

chdir($work_dir);
system("$raptorx_dir/runRaptorX.pl $fasta_file $work_dir $work_dir/Raptorx $modeller_program $name $cm_model_num"); 

`rm $work_dir/Raptorx/*`;
`rm -rf $work_dir/Raptorx/util`;

############Process template ranking file################

#$rank_file = "$work_dir/$name-70.rank";
$rank_file = "$work_dir/$name.rank";
open(RANK, $rank_file) || die "can't read $rank_file.\n";
@rank = <RANK>;
close RANK;

open(RFILE, ">$work_dir/$name.rank") || die "can't create $work_dir/name.rank.\n";
print RFILE "Ranked templates\n";

@template_list = (); 
@template_list_up = (); 
@pvalues = (); 
while (@rank)
{
	$rank_line = shift @rank;
	if ($rank_line =~ /^No   Template/)
	{
		for ($i = 1; $i <= $cm_model_num; $i++)
		{
			$template_line = shift @rank;
			@fields = (); 
			($rank_no, $template_id, $pvalue, @fields) = split(/\s+/, $template_line);
			if ($rank_no >= $i)
			{
				push @template_list, $template_id;
				$id_upper = uc($template_id);
				push @template_list_up, $id_upper;
				push @pvalues, $pvalue;
				print RFILE "$rank_no $id_upper $pvalue\n";
			}
		}
		last;	
				
	}

}
close RFILE;


############Process pdb and alignment files#################################
for ($i = 0; $i < @template_list; $i++)
{
	$num = $i + 1; 
	$tid = $template_list[$i]; 	
	$pdb_file = "${tid}_$name.B99990001.pdb";
	$align_file = "${tid}-$name.fasta";
	$pvalue = $pvalues[$i]; 
#	print "ls $pdb_file $align_file\n";
	if (-f $pdb_file && -f $align_file)
	{
		`cp $pdb_file $output_prefix_name$num.pdb`; 
	
		#get alignments	
		open(ALIGN, $align_file) || die "can't read $align_file\n";
		@align = <ALIGN>;	
		shift @align;
		$temp_align = shift @align;
		shift @align;
		shift @align;
		shift @align;
		
		$target_align = shift @align;

		chomp $target_align;
		chomp $temp_align;
			
		length($temp_align) == length($target_align) || die "template alignment length is not equal to target aignment length ($tid, $name)\n";

	
		
		#get length
		$trimed_temp_align = $temp_align;
		$trimed_temp_align =~ s/-//g;
		$temp_length = length($trimed_temp_align);

		$trimed_target_align = $target_align;
		$trimed_target_align =~ s/-//g;
		$target_length = length($trimed_target_align);

#		print "$trimed_target_align\n";

		$target_length == $query_length || die "$align_file: the length of the target in the input file is not equal to the length in the raptorx alignment file ($target_length, $query_length).\n";

		open(PIR, ">$output_prefix_name$num.pir") || die "can't create $output_prefix_name$num.pir\n";
		$utid = uc($tid);
		print PIR "C;cover size:0; local alignment length=0 (original info = $utid 0 0 $pvalue 0)\n";	
		print PIR ">P1;", $utid, "\n";

		print PIR "structureN:$utid: 1: : $temp_length: : : :6.0:\n";
		print PIR "$temp_align*\n";
		print PIR "\n";
		
		print PIR "C;query_length:$target_length\n";
		print PIR ">P1;", $name, "\n";
		print PIR " : : : : : : : : :\n";
		print PIR "$target_align*\n";

		close PIR; 
	}	
}

$rank_file = "$work_dir/$name.rank";
if (! -f $rank_file)
{
	open(RANK, ">$rank_file") || die "can't create $rank_file\n";; 
	print RANK "RaptorX failed, this is an empty rank file.\n";
	close RANK;
}

print "Raptorx prediction is finished.\n";


