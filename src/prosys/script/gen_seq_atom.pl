#!/usr/bin/perl -w
###############################################################################
#Generate sequence file, atom file from dssp and pdb file
#Input: script dir, pdb dir, dssp dir, seq output dir, atom output dir,
#original dssp seqeunce set, adjusted set(collection of all generated seqs)
#Author: Jianlin Cheng
#Date: 3/27/2005
###############################################################################

if (@ARGV != 7)
{
	die "need seven parameters: script dir, pdb dir, dssp dir, seq out dir, atom output dir, dssp seq set, adjusted seq set.\n";
}

$script_dir = shift @ARGV;
$pdb_dir = shift @ARGV;
$dssp_dir = shift @ARGV;
$seq_out_dir = shift @ARGV;
$atom_out_dir = shift @ARGV;
$dssp_set = shift @ARGV;
$seq_set = shift @ARGV;

#opendir(PDB_DIR, "$pdb_dir") || die "can't read pdb dir:$pdb_dir\n";
#@pdb_list = readdir(PDB_DIR);
#closedir(PDB_DIR);
opendir(DSSP_DIR, "$dssp_dir") || die "can't read dssp dir:$dssp_dir\n";
@dssp_list = readdir(DSSP_DIR);
closedir(DSSP_DIR);

open(DSSP_SET, ">$dssp_set") || die "can't create dssp set.\n";
open(SEQ_SET, ">$seq_set") || die "can't create seq set.\n";

while(@dssp_list)
{
	$file = shift @dssp_list;
	if ($file eq "." || $file eq "..") {next;};
	#check if it is dssp file
	if ($file !~ /dssp/) {next;};
	print "\nprocess $file\n";
	$temp_file = $file;

	$file = "$dssp_dir/$file";

	if ($file =~ /.*pdb.*dssp\.gz$/) #zip dssp file
	{
		`cp $file $temp_file`;
		 $pos = rindex($temp_file, ".");
		 $prefix = substr($temp_file, 0,$pos);
		 `gunzip -f $temp_file`;

	}
	elsif ($file =~ /.*pdb.*dssp$/)
	{
		`cp $file $temp_file`;
		$prefix = $temp_file;
	}

	#copy the corresponding pdb file here
	print "prefix of dssp file: $prefix\n";
	$pos = rindex($prefix, ".");
	#print "pos: $pos\n";
	$pdb_prefix = substr($prefix, 0,$pos);
	$pdb_prefix = $pdb_dir . "/" . $pdb_prefix;
	if ( ! -f $pdb_prefix)
	{
		$org_prefix = $pdb_prefix;
		$pdb_prefix .= ".Z";
		if (! -f $pdb_prefix)
		{
			$pdb_prefix = "$org_prefix.gz";
		}
	}
	print "pdb file: $pdb_prefix\n";
	if (! -f $pdb_prefix)
	{
		
		print "can't find pdb file for dssp file: $file\n";  
		`rm $prefix`;
	}

	if ( -f "$dssp_set.org")
	{
		`rm $dssp_set.org`; 
	}

	#print("$script_dir/pdb_dssp2set_atom.pl $script_dir $pdb_prefix $prefix $dssp_set.org");
	#<STDIN>;


	#process the file
	system("$script_dir/pdb_dssp2set_atom_new.pl $script_dir $pdb_prefix $prefix $dssp_set.org");

	#post process the results
	#1. copy the dssp set into whole dssp set
	#2. copy new seqs into  the whole seqs set
	#3. move atom file into atom dir
	#4. move seq file into seq dir

	#remove the temporaray dssp file
	`rm $prefix`;

	if (!open(ORG, "$dssp_set.org"))
	{
		print "can't create sequence and atom file for dssp file: $file.\n";
		next; 
	}

	@content = <ORG>;
	close ORG;
	`rm $dssp_set.org`;

	while (@content)
	{
		$name = shift @content;
	#	print "chain name: $name\n";
	#	<STDIN>;
		print DSSP_SET $name;
		$resolution = shift @content;
		print DSSP_SET $resolution;
		$length = shift @content;
		print DSSP_SET $length;
		$seq = shift @content;
		print DSSP_SET $seq;
		$mapping = shift @content;
		print DSSP_SET $mapping;
		$ss = shift @content;
		print DSSP_SET $ss;
		$bp1 = shift @content;
		print DSSP_SET $bp1;
		$bp2 = shift @content;
		print DSSP_SET $bp2;
		$sa = shift @content;
		print DSSP_SET $sa;
		$xyz = shift @content;
		print DSSP_SET $xyz;
		$blank = shift @content;
		print DSSP_SET $blank;

		#read sequence file	
		chomp $name;
		if (! open(NEW, "$name.seq"))
		{
		  print "can't read new sequence file, $name.seq\n";
		  next; 
		}
		@info = <NEW>;
		close NEW;
		print SEQ_SET join("", @info);

		#move seq file and atom file
		`mv $name.seq $seq_out_dir`;
		`mv $name.atom $atom_out_dir`; 
		#zip the atom file
		`gzip -f $atom_out_dir/$name.atom`;

	}
}

close DSSP_SET;
close SEQ_SET;


