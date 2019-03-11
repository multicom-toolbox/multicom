#!/usr/bin/perl -w

##########################################################################
#DO EASIEST HOMOLOGY MODELING USING BLASTP, NO ALIGNMENT COMBINATION
#Author: Jianlin Cheng
#Date: 6/17/2006
#################################################################

###########################################################################
#get the exponent of evalue
#if evalue is 0, the exponent is set to -1000
#if no exponent exists, the exponent is set to 0.
sub get_exponent 
{
	my $a = $_[0];
	#print "evalue: $a\n";
	$exponent = 0;

	#get the format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		if ($a <= 0) #evalue is 0
		{
			$exponent = -1000; 
		}
		else
		{
			$exponent = 0; 
		}
	}
	elsif ($a =~ /^([\d]*)e(-\d+)$/)
	{
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
		if ($a_next >= 0)
		{
			die "exponent must be negative: $a\n"; 
		}
		$exponent = $a_next; 
	}
	else
	{
		die "evalue format error: $a";	
	}
	return $exponent; 
}
########################End of compare evalue################################

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

use Cwd 'abs_path';
$option_file = abs_path($option_file);

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$atom_dir = "";
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

$adv_comb_join_max_size = -1; 

$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "yes";
$rm_identical_resolution = 2;

$cm_clean_redundant_align = "no";

$cm_evalue_diff = 1000; 
$output_prefix_name = "psiblast";

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	}
	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}
	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}
	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_align_evalue = $value; 
	}
	if ($line =~ /^cm_max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_gap_size = $value; 
	}
	if ($line =~ /^cm_min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_min_cover_size = $value; 
	}
	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}
	if ($line =~ /^easy_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$easy_model_num = $value; 
	}
	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^cm_max_linker_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_linker_size = $value; 
	}

	if ($line =~ /^cm_evalue_comb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_comb = $value; 
	}

	if ($line =~ /^cm_comb_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_comb_method = $value; 
	}

	if ($line =~ /^adv_comb_join_max_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$adv_comb_join_max_size = $value; 
	}

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_blast_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_align = $value; 
	}

	if ($line =~ /^sort_blast_local_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_ratio = $value; 
	}

	if ($line =~ /^sort_blast_local_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_delta_resolution = $value; 
	}

	#if ($line =~ /^add_stx_info_rm_identical/)
	#{
	#	($other, $value) = split(/=/, $line);
	#	$value =~ s/\s//g; 
	#	$add_stx_info_rm_identical = $value; 
	#}

	if ($line =~ /^rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rm_identical_resolution = $value; 
	}

	if ($line =~ /^cm_clean_redundant_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_clean_redundant_align = $value; 
	}

	if ($line =~ /^cm_evalue_diff/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_diff = $value; 
	}
}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $meta_common_dir || die "can't find meta_common dir.\n";

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


-f "$pdb_db_dir/pdb_cm.phr" || die "can't find the pdb database.\n"; 

#try to identify easy template using blastp
system("$script_dir/easy_psiblast.pl $option_file $fasta_file $fasta_file.blast"); 

#parse the blast output
print "parse blast output...\n"; 
system("$script_dir/cm_parse_blast.pl $fasta_file.blast $fasta_file.easy.local");
open(LOCAL, "$fasta_file.easy.local") || die "can't read the parsed output results.\n"; 
@local = <LOCAL>;
close LOCAL;
if (@local <= 2)
{
	die "no significant easy templates are found. stop.\n";
}

if ($sort_blast_align eq "yes")
{
	print "resort blast local alignments according to structure information.\n";
	system("$script_dir/sort_blast_local.pl $fasta_file.easy.local $chain_stx_info $sort_blast_local_ratio $sort_blast_local_delta_resolution $fasta_file.local.sort");
	`mv $fasta_file.easy.local $fasta_file.local.nosort`;
	`mv $fasta_file.local.sort $fasta_file.easy.local`; 
}

#analyze and improve local alignments
$align_option = "$meta_common_dir/script/align_option";
-f $align_option || die "can't find alignment option file: $align_option.\n";
system("$meta_common_dir/script/local_global_align.pl $align_option $fasta_file.easy.local $fasta_file $fasta_file"); 
-f "$fasta_file.local.ext" || die "can't find extended local alignment file: $fasta_file.local.ext\n";

print "generate PIR alignments...\n";
#convert local alignments into a pir msa.

system("$script_dir/easy_align_more.pl $script_dir $fasta_file $fasta_file.local.ext $cm_min_cover_size $cm_max_gap_size $cm_max_linker_size $cm_evalue_comb $adv_comb_join_max_size $cm_evalue_diff $fasta_file.easy");  

#add structure information to pir alignment (always) 
if ($add_stx_info_rm_identical eq "yes")
{

	print "Add structural information to blast pir alignments.\n";
	for ($i = 1; $i <= $easy_model_num; $i++)
	{
		if (-f "$fasta_file.easy$i.pir")
		{
			system("$script_dir/pir_proc_resolution.pl $fasta_file.easy$i.pir $chain_stx_info $rm_identical_resolution $fasta_file.easy$i.pir.stx");
		}
		if (-f "$fasta_file.easy$i.pir.stx")
		{
		#	`mv $fasta_file.easy$i.pir $fasta_file.easy$i.pir.nostx`;
			`mv $fasta_file.easy$i.pir.stx $fasta_file.easy$i.pir`; 
		}
	}

}

for ($idx = 1; $idx <= $easy_model_num; $idx++)
{

	if ( ! -f "$fasta_file.easy$idx.pir")
	{
		next; 
	}

	open(PIR, "$fasta_file.easy$idx.pir") || die "can't generate pir file from local alignments.\n";
	@pir = <PIR>;
	close PIR; 
	if (@pir <= 4)
	{
		die "no pir alignments are generated from target: $name\n"; 
	}

	$align_info = $pir[0];
	@fields = split(/\s+/, $align_info);
	$evalue = $fields[11];
	$exponent = &get_exponent($evalue);	

	$cover_info = $pir[5];
	@fields = split(/\s+/, $cover_info);
	$cover = $fields[2];
	@fields = split(/:/, $cover);
	$ratio = $fields[1];

	$reso_info = $pir[2];
	@fields = split(/:/, $reso_info);
	$reso = $fields[8];

	#compute corrected cover ratio
	$seqa = $pir[3];
	chomp $seqa;
	$seqb = $pir[8];
	chomp $seqb;
	$length = length($seqb);
	$total = 0;
	$match = 0;
	for ($i = 0; $i < $length; $i++)
	{
		$resb = substr($seqb, $i, 1);
		$resa = substr($seqa, $i, 1);
		if ($resb ne "-" && $resb ne "*")
		{
			$total++;
			if ($resa ne "-" && $resa ne "*")
			{
				$match++;
			}
		}
	}
	$correct_ratio = $match / $total;


	#check the condition:
	#resolution < 2.5, 2. evalue < -90, coverage > 0.85 for easiest templates
	print "evalue = $evalue, coverage = $correct_ratio ($ratio), resolution = $reso\n";
	print "Use Modeller to generate tertiary structures...\n"; 
	`cp $fasta_file.easy$idx.pir $output_prefix_name$idx.pir`; 
	system("$script_dir/pir2ts_energy.pl $modeller_dir $atom_dir $work_dir $output_prefix_name$idx.pir $cm_model_num");

	`mv model.log $fasta_file.log`; 
	if (-f "$name.pdb")
	{
		`mv $name.pdb $output_prefix_name$idx.pdb`;
	}


}
