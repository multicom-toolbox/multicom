#!/usr/bin/perl -w
#######################################################################
#align two shhm files using hhsearch
#Input: prosys dir, shhm file1, shhm file2, output pir file.
#Output: pir format alignment file.
#######################################################################

if (@ARGV != 6)
{
	die "need 6 parameters: prosys dir, hhsearch dir (new version) (/home/casp13/MULTICOM_package/software/hhsearch1.2/linux32/), shhm file 1, shhm file 2, query file (fasta), output pir file.\n";
}

$prosys_dir = shift @ARGV;
$hhsearch_dir = shift @ARGV;
$hhm1 = shift @ARGV;
$hhm2 = shift @ARGV;
$query_file = shift @ARGV;
$out_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $hhsearch_dir || die "can't find $hhsearch_dir.\n";

-f $hhm1 || die "can't find $hhm1\n";
-f $hhm2 || die "can't find $hhm2\n";

print "do hhsearch alignment...\n";
system("$hhsearch_dir/hhsearch -i $hhm1 -d $hhm2 >/dev/null  2>/dev/null");

$idx = rindex($hhm1, ".");
if ($idx > 0)
{
	$prefix = substr($hhm1, 0, $idx);
}
else
{
	$prefix = $idx;
}

print "parse hhsearch output...\n";
system("$prosys_dir/script/parse_hhsearch.pl $prefix.hhr $prefix.hhs");

system("$prosys_dir/script/hhsearch_align_comb.pl $prosys_dir/script/ $query_file  $prefix.hhs 1 1 1 1 1 1 $out_file");






