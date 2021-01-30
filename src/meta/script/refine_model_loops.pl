#!/usr/bin/perl -w
############################################################################################
#Refine protein model loops using Rosetta 
#or Rosetta Loop Building or Modeller Loop Refinement (?)
#Input five parameters: (1) Refinement script, (2) alignment file (.pir format), 
#(3) original model (.pdb), 
#(4) output model name, (5) simulation number
#Author: Jianlin Cheng
#Start Date: 2/14/2010
#Comments: Maybe good for internal loops. Two ends are fixed. Relatively slow
############################################################################################

if (@ARGV != 5)
{
	die "need five parameters: cheng group dir, alignment file, orignal model file, output directory, simulation number.\n";
}

$MIN_ALIGN_LEN = 30; #minimum valid alignment length
$MIN_AB_LEN = 10; #minimum length used for Rosetta loop refinment

$cheng_dir = shift @ARGV;
-d $cheng_dir || die "can't find $cheng_dir.\n";
$align_file = shift @ARGV;
-f $align_file || die "can't find $align_file.\n";
$model_file = shift @ARGV;
-f $model_file || die "can't find $model_file.\n";
$output_dir = shift @ARGV;
$simulation_num = shift @ARGV;
if ($simulation_num <= 0)
{
	$simulation_num = 100; 
}


#identify unaligned regions for refinement
open(PIR, $align_file) || die "can't find alignment file: $align_file.\n";
@pir = <PIR>;
close PIR; 

@align = ();
while (@pir)
{
	#shift out comments, title, range
	shift @pir;	
	shift @pir;
	shift @pir;
	#get alignment
	$alignment = shift @pir; 
	chomp $alignment;
	chop $alignment; #remove the last *

	#check if the alignment is valid for loop analysis
	$ungap_align = $alignment;
	$ungap_align =~ s/-//g;
	if (length($ungap_align) >= $MIN_ALIGN_LEN)
	{
		push @align, $alignment;
	}

	if (@pir > 0)
	{
		#remove blank line
		shift @pir; 
	}
}

#identify gapped regions (particularly tail regions)
$query_seq = pop @align;
$query_len = length($query_seq); 
@gstart = (); #gap start position
@gend = (); #gap end position
$idx = 0; 

$num = @align;  
$in_gap = 0; 
for ($i = 0; $i < $query_len; $i++)
{
	$aa = substr($query_seq, $i, 1);
	if ($aa eq "-")
	{
		next;
	}	

	$idx++; 	

	#check if the amino acid is matched 
	$found = 0; 
	for ($j = 0; $j < $num; $j++)
	{
		if ( substr($align[$j], $i, 1) ne "-")
		{
			$found = 1; 
			last;
		}	
	}

	if ($found == 0)
	{
		if ($in_gap == 0)
		{
			push @gstart, $idx;	
			$in_gap = 1; 
		}
		if ($idx == $query_len)
		{
			push @gend, $idx; 
		} 
	}
	else
	{
		if ($in_gap == 1)
		{
			push @gend, $idx - 1; 
			$in_gap = 0; 
		}	
	}
}

$nloops = @gstart;
@gstart == @gend || die "numbers of start positions and end positions are not equal.\n";

#enter into output dir and assume the fragment files exist in the directory
#generate loop defintion file

if ($nloops < 1)
{
	die "No loops need to be refined. Stop.\n";
}

#get file name prefix
$idx1 = rindex($model_file, "/");
$idx2 = rindex($model_file, ".");
if ($idx1 >= 0)
{
	if ($idx2 >= 0)
	{
		$model_name = substr($model_file, $idx1+1, $idx2 - $idx1 -1);
	}
	else
	{
		$model_name = substr($model_file, $idx1+1); 
	}
}
else
{
	if ($idx2 >= 0)
	{
		$model_name = substr($model_file, 0, $idx2);
	}
	else
	{
		$model_name = $model_file; 
	}
}

`cp $model_file $output_dir/$model_name.pdb 2>/dev/null`; 

chdir $output_dir;

#create a loop file (including tails, we may need to remove tails)
open(LOOP, ">$model_name.loop") || die "can't create loop file: $model_name.loop\n";
for ($i = 0; $i < $nloops; $i++)
{
	if ($gend[$i] - $gstart[$i] + 1 >= $MIN_AB_LEN)
	{
		
		if ($gend[$i] < $query_len)
		{
			print LOOP "LOOP    $gstart[$i]   $gend[$i]    0\n"; 
			last;
		}
#		else
#		{
#			print LOOP "LOOP    $gstart[$i]";
#			print LOOP "   ", $query_len - 1, "    0\n"; 
#		}
	}	
}
close LOOP; 

#T0446 --- Kic example
#-nstruct 100
#-in::file::fullatom
#-loops::input_pdb inputs/MULTICOM-CLUSTER_TS1
#-loops::loop_file inputs/T0446.loop_file
#-loops::frag_sizes 9 3 1
#-loops::frag_files  inputs/aa0446109_05.200_v1_3 inputs/aa0446103_05.200_v1_3 none
#-loops::ccd_closure
#-loops::random_loop
#-loops::remodel perturb_kic
#-loops::refine refine_kic
#-out::prefix T0446_zheng_kic
#-mute core.io.database

#make fragment files, if necessary
if (! -f "aaMOOKI03_05.200_v1_3" || ! -f "aaMOOKI09_05.200_v1_3" || ! -f "MOOKI.psipred_ss2")
{
	print "The fragment database files do not exist. Start to generate them.\n";
	system("$cheng_dir/bin/gen_fragments.sh $model_name.pdb MOOKI . 2>&1 1>/dev/null"); 
}

#create an kic option file
open(KIC, ">kic_option") || die "can't create kic_option file.\n";
print KIC "-nstruct $simulation_num\n";
print KIC "-in::file::fullatom\n";
print KIC "-loops::input_pdb $model_name.pdb\n";
print KIC "-loops::loop_file $model_name.loop\n"; 
print KIC "-loops::frag_sizes 9 3 1\n";
print KIC "-loops::frag_files aaMOOKI09_05.200_v1_3 aaMOOKI03_05.200_v1_3 none\n";
print KIC "-loops::ccd_closure\n";
print KIC "-loops::random_loop\n";
print KIC "-loops::remodel perturb_kic\n";
print KIC "-loops::refine refine_kic\n";
#print KIC "-in::file::psipred_ss2 MOOKI.psipred_ss2\n";
print KIC "-out::prefix $model_name-kic\n";
print KIC "-mute core.io.database\n";
close KIC; 

#according to Rosetta tutorials, fragment libraries are not needed for KIC loop building. 
#check Zheng how he did KIC loop building on tails
#system("$rosetta_dir/rosetta_source/bin/loopmodel.linuxgccrelease -database $rosetta_dir/rosetta_database -nstruct $simulation_num -in:file:fullatom -loops::input_pdb $model_file -loops:loop_file $model_file.loop -loops::strict_loops -loops::remodel 'perturb_kic' -loops::refine 'refine_kic' -loops::strict_loops -in::file::psipred_ss2 xxxxx_ss2 -loops::frag_sizes 9 3 -loops::frag_files frag9 frag3");


#Zheng's KIC file
#-nstruct 1
#-in::file::fullatom
#-loops::input_pdb inputs/4fxn.start_0001.pdb
#-loops::loop_file inputs/4fxn.loop_file
#-loops::frag_sizes 9 3 1
#-loops::frag_files  inputs/cc4fxn_09_05.200_v1_3.gz inputs/cc4fxn_03_05.200_v1_3.gz none
#-loops::ccd_closure
#-loops::random_loop
#-loops::refine refine_kic
#-out::prefix 4fxn_zheng_kic
#-mute core.io.database

#Zheng's CCD file
#-nstruct 50
#-in::file::fullatom
#-loops::input_pdb inputs/4fxn.start_0001.pdb
#-loops::loop_file inputs/4fxn.loop_file
#-loops::frag_sizes 9 3 1
#-loops::frag_files  inputs/cc4fxn_09_05.200_v1_3.gz inputs/cc4fxn_03_05.200_v1_3.gz none
#-loops::ccd_closure
#-loops::random_loop
#-loops::refine refine_ccd
#-out::prefix 4fxn_zheng_ccd
#-mute core.io.database

#T0446 --- Kic example
#-nstruct 100
#-in::file::fullatom
#-loops::input_pdb inputs/MULTICOM-CLUSTER_TS1
#-loops::loop_file inputs/T0446.loop_file
#-loops::frag_sizes 9 3 1
#-loops::frag_files  inputs/aa0446109_05.200_v1_3 inputs/aa0446103_05.200_v1_3 none
#-loops::ccd_closure
#-loops::random_loop
#-loops::remodel perturb_kic
#-loops::refine refine_kic
#-out::prefix T0446_zheng_kic
#-mute core.io.database


print "Start to refine loops...\n";
system("$cheng_dir/rosetta3.1/rosetta_source/bin/loopmodel.linuxgccrelease \@kic_option -database $cheng_dir/rosetta3.1/rosetta_database/"); 
