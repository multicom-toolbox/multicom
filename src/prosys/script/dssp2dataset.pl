#!/usr/bin/perl

# Processes multiple DSSP files sending on the standard output the fine PFM
#
# usage:
# dssp2adataset input_files
#
#
# Gianluca Pollastri, 24 Aug 2001, Dublin
#
# updated 11 Feb 2002, Irvine
# bug assigning beta-partners in broken chains fixed
#
# Copyright (C) Gianluca Pollastri 2002
#

#Modified by Jianlin Cheng, 5/29/2004. To ouput the result to a file instead of 
#standard output. 

#Modifided by Jianlin Cheng, 8/12/2004, Fix the problem of treating bonded cysteines. 
#IMPORTANT: copied from dssp2adataset.pl: generate one extra line to map dssp index to original pdb index used by mutation dataset

#Copy from /mupro/script/dssp2dataset.pl and  Modified by Jianlin Cheng 3/15/2005: single chain id is changed from A to "_"

#ARGV: a list of files. except the last file(which is output file), all 
#other files are input dssp files. usually, just one input dssp file.  

if (@ARGV != 2)
{
    die "need two parameters: input dssp file, output file(create new)";
}


$dest_file = pop @ARGV;

#if (-f $dest_file)
#{
	#append.
#	open(DEST, ">>$dest_file") || die "can't open the output file";
#}
#else
#{
	#Here we only overwirte file if it exist, not appending anymore.
	open(DEST, ">$dest_file") || die "can't create the output file.\n";
#}


@aanames = ('A', 'B', 'C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','X', 'Y', 'Z');
@accth = (106, 160, 135, 163, 194, 197, 84, 184, 169, 205, 164, 188, 157, 136, 198, 248, 130, 142, 142, 227, 180, 222, 196);
%accth2=();

for ($q = 0; $q<=$#aanames; $q++) {
	$accth2 {$aanames[$q]} = $accth[$q];
}

sub trunc2() {
$cm=shift;

if ($cm =~ /([\000-\256]+)\.([\000-\256]+)/) {
	$foo=substr($2,0,2);
	$nextd=substr($2,2,1);
	if ($nextd >=5) {$foo++;}
	$cm=$1.'.'.$foo;
	}

return $cm;
}





$nargp=0;
$done=0;
$crash=0;

$pro_file="";
$num_cont=0;

$intestazione="";

while ($ARGV[$nargp]) {
$filen=$ARGV[$nargp];


$nargp++;

open(fi,"<$filen");
@testo=<fi>;
close(fi);

@testo2=@testo;

@ini_pos=();
$pos=1;
push(@ini_pos,$pos);
@fin_pos=();
$ichain="A";


# The file is scanned to detect initial and final positions of the chains

while (@testo2) {
	$linea=shift(@testo2);
	if ($linea =~ /\#([\ ]+)RESIDUE([\000-\256]*)/) {


		while (@testo2) {
			$linea=shift(@testo2);
			chop($linea);
			$linea=substr($linea,0,18)."*******".substr($linea,25);


			# If no chain ID is provided, the chain is set to "A"

			$chain=substr($linea,11,1);
			$isbreak=substr($linea,13,1);

			if ($chain eq " ") {
				$linea=substr($linea,0,11).$ichain.substr($linea,12);
				$chain=$ichain;
				}

			# Blanks are removed

			while (index($linea,"  ")!=-1) {
				$pos=index($linea,"  ");
				$uno=substr($linea,0,$pos);
				$due=substr($linea,$pos+2);
				$linea=$uno." ".$due;
				}

			@divided=split(/\ /,$linea);

			$pos = $divided[1];

			if ($chain ne $ichain) {
				push(@fin_pos,$pos-1);
				push(@ini_pos,$pos);
				$ichain=$chain;
				}

			}
		} # end if (RESIDUE)
	} # end external scan @testo

push(@fin_pos,$pos);

#while (@ini_pos) {
#	print (shift(@ini_pos)." ".shift(@fin_pos)."\n");
#	}



@ini_pos1=@ini_pos;
@fin_pos1=@fin_pos;



$flag=0;

$name="";
$name2="";

$date="";

@aas=();
@sss=();
@chains = ();
@coords = ();

@bs1s = ();
@bs2s = ();
@accesss = ();

#keep track the pdb postion of each amino acids
@pdb_pos = (); 

$counter_pre=0;
$counter_post=0;

$ext_bs=0;

@chain_rem=();

$ichain="A";

$ini=shift(@ini_pos);
$fin=shift(@fin_pos);

$flag1=1;

@testo2 = @testo;


while (@testo2 && $flag1) {
	$linea=shift(@testo2);
	if ($linea =~ /^HEADER([\000-\256]+)/) {
		$linea=$1;
		$intestazione=$linea;

		chop($linea);
		chop($linea);

		while (index($linea,"  ")!=-1) {
			$pos=index($linea,"  ");
			$uno=substr($linea,0,$pos);
			$due=substr($linea,$pos+2);
			$linea=$uno." ".$due;
			}

		@divided=split(/\ /,$linea);
		$name=$divided[$#divided];
		$date=$divided[$#divided-1];

#		print $date;

		for ($is=1;$is<$#divided-1;$is++) {
			$name2 .= $divided[$is];
			}
		$flag1=0;
		}
	}



while (@testo) {
#	print "*\n";
	$linea=shift(@testo);

	if ($linea =~ /\#([\ ]+)RESIDUE([\000-\256]*)/) {
		$flag=1;
		$done++;


		while (@testo) {
			$linea=shift(@testo);
			chop($linea);
			$linea=substr($linea,0,18)."*******".substr($linea,25);


			$chain=substr($linea,11,1);
			if ($chain eq " ") {
				$linea=substr($linea,0,11).$ichain.substr($linea,12);
				$chain=$ichain;
				}

			if ($chain ne $ichain) {
				push(@chain_rem,"$chain $ichain\n");

				$ini=shift(@ini_pos);
				$fin=shift(@fin_pos);
				$ichain=$chain;

				}

			#extract the corresponding position in PDB file
			#one problem: some time pdb position start from 0, sometimes from 1
			#must be careful when we cast dssp position back
			$temp_string = $linea;
			@separate_vec = split(/\s+/, $temp_string);
			$pdb_position = $separate_vec[2]; 

			$aa=substr($linea,13,1); 
			###############################################################
			#Seriours bug fix: lower case is for Cysteine in disulfide bond
			#Jianlin Cheng
			#$aa =~ y/a-z/A-Z/;
			$aa =~ y/a-z/C/;
			################################################################
			$ss=substr($linea,16,1);
			if ($ss eq " ") {
				$linea=substr($linea,0,16).".".substr($linea,17);
				$ss=".";
				}
			$bs1 = substr($linea,25,4);
			$bs2 = substr($linea,29,4);
			$access = substr($linea,35,3);

			push(@chains, $chain);
			push(@aas, $aa);
			push(@sss, $ss);
			push(@pdb_pos, $pdb_position); 
			$aas .= $aa;
			$sss .= $ss;


			if ($bs1 =~ /([\ ]+)([0-9]+)/) {
				$bs1=$2;
				}
			if ($bs2 =~ /([\ ]+)([0-9]+)/) {
				$bs2=$2;
				}
			if ($access =~ /([\ ]+)([0-9]+)/) {
				$access=$2;
				}


			if (($bs1>=$ini && $bs1<=$fin)) {
				push(@bs1s, ($bs1-$ini+1));
			} else {
				push(@bs1s, "0");
			}
			if (($bs2>=$ini && $bs2<=$fin)) {
				push(@bs2s, ($bs2-$ini+1));
			} else {
				push(@bs2s, "0");
			}

			$th = $accth2{$aa};
			if ($access >= $th) {
				push(@accesss, "100");
			} else {
				$accp = 0.5 + 100.0 * $access / $th;
				$acci = int($accp);
				push(@accesss, $acci);
			}


			while (index($linea,"  ")!=-1) {
				$pos=index($linea,"  ");
				$uno=substr($linea,0,$pos);
				$due=substr($linea,$pos+2);
				$linea=$uno." ".$due;
				}
#			print "$linea";


			@divided=split(/\ /,$linea);


			$x=$divided[$#divided-2];
			$y=$divided[$#divided-1];
			$z=$divided[$#divided];

			push(@coords, "$x $y $z ");


			$pos = $divided[2];


			}
		} # end if (RESIDUE)
	} # end external scan @testo

$fla_month=0;
#print $date;








while (@ini_pos1) {
	$ini = shift @ini_pos1;
	$fin = shift @fin_pos1;
	if ($ini > $fin) {next;}
	print DEST "$name$chains[$ini]\n";

	$offset=0;
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] eq '!') {
		$offset++;
	   } 
	}
	print DEST ($fin-$ini-$offset+1)."\n";

	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		print DEST "$aas[$r]\t";
	   } 
	}
	print DEST "\n";

	#print out pdb position
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		print DEST "$pdb_pos[$r] ";
	   } 
	}

	print DEST "\n";
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		print DEST "$sss[$r]\t";
	   }
	}
	print DEST "\n";

      $negoffset=0;
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		$bs=$bs1s[$r]-$negoffset;
		if ($bs<0) {$bs=0;}
		print DEST "$bs\t";
	   } else {
		$negoffset++;
	   }
	}
	print DEST "\n";

      $negoffset=0;
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		$bs=$bs2s[$r]-$negoffset;
		if ($bs<0) {$bs=0;}
		print DEST "$bs\t";
	   } else {
		$negoffset++;
	   }
	}

	print DEST "\n";
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		print DEST "$accesss[$r]\t";
	   }
	}
	print DEST "\n";
	for ($r=$ini-1; $r<$fin; $r++) {
	   if ($aas[$r] ne '!') {
		print DEST "$coords[$r]\t";
	   }
	}
	print DEST "\n\n";
#print "$namet\n$chainst\n$aast\n$ssst\n$coordst\n\n";
}


}
close(DEST);
