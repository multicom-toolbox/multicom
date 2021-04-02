#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use File::Basename;
use Data::Dumper;
use File::Temp qw(tempfile);
use Getopt::Long;

my $input_rr = shift;
my $fasta = shift;
my $native_pdb = shift;
my $param_cont_type = shift;         # long medium short;

my $file_log = "log.txt";

my $d_threshold = 8;
my $param_atom_type = "cb";
my $short_range_min  = 6;         # 6;
my $short_range_max  = 11;         # 11;
my $medum_range_min  = 12;         # 12;
my $medium_range_max = 23;         # 23;
my $long_range_min   = 24;         # 24;
# Global Variables
my $MAX_SEQ_LIMIT = 1600;
my $MIN_SEQ_LIMIT = 5;
my $MAX_SOURCES   = 10;
my $MAX_JOBS_PER_CLIENT = 25;

my %min_true_dist  = ();
my %min_true_d_atoms = ();
my $native_rr;
my $rr_sequence;
my $id;
my %true_contacts  = ();
my %native_res_list = ();
my %top_count      = ();
my %top_count_order= ();
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V UNK -);
our %AA1TO3 = reverse %AA3TO1;

system_cmd("cp $input_rr input.rr");
my ($rr_sorted_fh, $rr_sorted_file) = tempfile();
	system_cmd("rm -f $rr_sorted_file");
	# Keep contact rows only
	system_cmd("sed -i '/^[A-Z]/d' input.rr");
	system_cmd("sed -i '/^-]/d' input.rr");
	# Some files have leading white spaces
	system_cmd("sed -i 's/^ *//' input.rr");
	# Stable sort with -s option, i.e. maintain order in case confidence are equal
	# Also using -g option instead of -n because some predictors have exponential values in confidence
	system_cmd("sort -gr -s -k5 input.rr > $rr_sorted_file");
	system_cmd("rm -f input.rr");
	system_cmd("cat $rr_sorted_file >> input.rr");
	system_cmd("rm -f $rr_sorted_file");

# Precompute this once for all, to save time
# if ($native_pdb){
# 	my $min_seq_sep = $short_range_min;
# 	$min_seq_sep = $medum_range_min if $param_cont_type eq "medium";
# 	$min_seq_sep = $long_range_min if $param_cont_type eq "long";
# 	%min_true_dist = all_pairs_min_dist($native_pdb, $min_seq_sep, $d_threshold, 0);
# 	%min_true_d_atoms = all_pairs_min_dist($native_pdb, $min_seq_sep, $d_threshold, 1);
# 	pdb2rr($native_pdb, "native.rr", $min_seq_sep, $d_threshold, $param_atom_type);
# 	$native_rr = "native.rr";
# 	%true_contacts = rrfile_to_r1r2hash($native_rr, $min_seq_sep, 1000000);
# 	%native_res_list = res_num_res_name($native_pdb);
# }

# CASP uses Native's Length as reference
my $sequence = seq_chain($native_pdb) if -f $native_pdb;
$top_count{"5"}  = 5;
$top_count{"L10"} = int(0.1 * length($sequence) + 0.5);
$top_count{"L5"}  = int(0.2 * length($sequence) + 0.5);
$top_count{"L2"}  = int(0.5 * length($sequence) + 0.5);
$top_count{"L"}   = length($sequence);
$top_count{"2L"}  = int(2.0 * length($sequence));
$top_count_order{"5"}    = 1;
$top_count_order{"L10"}  = 2;
$top_count_order{"L5"}   = 3;
$top_count_order{"L2"}   = 4;
$top_count_order{"L"}    = 5;
$top_count_order{"2L"}   = 6;

foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
	my $seq = undef;
	$seq = seq_fasta($fasta);
	system_cmd("rm -f temp.rr");
	print2file("temp.rr", $seq);
	if(-f "$native_pdb"){
		my %rrn = rr_rows_ordered_in_hash("native.rr", 100000, "all", "all");
		foreach my $row (sort {$a <=> $b} keys %rrn){
			print2file("temp.rr", $rrn{$row}." PDB");
		}
	}
	my %rr = rr_rows_ordered_in_hash("input.rr", $top_count{$top}, "all", $param_cont_type);
	#print Dumper(\%rr);
	foreach my $row (sort {$a <=> $b} keys %rr){
		my @C = split /\s+/, $rr{$row};
		$rr{$row} .= " input" if not defined $C[5];
		print2file("temp.rr", $rr{$row});
	}
	my $prefix = "";
	my $title = "${prefix}Top-$top";
	$title =~ s/L/L\// if $title =~ /L[0-9]/;
	plot_contact_map("temp.rr", "${top}_$param_cont_type.png", $title, $file_log);
}

sub system_cmd{
	my $command = shift;
	error_exit("EXECUTE [$command]") if (length($command) < 5  and $command =~ m/^rm/);
	append2log("[Executing $command]");
	system($command);
	if($? != 0){
		my $exit_code  = $? >> 8;
		error_exit("Failed executing [$command]!<br>ERROR: $!");
	}
}

sub rr_rows_ordered_in_hash{
	my $file_rr = shift;
	my $count = shift;
	my $source = shift;
	my $type = shift;
	my $confidence_thres = shift;
	confess "Input file not defined" if not defined $file_rr;
	confess "Input file $file_rr does not exist!" if not -f $file_rr;
	confess "No File RR!" if not -f $file_rr;
	confess "No contact count!" if not defined $count;
	confess "No contact source!" if not defined $source;
	confess "No contact type" if not defined $type;
	confess "Invalid type" if not ($type eq "everything" or $type eq "all" or $type eq "short" or $type eq "medium" or $type eq "long");
	my %rr = ();
	my $i = 1;
	my %i_for_each_source = ();
	# Find all Contact sources
	if ($source eq "all"){
		open RR, $file_rr or confess $!;
		while (<RR>){
			next unless $_ =~ /[0-9]/;
			chomp $_;
			$_ =~ s/\r//g;
			$_ =~ s/^\s+//;
			next unless $_ =~ /^[0-9]/;
			my @C = split /\s+/, $_ ;
			last if not defined $C[5];
			last if (scalar keys %i_for_each_source) >= $MAX_SOURCES;
			$i_for_each_source{$C[5]} = 1;
		}
		close RR;
	}
	open RR, $file_rr or error_exit($!);
	while(<RR>){
		my $row = $_;
		next unless $row =~ /[0-9]/;
		chomp $row;
		$row =~ s/\r//g;
		$row =~ s/^\s+//;
		next unless $row =~ /^[0-9]/;
		my @C = split /\s+/, $row ;
		error_exit("Expecting a pair in row [".$row."]!\n") if (not defined $C[0] || not defined $C[1]);
		error_exit("Confidence column not defined in row [".$row."] in file <b>$file_rr</b>! </br>Please make sure that the input RR file is in 5-column format!") if not defined $C[4];
		# Fix order
		if ($C[0] > $C[1]){
			$row = $C[1]." ".$C[0]." ".$C[2]." ".$C[3]." ".$C[4];
			$row = $C[1]." ".$C[0]." ".$C[2]." ".$C[3]." ".$C[4]." ".$C[5] if defined $C[5];
		}
		if (defined $confidence_thres){
			next if $C[4] < $confidence_thres;
		}
		# Select only LR, MR, SR or all
		my $d = abs($C[0]-$C[1]);
		if ($type eq "long"){
			next if $d < $long_range_min;
		}
		if ($type eq "medium"){
			next if $d < $medum_range_min;
			next if $d > $medium_range_max;
		}
		if ($type eq "short"){
			next if $d < $short_range_min;
			next if $d > $short_range_max;
		}
		next if ($d < $short_range_min and $type eq "all");
		# Select only those matching the source
		$C[5] = "all" if not defined $C[5];
		if ($source eq "all" and $C[5] eq "all"){
			$rr{$i} = $row;
			$i++;
			last if $i > $count;
		}
		elsif($source ne "all" and $C[5] eq "all"){
			confess "Specified some specific source but there is a whose source is not specified";
		}
		elsif($source eq "all" and $C[5] ne "all"){
			next if not defined $i_for_each_source{$C[5]};
			next if $i_for_each_source{$C[5]} > $count;
			$i++;
			$rr{$i} = $row;
			$i_for_each_source{$C[5]}++;
		}
		else{
			next if $C[5] ne $source;
			$rr{$i} = $row;
			$i++;
			last if $i > $count;
		}
	}
	close RR;
	append2log("Subroutine: rr_rows_ordered_in_hash :: File: $file_rr Type: $type Count: $count Source: $source -> Returning ".(scalar keys %rr)." rows");
	return %rr;
}

sub seq_chain{
	my $chain = shift;
	confess "ERROR! file $chain does not exist!" if not -f $chain;
	my $seq = "";
	open CHAIN, $chain or confess $!;
	while(<CHAIN>){
		next if $_ !~ m/^ATOM/;
		if (parse_pdb_row($_,"rname") eq "GLY"){
			next if parse_pdb_row($_,"aname") ne "CA";
		}
		else{
			next if parse_pdb_row($_,"aname") ne "CB";
		}
		confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $chain! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
		my $res = $AA3TO1{parse_pdb_row($_,"rname")};
		$seq .= $res;
	}
	close CHAIN;
	confess "$chain has less than 1 residue!" if (length($seq) < 1);
	return $seq;
}

sub plot_contact_map{
	my $file_rr = shift;
	my $output_png = shift;
	my $id = shift;
	append2log("Plotting $id");
	system_cmd("rm -f cmap.R");
	print2file("cmap.R", "png(\"$output_png\", width=1600, height=1600, res=300)");
	print2file("cmap.R", "infile = \"$file_rr\"");
	print2file("cmap.R", "con <- file(infile, \"rt\")");
	print2file("cmap.R", "seqlen <- readLines(con, 1)");
	print2file("cmap.R", "L <- nchar(seqlen)");
	print2file("cmap.R", "data <- read.table(infile, skip = 1, header = FALSE)");
	print2file("cmap.R", "col_count <- ncol(data)");
	print2file("cmap.R", "data\$V7 <- abs(data\$V1-data\$V2)");
	print2file("cmap.R", "data\$V7[data\$V7 > 23] <- 200");
	print2file("cmap.R", "data\$V7[data\$V7 < 12] <- 100");
	print2file("cmap.R", "data\$V7[data\$V7 < 24] <- 150");
	print2file("cmap.R", "data\$V7[data\$V7 == 100] <- 4");
	print2file("cmap.R", "data\$V7[data\$V7 == 150] <- 3");
	print2file("cmap.R", "data\$V7[data\$V7 == 200] <- 2");
	print2file("cmap.R", "data\$V8[data\$V7 == 4] <- \"Short-Range\"");
	print2file("cmap.R", "data\$V8[data\$V7 == 3] <- \"Medium-Range\"");
	print2file("cmap.R", "data\$V8[data\$V7 == 2] <- \"Long-Range\"");
	print2file("cmap.R", "data\$V9 = as.numeric(data\$V6)");
	print2file("cmap.R", "par(mar=c(2,2,0.5,0.5))");
	print2file("cmap.R", "# Plot for an RR file with multiple sources");
	print2file("cmap.R", "native <- subset(data, data\$V6 == \"PDB\")");
	print2file("cmap.R", "plot(native\$V1, native\$V2, col=\"blue\", pch=0, xlab = NULL, ylab = NULL, ylim=c(L, 1), xlim=c(1, L))");
	print2file("cmap.R", "points(native\$V2, native\$V1, col=\"blue\", pch=0, xlab = NULL, ylab = NULL, ylim=c(L, 1), xlim=c(1, L))");
	print2file("cmap.R", "predic <- subset(data, data\$V6 != \"PDB\")");
	print2file("cmap.R", "points(predic\$V2, predic\$V1, col=\"red\", xlab = NULL, ylab = NULL, ylim=c(L, 1), xlim=c(1, L), pch = 2)");
	#print2file("cmap.R", "legend(\"topright\", bty=\"n\", legend=c(\"input\",\"native\"), pch = c(2,0), col=c(\"red\",\"blue\"))");
	print2file("cmap.R", "legend(\"topright\", bty=\"n\", legend=c(\"DNCON2-RR\",\"Model-RR\"), pch = c(2,0), col=c(\"red\",\"blue\"))");
	print2file("cmap.R", "text(0, L, \"$id\", cex=2.0, adj = c(0,1), pos=4)"); 
	#print2file("cmap.R", "dev.off()");
	system_cmd("Rscript cmap.R");
}

sub all_pairs_min_dist{
	my $file_pdb = shift;
	my $separation = shift;
	my $d_threshold = shift;
	my $flg_atoms_not_dist = shift;
	confess ":( $file_pdb does not exist!" if not -f $file_pdb;
	my %xyz = ();
	my %pairs_dist = ();
	my %pairs_atoms = ();
	if($param_atom_type eq "ca" or $param_atom_type eq "cb"){
		%xyz = xyz_pdb($file_pdb, $param_atom_type);
		foreach my $r1(sort {$a <=> $b} keys %xyz){
			foreach my $r2(sort {$a <=> $b} keys %xyz){
				next if $r1 >= $r2;
				next if abs($r1 - $r2) < $separation;
				my $d = calc_dist($xyz{$r1}, $xyz{$r2});
				$pairs_dist{$r1." ".$r2} = $d;
				if ($param_atom_type eq "cb"){
					$pairs_atoms{$r1." ".$r2} = "".return_cb_or_ca_atom($r1)." ".return_cb_or_ca_atom($r2);
				}
				else{
					$pairs_atoms{$r1." ".$r2} = "CA CA";
				}
			}
		}
		if ($flg_atoms_not_dist){
			return %pairs_atoms;
		}
		append2log("Returning ".(scalar keys %pairs_dist)." rows for $file_pdb at separation $separation");
		return %pairs_dist;
	}
	else{
		%xyz = xyz_pdb($file_pdb, "ALL");
		foreach my $row1(keys %xyz){
			my @row1 = split /\s+/, $row1;
			my $res1 = $row1[0];
			my $atm1 = $row1[1];
			if ($param_atom_type eq "heavyatoms"){
				next if not ($atm1 eq "N" or $atm1 eq "CA" or $atm1 eq "C" or $atm1 eq "O");
			}
			foreach my $row2(keys %xyz){
				my @row2 = split /\s+/, $row2;
				my $res2 = $row2[0];
				my $atm2 = $row2[1];
				if ($param_atom_type eq "heavyatoms"){
					next if not ($atm2 eq "N" or $atm2 eq "CA" or $atm2 eq "C" or $atm2 eq "O");
				}
				next if $res1 >= $res2;
				next if abs($res1 - $res2) < $separation;
				my $d = calc_dist($xyz{$row1}, $xyz{$row2});
				if (not defined $pairs_dist{$res1." ".$res2}){
					$pairs_dist{$res1." ".$res2} = $d;
					$pairs_atoms{$res1." ".$res2} = "$atm1 $atm2" if $flg_atoms_not_dist;
				}
				if ($pairs_dist{$res1." ".$res2} > $d){
					$pairs_dist{$res1." ".$res2} = $d;
					$pairs_atoms{$res1." ".$res2} = "$atm1 $atm2" if $flg_atoms_not_dist;
				}
			}
		}
		if($flg_atoms_not_dist){
			return %pairs_atoms;
		}
		append2log("Returning ".(scalar keys %pairs_dist)." rows for $file_pdb at separation $separation");
		return %pairs_dist;
	}
}

sub xyz_pdb{
	my $chain = shift;
	my $atom_selection = shift; # ca or cb or all/any
	$atom_selection = "all" if $atom_selection eq "any";
	confess "\nERROR! file $chain does not exist!" if not -f $chain;
	confess "\nERROR! Selection must be ca or cb or all or heavyatoms" if not (uc($atom_selection) eq "CA" or uc($atom_selection) eq "ALL" or uc($atom_selection) eq "CB" or uc($atom_selection) eq "HEAVYATOMS");
	my %xyz_pdb = ();
	open CHAIN, $chain or confess $!;
	while(<CHAIN>){
		next if $_ !~ m/^ATOM/;
		$xyz_pdb{"".parse_pdb_row($_,"rnum")." ".parse_pdb_row($_,"aname")} = "".parse_pdb_row($_,"x")." ".parse_pdb_row($_,"y")." ".parse_pdb_row($_,"z");
	}
	close CHAIN;
	confess "\nERROR!: xyz_pdb is empty\n" if (not scalar keys %xyz_pdb);
	if (uc($atom_selection) eq "ALL"){
		return %xyz_pdb;
	}
	elsif (uc($atom_selection) eq "HEAVYATOMS"){
		foreach (sort keys %xyz_pdb){
			my @C = split /\s+/, $_;
			if (not($C[1] eq "N" or $C[1] eq "CA" or $C[1] eq "C" or $C[1] eq "O")){
				delete $xyz_pdb{$_};
			}
		}
		return %xyz_pdb;
	}
	my %native_res_list = res_num_res_name($chain);
	my %selected_xyz = ();
	foreach (sort keys %xyz_pdb){
		my @C = split /\s+/, $_;
		my $atom_of_interest = uc($atom_selection);
		$atom_of_interest = "CA" if $native_res_list{$C[0]} eq "GLY";
		# Some pdb files have errors. Non-gly residues do not have CB atoms.
		# For instance, http://sysbio.rnet.missouri.edu/coneva2/preloaded_data/fragfold/native/1ej8A_reindexed.pdb
		# Need to throw errors in such cases.
		error_exit("The pdb file $native_pdb does not have CB atom for residue ".$C[0]."! Try assessing CA-contacts instead!") if not defined $xyz_pdb{$C[0]." ".$atom_of_interest};
		next if $C[1] ne $atom_of_interest;
		$selected_xyz{$C[0]} = $xyz_pdb{$_};
	}
	confess "\nERROR! Empty xyz coordinates in the pdb file!" if not scalar keys %selected_xyz;
	return %selected_xyz;
}

sub parse_pdb_row{
	my $row = shift;
	my $param = shift;
	my $result;
	$result = substr($row,6,5) if ($param eq "anum");
	$result = substr($row,12,4) if ($param eq "aname");
	$result = substr($row,16,1) if ($param eq "altloc");
	$result = substr($row,17,3) if ($param eq "rname");
	$result = substr($row,22,5) if ($param eq "rnum");
	$result = substr($row,26,1) if ($param eq "insertion");
	$result = substr($row,21,1) if ($param eq "chain");
	$result = substr($row,30,8) if ($param eq "x");
	$result = substr($row,38,8) if ($param eq "y");
	$result = substr($row,46,8) if ($param eq "z");
	confess "Invalid row[$row] or parameter[$param]" if (not defined $result);
	$result =~ s/\s+//g;
	return $result;
}

sub res_num_res_name{
	my $chain = shift;
	confess "ERROR! file $chain does not exist!" if not -f $chain;
	my %rnum_rname = ();
	open CHAIN, $chain or confess $!;
	while(<CHAIN>){
		next if $_ !~ m/^ATOM/;
		$rnum_rname{parse_pdb_row($_,"rnum")} = parse_pdb_row($_,"rname");
	}
	close CHAIN;
	confess ":(" if not scalar keys %rnum_rname;
	return %rnum_rname;
}

sub calc_dist{
	my $x1y1z1 = shift;
	my $x2y2z2 = shift;
	my @row1 = split(/\s+/, $x1y1z1);
	my $x1 = $row1[0]; my $y1 = $row1[1]; my $z1 = $row1[2];
	my @row2 = split(/\s+/, $x2y2z2);
	my $x2 = $row2[0]; my $y2 = $row2[1]; my $z2 = $row2[2];
	my $d = sprintf "%.3f", sqrt(($x1-$x2)**2+($y1-$y2)**2+($z1-$z2)**2);
	return $d;
}

sub return_cb_or_ca_atom{
	my $rnum = shift;
	my $residue = substr $rr_sequence, $rnum - 1, 1;
	confess "rnum not defined!" if not defined $rnum;
	confess "Could not find residue name for $rnum!" if not $residue;
	return "CA" if $residue eq "G";
	return "CB";
}

sub seq_fasta{
	my $file_fasta = shift;
	confess "ERROR! Fasta file $file_fasta does not exist!" if not -f $file_fasta;
	my $seq = "";
	open FASTA, $file_fasta or confess $!;
	while (<FASTA>){
		next if (substr($_,0,1) eq ">");
		chomp $_;
		$_ =~ tr/\r//d; # chomp does not remove \r
		$seq .= $_;
	}
	close FASTA;
	return $seq;
}

sub append2log{
	my $row = shift;
	print2file($file_log, $row);
}

sub print2file{
	my $file = shift;
	my $message = shift;
	my $newline = shift;
	$newline = "\n" if not defined $newline;
	if (-f $file){
		open  FILE, ">>$file" or confess $!;
		print FILE $message."".$newline;
		close FILE;
	}
	else{
		open  FILE, ">$file" or confess $!;
		print FILE $message."".$newline;
		close FILE;
	}
}

sub pdb2rr{
	my $chain = shift;
	my $rr = shift;
	my $seq_separation = shift;
	my $d_threshold = shift;
	my $param_atom_type = shift;
	confess "ERROR! file $chain does not exist!" if not -f $chain;
	my %contacts_pdb = ();
	my %xyz = xyz_pdb($chain, $param_atom_type);
	confess "\nERROR!! No xyz for any residues in $chain!" if not scalar keys %xyz;
	if (uc($param_atom_type) eq "CA" or uc($param_atom_type) eq "CB"){
		foreach my $r1 (sort keys %xyz){
			foreach my $r2 (sort keys %xyz){
				next if ($r1 >= $r2);
				next if (abs($r2 - $r1) < $seq_separation);
				if ($param_cont_type eq "short"){
					next if (abs($r2 - $r1) > $short_range_max);
				}
				if ($param_cont_type eq "medium"){
					next if (abs($r2 - $r1) > $medium_range_max);
				}
				my $d = calc_dist($xyz{$r1}, $xyz{$r2});
				# Making < $d_threshold and not <= because that is how CASP defines it
				if ($d < $d_threshold){
					$contacts_pdb{"$r1 $r2"} = sprintf "%.3f", $d;
				}
			}
		}
	}
	else{
		foreach my $row1(keys %xyz){
			my @row1 = split /\s+/, $row1;
			my $res1 = $row1[0];
			my $atm1 = $row1[1];
			if ($param_atom_type eq "heavyatoms"){
				next if not ($atm1 eq "N" or $atm1 eq "CA" or $atm1 eq "C" or $atm1 eq "O");
			}
			foreach my $row2(keys %xyz){
				my @row2 = split /\s+/, $row2;
				my $res2 = $row2[0];
				my $atm2 = $row2[1];
				if ($param_atom_type eq "heavyatoms"){
					next if not ($atm2 eq "N" or $atm2 eq "CA" or $atm2 eq "C" or $atm2 eq "O");
				}
				next if $res1 >= $res2;
				next if abs($res1 - $res2) < $seq_separation;
				my $d = calc_dist($xyz{$row1}, $xyz{$row2});
				if ($d < $d_threshold){
					$contacts_pdb{"$res1 $res2"} = sprintf "%.3f", $d;
				}
			}
		}
	}
	open RR, ">$rr" or confess $!;
	print RR "".seq_chain_with_gaps($chain)."\n";
	confess "Sorry! There are no such contacts [in $chain] that can be analyzed!</br>Please try assessing ALL instead of LONG-RANGE! That may help!" if not scalar keys %contacts_pdb;
	error_exit("Sorry! There are no such contacts [in $chain] that can be analyzed!</br>Please try assessing ALL instead of LONG-RANGE! That may help!") if not scalar keys %contacts_pdb;
	foreach (sort keys %contacts_pdb){
		print RR "$_ 0 $d_threshold ".$contacts_pdb{$_}."\n";
	}
	close RR;
}

sub seq_chain_with_gaps{
	my $chain = shift;
	my $flag = shift; # flag 1 if the left side dashes of the sequence are not wanted
	confess "ERROR! file $chain does not exist!" if not -f $chain;
	my $start = 1;
	# if flagged, keep start for trimming
	if (defined $flag){
		open CHAIN, $chain or confess $!;
		while(<CHAIN>){
			next if $_ !~ m/^ATOM/;
			if (parse_pdb_row($_,"rname") eq "GLY"){
				next if parse_pdb_row($_,"aname") ne "CA";
			}
			else{
				next if parse_pdb_row($_,"aname") ne "CB";
			}
			confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $chain! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
			$start = parse_pdb_row($_,"rnum");
			last;
		}
		close CHAIN;
	}
	# 1.find end residue number
	my $end;
	open CHAIN, $chain or confess $!;
	while(<CHAIN>){
		next if $_ !~ m/^ATOM/;
		if (parse_pdb_row($_,"rname") eq "GLY"){
			next if parse_pdb_row($_,"aname") ne "CA";
		}
		else{
			next if parse_pdb_row($_,"aname") ne "CB";
		}
		confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $chain! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
		$end = parse_pdb_row($_,"rnum");
	}
	close CHAIN;
	# 2.initialize
	my $seq = "";
	for (my $i = 1; $i <= $end; $i++){
		$seq .= "-";
	}
	# 3.replace with residues
	open CHAIN, $chain or confess $!;
	while(<CHAIN>){
		next if $_ !~ m/^ATOM/;
		if (parse_pdb_row($_,"rname") eq "GLY"){
			next if parse_pdb_row($_,"aname") ne "CA";
		}
		else{
			next if parse_pdb_row($_,"aname") ne "CB";
		}
		confess "ERROR!: ".parse_pdb_row($_,"rname")." residue not defined! \nFile: $chain! \nLine : $_" if (not defined $AA3TO1{parse_pdb_row($_,"rname")});
		my $rnum = parse_pdb_row($_,"rnum");
		$rnum =~ s/[A-G]//g;
		substr $seq, ($rnum - 1), 1, $AA3TO1{parse_pdb_row($_,"rname")};
	}
	close CHAIN;
	confess "$chain has less than 1 residue!" if (length($seq) < 1);
	return (substr $seq, $start - 1);
}

sub rrfile_to_r1r2hash{
	my $file_rr = shift;
	my $seq_sep = shift;
	my $count = shift;
	$seq_sep = 1 if not defined $seq_sep;
	$count = 1000000 if not defined $count;
	confess ":(" if not -f $file_rr;
	my %contacts = ();
	open RR, $file_rr or confess $!;
	while(<RR>){
		next unless ($_ =~ /[0-9]/);
		$_ =~ s/^\s+//;
		next unless ($_ =~ /^[0-9]/);
		my @C = split(/\s+/, $_);
		confess "ERROR! Expecting a pair in row [".$_."]!\n" if (not defined $C[0] || not defined $C[1]);
		next if (abs($C[1] - $C[0]) < $seq_sep);
		if(defined $C[4]){
			$contacts{$C[0]." ".$C[1]} = $C[4];
		}
		elsif(defined $C[2] && $C[2] != 0){
			$contacts{$C[0]." ".$C[1]} = $C[2];
		}
		else{
			confess "ERROR! Confidence column not defined in row [".$_."] in file $file_rr!\n";
		}
		last if (scalar keys %contacts) == $count;
	}
	close RR;
	return %contacts;
}
