#!/usr/bin/perl -w
#########################################################
#Check if all the proteins in Rych's data set have a pdb
#file in the current scop repository.
#and copy pdb files to pdb dir. 
##########################################################
#$pdb_dir = "/home/jianlinc/profam/dataset/pdbstyle-1.65/"; 
$pdb_dir = "/home/jianlinc/profam/scop_allpdb_1.65/pdbstyle-1.65/"; 
$file_list = "./uniq.list";
$dest_dir = "./pdb"; 
open(LIST, "$file_list") || die "can't read file list: $file_list.\n";

@list = <LIST>;
close LIST;

$nfound = 0;
$total = @list; 

while(@list)
{
	$file = shift @list;
	chomp $file; 
	$sub_dir = substr($file, 1, 2);
	$full_dir = $pdb_dir . $sub_dir . "/";
	#print "$file, $sub_dir, $full_dir\n"; 
	#<STDIN>;
	if (! -d $full_dir)
	{
#	        die "pdb dir doesn't exist: $full_dir\n";
	}
	$pdb_file = $full_dir . "d" . $file . ".ent";
	if (! -f $pdb_file)
	{
	    print "$file: pdb file doesn't exist: $pdb_file\n";
	}
	else	
	{
		`cp $pdb_file $dest_dir/$file`; 
		$nfound++; 
	}

}

print "*****************************\n"; 
print "total: $total, found: $nfound\n"; 
