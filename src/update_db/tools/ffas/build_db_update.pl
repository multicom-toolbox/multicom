#!/usr/bin/perl -w
#################################################################
#create and continuously update the ffas database
#Author: Jianlin Cheng
#Date: 11/21/2011
#################################################################

#library dir
$library_dir = "/home/jh7x3/multicom_beta1.0/databases/library";
$input_file = "/home/jh7x3/multicom_beta1.0/databases/fr_lib/sort90";
$output_db = "/home/jh7x3/multicom_beta1.0/databases/ffas_dbs/multicom_db/multicom_ffas_db";
$db_profile_list = "/home/jh7x3/multicom_beta1.0/databases/ffas_dbs/multicom_db/profile_list"; 
$ffas_dir = "/home/jh7x3/multicom_beta1.0/src/update_db/tools/ffas/";

if (! -f $output_db)
{
	`>$output_db`; 
}

if (! -f $db_profile_list)
{
	`>$db_profile_list`; 
}
else
{
	#read the list of profiles	
	open(LIST, $db_profile_list) || die "can't read $db_profile_list\n";
	while ($profile_id = <LIST>)
	{
		chomp $profile_id; 
		push @profile_list, $profile_id; 
	}
	close LIST; 
}

open(LIB, $input_file) || die "can't read $input_file.\n";
@lib = <LIB>;
close LIB;

$count = 0; 
while (@lib)
{
	$name = shift @lib;
	chomp $name;
	$name = substr($name, 1);

	print "process $name\n";
	shift @lib;

	#check if the name is in the list
	$found = 0; 	
	foreach $prof_id (@profile_list)
	{
		if ($name eq $prof_id)
		{
			$found = 1; 
		}			
	}
	if ($found == 1)
	{
		next; 
	}
	push @profile_list, $name; 

	$msa_file = "$library_dir/$name.fas"; 	

	#convert msa into ffas msa format
	open(MU, ">$name.ffas.mu");

	open(MSA, $msa_file) || die "can't open $msa_file\n";
	@msa = <MSA>;
	close MSA; 

	$title = shift @msa;
	$t_sequence = shift @msa;
	print MU ">$title$t_sequence";		
	chomp $t_sequence;

	while (@msa)
	{
		$title = shift @msa;
		$title = substr($title, 1);
		$sequence = shift @msa;	
		chomp $sequence;

		if ($sequence eq $t_sequence)
		{
			next;
		}

		print MU ">   1e-10 >gi|1|ref|YP|$title";

		#shrink gaps at both ends		
		$start_pos = 1;
		$end_pos = length($t_sequence);			
		
		for ($i = 0; $i < $end_pos; $i++)
		{
			if (substr($sequence, $i, 1) eq "-")
			{
				$start_pos++; 
			}
		}	
		for ($i = $end_pos - 1; $i > 0; $i--)
		{
			if (substr($sequence, $i, 1) eq "-")
			{
				$end_pos--; 
			}	
		}
		
		$t_sub_seq = substr($t_sequence, $start_pos - 1, $end_pos - $start_pos + 1);
		$o_sub_seq = substr($sequence, $start_pos - 1, $end_pos - $start_pos + 1);

		$str = "$start_pos";
		$len = length($str);
		for ($j = 0; $j < 6 - $len; $j++)
		{
			$str = " " . $str;
		}
		print MU "$str $t_sub_seq\n";
		print MU "     1 $o_sub_seq\n";	

	}
	print MU ">*\n";
	close MU;

	#convert msa into profiles
	`$ffas_dir/profile.sh $name.ffas.mu $output_db`; 
	`rm $name.ffas.mu`; 

	$count++; 
}

open(LIST, ">$db_profile_list") || die "can't write $db_profile_list\n";
print LIST join("\n", @profile_list); 
close LIST; 

print "total number of new ffas profiles is $count.\n";

