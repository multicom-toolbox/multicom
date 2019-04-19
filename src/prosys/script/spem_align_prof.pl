#!/usr/bin/perl -w
############################################################################
#use spem to align a fasta file with a pdb file
#Input: prosys_script dir, spem_dir, query_file, pdb file, output pir file
#Output: output pir file
#Author: Jianlin Cheng
#Date: 12/08/2007.
############################################################################

if (@ARGV != 5)
{
	die "need five parameters: script dir, spem dir, query file, pdb file, output pir file.\n";
}

$script_dir = shift @ARGV;
$spem_dir = shift @ARGV;
$query_file = shift @ARGV;
$pdb_file = shift @ARGV;
$out_file = shift @ARGV;

-d $script_dir || die "can't find $script_dir.\n";
-d $spem_dir || die "can't find $spem_dir.\n";
-f $query_file || die "can't find $query_file.\n";
-f $pdb_file || die "can't find $pdb_file.\n";

use Cwd 'abs_path';

$query_file = abs_path($query_file);
$pdb_file = abs_path($pdb_file);
$out_file = abs_path($out_file);

$cur_dir = abs_path(".");

open(FASTA, $query_file);
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
close FASTA;

$tmp_dir = $cur_dir . "/spemtmp";
if (! -d $tmp_dir)
{
	`mkdir $tmp_dir`;
}
chdir $tmp_dir; 

$slash = rindex($pdb_file, "/");
$dot = rindex($pdb_file, ".");
$pdbcode = "xxxx";
if ($slash > 0)
{
	if ($dot > 0)
	{
		$pdbcode = substr($pdb_file, $slash+1, $dot - $slash - 1);
	}
	else
	{
		$pdbcode = substr($pdb_file, $slash+1);
	}
}
else
{
	if ($dot > 0)
	{
		$pdbcode = substr($pdb_file, 0, $dot);
	}
	else
	{
		$pdbcode = $pdb_file;
	}
}


`cp $query_file $name`;
`cp $pdb_file $pdbcode.pdb`; 

#create a temporary file
open(LIST, ">$name.lst");
print LIST $pdbcode;
close LIST;


system("$spem_dir/spem/bin/scan_spem_alone.job $name $name.lst");

$align_file = "$name.aln";
-f $align_file || die "alignment file is not generated.\n";

open(ALIGN, $align_file);
@ali = <ALIGN>;
close ALIGN;

$align1 = "";
$align2 = "";

while (@ali)
{
	$line = shift @ali;
	chomp $line;	

	if ($line =~ /^$pdbcode/)
	{
		@elements = split(/\s+/, $line);
		if ($elements[0] eq $pdbcode)
		{
			$align1 .= $elements[1];
		}
	}

	if ($line =~ /^$name/)
	{
		@elements = split(/\s+/, $line);
		if ($elements[0] eq $name)
		{
			$align2 .= $elements[1];
		}
	}
}

open(OUT, ">$name.glo");
print OUT "1\n1\n";
#query
print OUT "$name\n$align2\n";
#template
print OUT "$pdbcode\n$align1\n";
close OUT;

system("$script_dir/global2pir.pl $name.glo $out_file");

#remove template profiles
`rm s1.* _tmp*`;

chdir $cur_dir;




