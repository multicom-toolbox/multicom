#!/usr/bin/perl -w
#########################################################################
#generate ab initio models using Rosetta
#Inputs: rosetta dir, fasta file, number of simulations, output dir
#Output: models (cluster centers) 
#Author: Jianlin Cheng
#Start: 1/22/2008
#########################################################################

if (@ARGV != 5)
{
	die "need five parameters: rosetta dir, fasta file, number of simulations, random seed, output dir.\n"; 
}

$rosetta_dir = shift @ARGV;
$fasta_file = shift @ARGV;
$sim_num = shift @ARGV;
$seed = shift @ARGV;
$out_dir = shift @ARGV;

$abinitio_dir = "$rosetta_dir/RosettaAbinitio/scripts/bin";
$fragment_dir = "$rosetta_dir/rosetta_fragments";

-d $abinitio_dir || die "can't find rosetta script dir.\n";
-d $fragment_dir || die "can't find rosetta fragment dir.\n";
$sim_num >= 50 || die "number of simulations must be greater than 50.\n";
-d $out_dir || die "can't find $out_dir.\n";

use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);

chdir $out_dir;

#generate fragment files for the targets
open(FASTA, $fasta_file) || die "can't open $fasta_file.\n";
$name = <FASTA>;
$seq = <FASTA>;
close FASTA;

chomp $name;
$name = substr($name, 1);
chomp $seq;

$pseudo_name = "T0000";
#create a temporary file for fragment creation
open(ROS, ">$pseudo_name.fasta");
print ROS ">$pseudo_name\n";
for ($i = 0; $i < length($seq); $i++)
{
	print ROS substr($seq, $i, 1);
	if ( ($i+1) % 60 == 0)
	{
		print ROS "\n";
	}	
}
if ( ($i+1) % 60 != 0)
{
	print ROS "\n";
}
close ROS;

print "generate fragments for $name...\n";
system("$fragment_dir/make_fragments.pl -nojufo -nosam $pseudo_name.fasta >frag.log 2>&1");

if (-f "aaT000003_05.200_v1_3")
{
	`mv aaT000003_05.200_v1_3 aaT000_03_05.200_v1_3`;
	`mv aaT000009_05.200_v1_3 aaT000_09_05.200_v1_3`;
	print "fragments for $name are generated.\n";
}
else
{
	die "fail to generate fragment files for $name.\n";
}

$cur_dir = `pwd`;
chomp $cur_dir;

$cur_dir .= "/";

open(PATH, ">paths.txt");
print PATH "Rosetta Input/Output Paths (order essential)\n";
print PATH "path is first \'/\', \'./\',or \'../\' to next whitespace, must end with /\n";
print PATH "INPUT PATHS:\n";
print PATH "pdb1\t$cur_dir\n";
print PATH "pdb2\t$cur_dir\n";
print PATH "pdb3\t$cur_dir\n";
print PATH "fragments\t$cur_dir\n";
print PATH "structure\t$cur_dir\n";
print PATH "sequence\t$cur_dir\n";
print PATH "constraints\t$cur_dir\n";
print PATH "starting structure\t$cur_dir\n";
print PATH "data files\t$rosetta_dir/rosetta_scripts/abinitio/bin/../../../rosetta_database/\n";
print PATH "OUTPUT PATHS:\n";
print PATH "movie\t$cur_dir\n";
print PATH "pdb\t$cur_dir\n";
print PATH "score\t$cur_dir\n";
print PATH "status\t$cur_dir\n";
print PATH "user\t$cur_dir\n";

print PATH "FRAGMENTS:\n";
print PATH "2  number of fragment files\n";
print PATH "3  file 1 size\n";
print PATH "aa*****03_05.200_v1_3\n";
print PATH "9  file 2 size\n";
print PATH "aa*****09_05.200_v1_3\n";
close PATH;

`cp $pseudo_name.fasta T000_.fasta`;

#generate movies
print "Rosetta simulating models...\n";
system("$abinitio_dir/rosettaAB.pl -binary $rosetta_dir/RosettaAbinitio/source/rosetta.gcc -fasta $pseudo_name.fasta -nstruct $sim_num -outdir ./ -verbose -additional_args \"-constant_seed -jran $seed\" >ab.log 2>&1");
print "Rosetta simulation is done.\n";

print "Rosetta clustering decoys...\n";
system("$abinitio_dir/cluster.pl -silentfile aaT000.out >clu.log 2>&1");
print "Rosetta clustering is done.\n";

#get the center of each cluster
open(CLUSTER, "aaT000.out.clusters") || die "can't read cluster file.\n";
@cluster = <CLUSTER>;
close CLUSTER;

shift @cluster; shift @cluster;

open(LIST, ">aaT000.list");

@decoys = ();
while (@cluster)
{
	$line = shift @cluster;
	if ($line eq "\n")
	{
		last;
	}
	if ($line =~ /: \d+,(\S+) /)
	{
		push @decoys, $1;
		print LIST "$1\n";
	}
	else
	{
		die "cluster centroid format error.\n";
	}
}
close LIST;

system("$abinitio_dir/extract.pl -binary $rosetta_dir/RosettaAbinitio/source/rosetta.gcc aaT000.out aaT000.list >ext.log 2>&1");

$idx = 1;
foreach $decoy (@decoys)
{
	if (-f "${decoy}_0001.pdb")
	{
		print "Rosetta ab initio model $idx is created.\n";
		`mv ${decoy}_0001.pdb ab$idx.pdb`;
	
		#reformat the pdb file
		open(AB, "ab$idx.pdb"); 
		@ab = <AB>;
		close AB;
		open(AB, ">ab$idx.pdb"); 
		while (@ab)
		{
			$line = shift @ab;
			if ($line =~ /^ATOM/)
			{
				$left = substr($line, 0, 21);
				$right = substr($line, 22);
				$record = "$left $right";
				print AB $record;
			}
		}		

		close AB;

		$idx++;
	}
}


