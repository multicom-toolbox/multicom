#!/usr/bin/perl -w

if (@ARGV != 4)
{
	die "need four parameters: compass_db_tool (~/software/new_compass/compass_search/mk_compass_db), input directory of aln files (aln directory, sort90 library file, output db file.\n";
}

$compass = shift @ARGV;
-f $compass || die "can't find $compass.\n";

$aln_dir = shift @ARGV;
-d $aln_dir || die "can't find $aln_dir.\n";

$sort90 = shift @ARGV;

$db_file = shift @ARGV;

open(SORT, $sort90) || die "can't read $sort90.\n";
@data = <SORT>;
close SORT;

open(LIST, ">$db_file.list1");
open(LIST2, ">$db_file.list2");
open(LIST3, ">$db_file.list3");
open(LIST4, ">$db_file.list4");
open(LIST5, ">$db_file.list5");

$num = @data / 10; #divide the data into fivee sections (two lines are counted as one protein)
$count = 1;
while (@data)
{
	$name = shift @data;
	$name =~ /^>/ || die "sort file format error.\n";
	chomp $name;
	$name = substr($name, 1);
	$aln_file = "$aln_dir/$name.aln";
	if (-f $aln_file)
	{
		if ($count < $num)
		{
			print LIST "$aln_file\n";
		}
		elsif ($count < 2 * $num)
		{
			print LIST2 "$aln_file\n";
		}
		elsif ($count < 3 * $num)
		{
			print LIST3 "$aln_file\n";
		}
		elsif ($count < 4 * $num)
		{
			print LIST4 "$aln_file\n";
		}
		else
		{
			print LIST5 "$aln_file\n";
		}
	}
	shift @data;
	$count++;
}
close LIST;
close LIST2;
close LIST3;
close LIST4;
close LIST5;

system("$compass -i $db_file.list1 -o ${db_file}1");
system("$compass -i $db_file.list2 -o ${db_file}2");
system("$compass -i $db_file.list3 -o ${db_file}3");
system("$compass -i $db_file.list4 -o ${db_file}4");
system("$compass -i $db_file.list5 -o ${db_file}5");

