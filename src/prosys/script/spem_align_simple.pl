#!/usr/bin/perl -w
############################################################################
#use spem to align a fasta file with a pdb file
#Input: prosys_script dir, spem_dir, query_file, pdb file, output pir file
#Output: output pir file
#Author: Jianlin Cheng
#Date: 12/08/2007.
#Modified at 12/23/2007
############################################################################

if (@ARGV != 5)
{
	die "need five parameters: script dir, spem dir, query file, template file, output pir file.\n";
}

$script_dir = shift @ARGV;
$spem_dir = shift @ARGV;
$query_file = shift @ARGV;
$temp_file = shift @ARGV;
$out_file = shift @ARGV;

-d $script_dir || die "can't find $script_dir.\n";
-d $spem_dir || die "can't find $spem_dir.\n";
-f $query_file || die "can't find $query_file.\n";
-f $temp_file || die "can't find $temp_file.\n";

use Cwd 'abs_path';

$query_file = abs_path($query_file);
$temp_file = abs_path($temp_file);
$out_file = abs_path($out_file);

$cur_dir = abs_path(".");

open(FASTA, $query_file);
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$qseq = <FASTA>;
chomp $qseq;
close FASTA;

#read query file
open(FASTA, $temp_file);
$tname = <FASTA>;
chomp $tname;
$tname = substr($tname, 1);
$tseq = <FASTA>;
chomp $tseq;
close FASTA;

$tmp_dir = $cur_dir . "/spemtmp";
if (! -d $tmp_dir)
{
	`mkdir $tmp_dir`;
}
chdir $tmp_dir; 

#create a temporary file
open(LIST, ">$name.multi");
print LIST ">$tname\n";
print LIST "$tseq\n";
print LIST ">$name\n";
print LIST "$qseq\n";
close LIST;

#print "generate alignment for $name and $tname using SPEM ...\n";
system("$spem_dir/spem/bin/scan_spem_alone.job $name.multi >/dev/null");

$align_file = "fort.99";
if (! -f $align_file)
{
	print "alignment file is not generated.\n";
	goto END;
	#-f $align_file || die "alignment file is not generated.\n";
}

open(ALIGN, $align_file);
@ali = <ALIGN>;
close ALIGN;

$align1 = "";
$align2 = "";

while (@ali)
{
	
	$line = shift @ali;
	chomp $line;	
	if ($line =~ /^>s1/)
	{
		next;
	}
	if ($line =~ /\*$/)
	{
		chop $line;
		$align2 .= $line;
		last;
	}
	else
	{
		$align2 .= $line;
	}
}

while (@ali)
{
	
	$line = shift @ali;
	chomp $line;	
	if ($line =~ /^>s2/)
	{
		next;
	}
	if ($line =~ /\*$/)
	{
		chop $line;
		$align1 .= $line;
		last;
	}
	else
	{
		$align1 .= $line;
	}
}

open(OUT, ">$name.glo");
print OUT "1\n1\n";
#query
print OUT "$name\n$align1\n";
#template
print OUT "$tname\n$align2\n";
close OUT;

system("$script_dir/global2pir.pl $name.glo $out_file");

END:

#remove template profiles
`rm s2.* _* fort.99 2>/dev/null`;

chdir $cur_dir;




