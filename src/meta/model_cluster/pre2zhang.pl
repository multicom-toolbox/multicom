#!/usr/bin/perl -w
##################################################################################################
#convert CASP predicted model to model matching with the final true structure file (zhang's target)
#Author: Jianlin Cheng, 9/5/2006 
#################################################################################################

##############standard Amino Acids (3 letter <-> 1 letter)#######################################
%amino=();
$amino{"ALA"} = 'A';
$amino{"CYS"} = 'C';
$amino{"ASP"} = 'D';
$amino{"GLU"} = 'E';
$amino{"PHE"} = 'F';
$amino{"GLY"} = 'G';
$amino{"HIS"} = 'H';
$amino{"ILE"} = 'I';
$amino{"LYS"} = 'K';
$amino{"LEU"} = 'L';
$amino{"MET"} = 'M';
$amino{"MSE"} = 'M';
$amino{"ASN"} = 'N';
$amino{"PRO"} = 'P';
$amino{"GLN"} = 'Q';
$amino{"ARG"} = 'R';
$amino{"SER"} = 'S';
$amino{"THR"} = 'T';
$amino{"VAL"} = 'V';
$amino{"TRP"} = 'W';
$amino{"TYR"} = 'Y';
###################################################################################################

#parse parameters
if (@ARGV != 3)
{
	die "Need three parameters: casp prediction file, zhang target file, output file\n"
}

$casp_file = shift @ARGV;
$target_file = shift @ARGV;
$out_file = shift @ARGV;

#read target file
open(TARGET, $target_file) || die "can't read target file.\n";
@target = <TARGET>;
close TARGET;


@order = ();
while (@target)
{
	$record = shift @target;
	chomp $record;
	if ($record !~ /^ATOM/)
	{
		next;
	}
	@fields = split(/\s+/, $record);
	$aa = $fields[3];
	if (defined($amino{$aa}))
	{
		$aa = $amino{$aa}; 
	}
	else
	{
		die "$aa is not found\n";
	}

	push @atoms, {
		new_idx => $fields[1],
		aa => $aa,
		org_idx => $fields[4],
		x => $fields[5],
		y => $fields[6],
		z => $fields[7]
	};
	push @order, $fields[4];
}

#read CASP predicted model
open(CASP, $casp_file) || die "can't read $casp_file\n";
@casp = <CASP>;
close CASP;

@selected = ();
while (@casp)
{
	$line = shift @casp;
	chomp $line;

	if ($line =~ /^ATOM/)
	{
		@fields = split(/\s+/, $line);
		$aa = $fields[3];
		if (defined($amino{$aa}))
		{
			$aa = $amino{$aa}; 
		}
		else
		{
			die "$aa is not found\n";
		}
		$idx = $fields[4];

		#check if the amino acid is in the true pdb file
		for ($i = 0; $i < @atoms; $i++)
		{
			$ord = $atoms[$i]{"org_idx"};
			if ($idx == $ord)
			{
				#check if amino acid match
				$aa eq $atoms[$i]{"aa"} || die "amino acid doesn't match.\n";
				push @selected, $line;
			}
		}
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";

print OUT join("\n", @selected), "\n";

close OUT;

