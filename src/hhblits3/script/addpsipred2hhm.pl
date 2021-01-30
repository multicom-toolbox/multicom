#!/usr/bin/perl -w
##################################################################
#Add predicted psi-pred secondary structure into HHSearch HMM model
#Input: psipred horiz file, HHM model name
#Output: to std: a new HMM with SS info.
#Author: Jianlin Cheng
#Date: 10/10/2007
##################################################################

if (@ARGV != 2)
{
	die "need two parameters: psipred horiz file, hhsearch HMM model file.\n";
}

$horiz_file = shift @ARGV;
$hhm_file = shift @ARGV;

open(SEQ, $horiz_file) || die "can't read $horiz_file.\n";
$ss_pred = "";
$ss_conf = "";
while ($line = <SEQ>)
{
	if ($line =~ /^Conf:\s+(\d+)/)
	{
		$ss_conf .= $1;
	} 
	elsif ($line =~ /^Pred:\s+(\S+)/)
	{
		$ss_pred .= $1;
	}
	
}

length($ss_conf) == length($ss_pred) || die "sequence length is not equal to confidence length.\n";

open(HHM, $hhm_file) || die "can't read $hhm_file.\n";
@hhm = <HHM>;
close HHM;

while (@hhm)
{
	$line = shift @hhm;
	print $line;
	if ($line =~ /^SEQ/)
	{
		#get length of secondary structure	
		$len = length($ss_pred);			

		print ">ss_pred\n";
		for ($i = 1; $i <= $len; $i++)
		{
			print substr($ss_pred, $i-1, 1);
			if ($i % 100 == 0 || $i == $len)
			{
				print "\n";
			}
		}

		print ">ss_conf\n";
		for ($i = 1; $i <= $len; $i++)
		{
			print substr($ss_conf, $i-1, 1);
			if ($i % 100 == 0 || $i == $len)
			{
				print "\n";
			}
		}

	}	
}

