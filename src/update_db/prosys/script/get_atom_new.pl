#!/usr/bin/perl -w
##################################################################################################
#given a 10-line sequence file(name,length,seq,mapping,ss,bp1,bp2,acc,xyz), and pdb file
#name = pdb_code + chain id
#mapping: dssp index to pdb positions
#extract atom records from the pdb file for the file
#pdb file name must be stanard: pdbxxxx... (can be zipped or not zipped)
#output: atom records 
#
#input: sequence file, pdb file, atom output file, adjust sequence file(first line (#found, #not found)

#possible problem: we store the residue when Ca exists. However, if Ca not exists, but other atoms
# exist, the residue is not added into final set. but the atom file include it, does this cause problem
# to modeller when generate structure from alignment? Is it possible, CA not exist but other atom exist?

#Author: Jianlin Cheng, 3/15/2005 
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
if (@ARGV != 4)
{
	die "Need four parameters:sequence file(10-line) pdb file, atom_file, adjusted seq file\n"
}

$seq_file = shift @ARGV;
-f $seq_file || die "sequence file doesn't exist.\n";
$pdb_file =  shift @ARGV;
-f $pdb_file || die "pdb file doesn't exist.\n"; 
$atom_file =  shift @ARGV;
$new_file = shift @ARGV;


##########read sequence information#######################
open(SEQ, $seq_file) || die "can't read sequence file\n";
$seq_name = <SEQ>; #seq_name: pdb_code + chain id
chomp $seq_name;
$length = <SEQ>;
chomp $length;
$seq = <SEQ>;
chomp $seq;
@seq = split(/\s+/, $seq);
$map = <SEQ>;
chomp $map;
@map = split(/\s+/, $map);
$ss = <SEQ>;
chomp $ss;
@ss = split(/\s+/, $ss); 
$bp1 = <SEQ>;
chomp $bp1;
@bp1 = split(/\s+/, $bp1);
$bp2 = <SEQ>;
chomp $bp2;
@bp2 = split(/\s+/, $bp2);
$sa = <SEQ>;
chomp $sa;
@sa = split(/\s+/, $sa); 
$xyz = <SEQ>;
chomp $xyz;
@xyz = split(/\s+/, $xyz);
close SEQ;

#################consistency verification###################################
if (@seq != $length || @ss != $length || @map != $length || @xyz != $length * 3 ||
    @bp1 != $length ||  @bp2 != $length || @sa != $length )
{
	die "length not match in sequence.\n";
}

#read chain id
$chain = substr($seq_name, 4, 1);


###############read pdb files########################################
$pdbfile = ""; #file name without path
$index = rindex($pdb_file, "/");
if ($index >= 0)
{
	$pdbfile = substr($pdb_file, $index+1); 
}
else
{
	$pdbfile = $pdb_file; 
}
#create tmp file name
$tmp_file = "tmp$pdbfile"; 
`cp $pdb_file $tmp_file`; 

if ($pdb_file =~ /.*Z$/ || $pdb_file =~ /.*gz$/)
{
       #unzip the file
       `gzip -f -d $tmp_file`;       
       $pos = rindex($tmp_file, ".");
       $tmp_file = substr($tmp_file, 0,$pos);
}
#extract pdb code
$pdb_code = substr($tmp_file, 6, 4); #"file format: tmppdbxxxx...." 
$pdb_code = uc($pdb_code);

#check if pdb code match
if (substr($seq_name,0,4) ne $pdb_code)
{
	`rm $tmp_file`; 
	die "sequence name doesn't match with pdb code:$seq_name, $pdb_code.\n"; 
}

if (! open(PDB, "$tmp_file"))
{
	`rm $tmp_file`; 
	die "fail to open unzip pdb file:$tmp_file.\n";
}
@content = <PDB>;
close PDB;
##########################################################################

###########################Extract Information from ATOM RECORD###########
#Extract all ATOMS RECORDS
@records = ();
$multi_model = 0;
foreach $text(@content)
{
	#handle multiple model (only use model 1)
	if ($text =~ /^MODEL\s+/)
	{
		$multi_model = 1;
	}
	if ($text =~ /^ENDMDL/)
	{
		if ($multi_model == 1)
		{
			print "multiple model, take model 1\n";
			last;
		}
	}
	if ($text =~ /^ATOM\s+/)
	{
		$cid = substr($text, 21, 1); 
		if ($cid eq " ")
		{
			$cid = 'A'; 
		}
		if ($cid eq $chain)
		{
			push @records, $text; 
		}
	}
}

#very unefficient algorithm to extract atoms
@new_seq = ();
@new_map = ();
@new_ss = ();
@new_bp1 = ();
@new_bp2 = ();
@new_sa = ();
@new_xyz = (); 

@atoms = (); 

$atom_ind = 1; 
$res_ind = 1; 
for ($i = 0; $i < $length; $i++)
{
	$org_aa = $seq[$i];
	$pos = $map[$i];

	if ($org_aa eq "X")
	{
		print "DSSP residue at $pos is X. skip it.\n";
		next;
	}

	#check if the pos includes an insertion code(chars)
	$org_insertion_code = " ";
	if ($pos =~ /^(\d+)(\D+)/)
	{
		print "insertion code: $pos\n";
		#this position is skipped	
		$pos = $1; 
		#take the first char
		$org_insertion_code = substr($2, 0, 1); 
	}

	$x = $xyz[3*$i];
	$y = $xyz[3*$i+1];
	$z = $xyz[3*$i+2];

	$ca_done = 0; 

        @temp_atoms = (); 
	foreach $text(@records)
	{
		#print "atom: $text";
		#residue (three letter)
		$res = substr($text, 17, 3); 
		#chain id
		$cid = substr($text, 21, 1); 
		if ($cid eq " ")
		{
			$cid = 'A'; 
		}

		$atom_name = substr($text, 12, 4);

		$is_ca = 0;
		if ($atom_name =~ /CA/)
		{
			#extract the xyz coordinates of CA atom
			$xc = substr($text, 30, 8);
			$xc =~ s/\s//g;
			$yc = substr($text, 38, 8);
			$yc =~ s/\s//g;
			$zc = substr($text, 46, 8); 
			$zc =~ s/\s//g;
			$is_ca = 1; 
		}

		#get the residue serial number
		$ser = substr($text, 22, 4);
		$insertion_code = substr($text, 26, 1); 

		#conver to one letter
		$res = uc($res); 
		
		#check the residue length (3-letter or 1-letter)
		$res =~ s/\s+//g;
		if (length($res) == 3)
		{
			if (exists($amino{$res}) )
			{
				$aa = $amino{$res}; 
			}
			else
			{
				$aa = "X"; 
			}
		}
		else
		{
			$aa = $res;
		}

		#set chain id to " "
		$text = substr($text,0, 21) . " " . substr($text, 22);


		#check if the information match
		if ($pos == $ser && $insertion_code eq $org_insertion_code)
		{
			if ($org_aa eq $aa || $org_aa eq "X")
			{
				#get alternate chars of CA atoms (sometime only some atom alternate, so this code doesn't work
				#if ($first_atom == 1 && $is_ca == 1)
				#{
				#	$alternate = substr($text, 16, 1); # we will only consider the first alternate pos
				#	$first_atom = 0;
				#}

				#if (substr($text, 16, 1) ne $alternate && $is_ca == 1)
				#{
					#skip the second alternate positions
				#		next; 
				#}

				if ($org_aa eq "X")
				{
					print "DSSP residue at pos = $pos is X. change it back to $aa.\n";
					$org_aa = $aa;
					$seq[$i] = $aa;
				}
				
				#if ($is_ca == 1)
				if ($is_ca == 1 && $ca_done == 1)
				{
					print "alternating ca: $pdb_code, $cid, pos=$pos,org=$org_aa, aa=$aa\n";
				}
				if ($is_ca == 1 && $ca_done == 0) #here we only check one CA for each residue, discard alternate ones. 
				{
					$diff = sqrt(($x-$xc)*($x-$xc)+ ($y-$yc)*($y-$yc)+($z-$zc)*($z-$zc));

					if ($diff > 0.1)
					{
						#print STDERR "warning the Ca distance is large:$diff, $pdb_code, $cid, pos=$pos,org=$org_aa, aa=$aa\n";
						print "warning the Ca distance is large:$diff, $pdb_code, $cid, pos=$pos,org=$org_aa, aa=$aa\n";
					}
					$ca_done = 1; 
				}

				push @temp_atoms, $text; 
			}
			else
			{
				`rm $tmp_file`; 
				die "$pdb_code,$cid, pos=$pos, org=$org_aa, ser=$ser, aa=$aa doesn't match.\n";
			}
		}
	}
	if ($ca_done == 0)
	{
		print "Ca/residue is not found:$pdb_code, chain = $cid, pos=$pos,org=$org_aa, skip the residue\n";
	}
	else #add information into sequence and atom
	{
		#add sequence info
		push @new_seq, $seq[$i];
		push @new_map, $map[$i];
		push @new_ss, $ss[$i];
		push @new_bp1, $bp1[$i];
		push @new_bp2, $bp2[$i];
		push @new_sa, $sa[$i];
		push @new_xyz, $xyz[3*$i], $xyz[3*$i+1], $xyz[3*$i+2]; 

		#add atoms
		foreach $new_line (@temp_atoms)
		{
			$atom_line = $new_line;
			#replace the old atom id (7-11) with new index.
			$atom_ord = sprintf("%5d", $atom_ind);
			$atom_line = substr($atom_line, 0, 6) . $atom_ord . substr($atom_line, 11); 

			#replace residue index with new index
			$res_ord = sprintf("%4d", $res_ind);
			$atom_line = substr($atom_line, 0, 22) . $res_ord . substr($atom_line, 26);

			#remove the insertion code if necessary
			if ($org_insertion_code ne " ")
			{
				$atom_line = substr($atom_line, 0, 26) . " " . substr($atom_line, 27); 
			}

			push @atoms, $atom_line; 

			$atom_ind++;
		}
		$res_ind++; 
	}
}

#output
$size = @new_seq;
open(NEW, ">$new_file") || die "can't create new sequence file.\n";
print NEW "found=$size, not_found=", $length-$size, "\n";
print "$seq_name, found=$size, not_found=", $length-$size,",ratio=", $size/$length, "\n";
print NEW "$seq_name\n";
print NEW "$size\n";
print NEW join(" ", @new_seq), "\n";
print NEW join(" ", @new_map), "\n";
print NEW join(" ", @new_ss), "\n";
print NEW join(" ", @new_bp1), "\n";
print NEW join(" ", @new_bp2), "\n";
print NEW join(" ", @new_sa), "\n";
print NEW join(" ", @new_xyz), "\n\n";
close NEW; 

open(ATOM, ">$atom_file") || die "can't create atom file.\n";
print ATOM join("", @atoms);
print ATOM "END\n";
close ATOM;

#remove the temporary pdb file
`rm $tmp_file`; 
