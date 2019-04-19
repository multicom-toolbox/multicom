#!/usr/bin/perl -w
#############################################################################
#Use verify 3d to evaluate pdb model
#Input: prosys dir, verify 3d dir, dssp dir, pdb file
#output file
#Author: Jianlin Cheng
#Date: 2/17/2006
#############################################################################
if (@ARGV != 5)
{
	die "need 5 parameters: dssp2dataset.pl, verify 3d dir, dssp dir, pdb file, output file.\n";
}

$dssp2dataset = shift @ARGV;
$verify3d_dir = shift @ARGV;
$dssp_dir = shift @ARGV;
$pdb_file = shift @ARGV;
$out_file = shift @ARGV;

-f $dssp2dataset || die "can't find script $dssp2dataset\n";
-d $verify3d_dir || die "can't find verify 3d dir.\n";
-d $dssp_dir || die "can't find $dssp_dir\n";
-f $pdb_file || die "can't find pdb file.\n";

print "convert pdb to dssp...\n";
$dssp_file = $pdb_file . ".dssp";
$status = system("${dssp_dir}dsspcmbi $pdb_file $dssp_file");
if ($status == 0) #succeed
{
   print "process $pdb_file successfully.\n";
}
else
{
	print "fail to generate dssp file for $pdb_file.\n";
}

print "convert dssp file to dataset file...\n";
$set_file = $pdb_file . ".set";
system("$dssp2dataset $dssp_file $set_file");


#generate secondary stx file for verify 3d
$ssf = $pdb_file . ".ssf"; 
open(SET, $set_file) || die "can't read $set_file\n";
<SET>;
<SET>;
$seq = <SET>;
$seq =~ s/\s//g; 
<SET>;
$sec = <SET>;
$sec =~ s/\s//g; 
close SET; 

$ss = ""; 
for ($i = 0; $i < length($sec); $i++)
{
	$val = substr($sec, $i, 1); 
	if ( $val eq "E" || $val eq "B")
	{
		$ss .= "E"; 
	}
	elsif ($val eq "H" || $val eq "G" || $val eq "I")
	{
		$ss .= "H";
	}
	else
	{
		$ss .= "C"; 
	}
}

length($ss) ==  length($seq) || die "sequence length doesn't match with secondary structure length.\n"; 
print "$ss\n";

#generate input scripts for verify3d and run verify3d
#get starting and end positions for helix and strand
#state: c: coil, h: helix, e: strand
$state = "c"; 
@helix_start = ();
@helix_end = ();
@strand_start = ();
@strand_end = (); 
for ($i = 0; $i < length($ss); $i++)
{
	$val = substr($ss, $i, 1);

	if ($val eq "H")
	{
		if ($state ne "h")
		{
			if ($state eq "e")
			{
				push @strand_end, $i - 1; 
			}
			push @helix_start, $i; 
			$state = "h";
		}
	}
	if ($val eq "E")
	{
		if ($state ne "e")
		{
			if ($state eq "h")
			{
				push @helix_end, $i - 1; 
			}
			push @strand_start, $i;  
			$state = "e";
		}
	}
	if ($val eq "C")
	{
		if ($state eq "h")
		{
			push @helix_end, $i - 1; 
			$state = "c";
		}
		if ($state eq "e")
		{
			push @strand_end, $i - 1; 
			$state = "c";
		}
	}
	if ($i == length($ss) - 1)
	{
		if ($state eq "h")
		{
			push @helix_end, $i;  
		}
		if ($state eq "e")
		{
			push @strand_end, $i;  
		}
	}
}

$num_helix = @helix_start;
$num_strand = @strand_start;

$num_helix == @helix_end || die "helix start num != end num\n";

if ($num_strand != @strand_end)
{
	$end_num = @strand_end; 
	die "strand start_num ($num_strand) != end num ($end_num)\n";
}

%amino=();
$amino{"A"} = "ALA";
$amino{"C"} = "CYS";
$amino{"D"} = "ASP";
$amino{"E"} = "GLU";
$amino{"F"} = "PHE";
$amino{"G"} = "GLY";
$amino{"H"} = "HIS";
$amino{"I"} = "ILE";
$amino{"K"} = "LYS";
$amino{"L"} = "LEU";
$amino{"M"} = "MET";
$amino{"N"} = "ASN";
$amino{"P"} = "PRO";
$amino{"Q"} = "GLN";
$amino{"R"} = "ARG";
$amino{"S"} = "SER";
$amino{"T"} = "THR";
$amino{"V"} = "VAL";
$amino{"W"} = "TRP";
$amino{"Y"} = "TYR";

open(SSF, ">$ssf") || die "can't create $ssf.\n";

#print out helix
for ($i = 0; $i < @helix_start; $i++)
{
	
	$helix = "HELIX ";
	$helix .= " ";
	#helix index
	$helix .= sprintf("%3d", $i+1);
	#helix id
	$helix .= "     ";
	$start = $helix_start[$i]; 
	$aa = substr($seq, $start, 1);
	$aa_name = $amino{$aa};
	defined $aa_name || die "residue $aa is not defined.\n";
	#initial residue name
	$helix .= sprintf("%3s", $aa_name); 
	$helix .= "   ";
	#inital residue num
	$helix .= sprintf("%4d", $start + 1);

	$helix .= "  ";
	#terminal residue name
	$end = $helix_end[$i]; 
	$aa = substr($seq, $end, 1);
	$aa_name = $amino{$aa};
	defined $aa_name || die "residue $aa is not defined.\n";
	$helix .= sprintf("%3s", $aa_name); 
	$helix .= "   ";
	#terminal residue num
	$helix .= sprintf("%4d", $end + 1);
	$helix .= " \n";

	print SSF "$helix";
}

#print out beta-sheet 
for ($i = 0; $i < @strand_start; $i++)
{
	
	$sheet = "SHEET  ";
	#helix index
	$sheet .= sprintf("%3d", $i+1);
	#helix id
	$sheet .= "       ";
	$start = $strand_start[$i]; 
	$aa = substr($seq, $start, 1);
	$aa_name = $amino{$aa};
	defined $aa_name || die "residue $aa is not defined.\n";
	#initial residue name
	$sheet .= sprintf("%3s", $aa_name); 
	$sheet .= "  ";
	#inital residue num
	$sheet .= sprintf("%4d", $start + 1);

	$sheet .= "  ";
	#terminal residue name
	$end = $strand_end[$i]; 
	$aa = substr($seq, $end, 1);
	$aa_name = $amino{$aa};
	defined $aa_name || die "residue $aa is not defined.\n";
	$sheet .= sprintf("%3s", $aa_name); 
	$sheet .= "  ";
	#terminal residue num
	$sheet .= sprintf("%4d", $end + 1);
	$sheet .= " \n";

	print SSF "$sheet";
}
close SSF; 

#generate environment information
open(ENVSH, ">$pdb_file.sh") || die "can't create environment script.\n";
print ENVSH "$verify3d_dir/environments << EOIN\n";
print ENVSH "$pdb_file\n$ssf\n$pdb_file.env\nU\nEOIN\n";
close ENVSH;
`chmod 755 $pdb_file.sh`; 
#generate environment information
use Cwd 'abs_path'; 
$env_script = abs_path("$pdb_file.sh");
system($env_script);

#generate a script for verify3d
open(VERIFY, ">$pdb_file.v3d.sh") || die "can't create verify3d script.\n";
print VERIFY "$verify3d_dir/verify_3d << EOIN\n";
print VERIFY "$pdb_file.env\n$verify3d_dir/3d_1d.tab\n$out_file\n21\n0\nEOIN\n";
close VERIFY;
`chmod 755 $pdb_file.v3d.sh`; 
#run verify3d
use Cwd 'abs_path'; 
$verify_script = abs_path("$pdb_file.v3d.sh");
system($verify_script);

#remove temporary files
`rm $pdb_file.env $pdb_file.sh $pdb_file.v3d.sh $pdb_file.ssf`;
`rm $pdb_file.set $pdb_file.dssp`; 

