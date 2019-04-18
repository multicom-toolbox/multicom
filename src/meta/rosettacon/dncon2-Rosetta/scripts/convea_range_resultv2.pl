use Carp;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
use File::Temp qw(tempfile);

# User inputs
my ($in_rr, $in_fasta,$topL,$min_seq_sep, $max_seq_sep);

GetOptions(
  "rr=s"	=> \$in_rr,
  "fasta=s" => \$in_fasta,
  "smin=i"=> \$min_seq_sep,
  "smax=i"=> \$max_seq_sep,
  "top=s" => \$topL)
or confess "ERROR! Error in command line arguments!";

if (not -f $in_rr){
	print "\nERROR!! RR file $in_rr does not exist!!\n";
	print_usage()
}

if (not -f $in_fasta){
	print "\nERROR!! RR file $in_fasta does not exist!!\n";
	print_usage()
}

my $seq_id = basename($in_rr);
$seq_id =~ s/\.[^.]+$//;
$seq_id =~ s/\.[^.]+$//;
my $output_folder = dirname($in_rr);
#$output_folder =~ s/\/[^\/]+$//;
#print "$seq_id $output_folder\n";

# Defaults
$atom_type    = "cb"  if !$atom_type;
$d_threshold  = 8.0   if !$d_threshold;
$max_seq_sep  = 10000 if !$max_seq_sep;
$min_seq_sep  = 24    if !$min_seq_sep;
my $range;

if($min_seq_sep == 24 && $max_seq_sep == 10000){
  $range="Long-range";
}

if(($min_seq_sep == 12) && ($max_seq_sep == 23)){
  $range="Medium-range";
}

if($min_seq_sep == 6 && $max_seq_sep == 11){
  $range="Short-range";
}

# Load top contact subsets
my %top_count       = ();
my %top_count_order = ();

my $seq = seq_fasta($in_fasta);

 # use fasta file Length as reference
$top_count{"5"}  = 5;
$top_count{"L10"} = int(0.1 * length($seq) + 0.5);
$top_count{"L5"}  = int(0.2 * length($seq) + 0.5);
$top_count{"L2"}  = int(0.5 * length($seq) + 0.5);
$top_count{"L"}    = length($seq);
$top_count{"2L"}   = int(2.0 * length($seq));
$top_count{"ALL"}  = 100000 if $flag_show_all;
$top_count_order{"5"}    = 1;
$top_count_order{"L10"} = 2;
$top_count_order{"L5"}  = 3;
$top_count_order{"L2"}  = 4;
$top_count_order{"L"}    = 5;
$top_count_order{"2L"}   = 6;
$top_count_order{"ALL"}  = 7;
# print Dumper(\%top_count);
# print Dumper(\%top_count_order);

# Load all contacts to be assessed (including pdb contacts)
my @rr_list = ();
if ($in_rr){
  if (-d $in_rr){
    @rr_list = load_rr($in_rr);
  }
  elsif (-f $in_rr){
    push @rr_list, $in_rr;
  }
}
#print join("\n",@rr_list),"\n";

# Load contacts into memory
my %all_rr;
my $base_rr;
foreach my $rr (@rr_list){
  my %rr_needed = rr_rank_rows_hash($rr, 100000);
  $all_rr{"".basename($rr)." ALL"} = \%rr_needed;
}
foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
  #print $top." ".$top_count{"$top"}."\n";
  foreach my $rr (@rr_list){
   #print "$top_count{$top}\n";
    my %rr_needed = rr_rank_rows_hash($rr, $top_count{$top});
    $all_rr{"".basename($rr)." ".$top} = \%rr_needed;
    $base_rr=basename($rr);
  }
}
my %all_rr_above_thres_conf;
foreach my $rr (@rr_list){
  my %rr_selected = rr_rank_rows_hash($rr, 100000, 0.5);
  $all_rr_above_thres_conf{"".basename($rr)} = \%rr_selected;
}
 #print Dumper(\%all_rr);
 #print Dumper(\%all_rr_above_thres_conf);

open TEMP, ">$output_folder/${seq_id}-$range-$topL.rr.raw" or confess $!;
while (my ($k,$v)=each(%{$all_rr{"".$base_rr." ".$topL}})){
  print TEMP "$v\n";
}
close TEMP;
#print Dumper(\$all_rr{"".$base_rr." "."L/5"});


# Contact counts
# print "PDB     : $in_pdb_file\n";
# print "RR      : $in_rr\n" if $in_rr;
# print "L       : ".length(seq_chain($in_pdb_file))." (pdb's chain length without gaps)\n";
# print "Nc      : ".(scalar keys %pdb_cont_dist)." (pdb's contact count)\n";
# print "Seq Sep : $min_seq_sep to ".(($max_seq_sep == 10000) ? "INF": $max_seq_sep)."\n";
# print "PDB-Seq : ".seq_chain_with_gaps($in_pdb_file)."\n";
# print "\n";
# printf "%-30s", "CONTACT-COUNTS";
# foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
  # next if $top eq "5";
  # next if $top eq "ALL";
  # $top = "Top-$top";
  # printf "%-10s", $top;
# }
# printf "%-10s", "ALL";
# print "\n";

# foreach my $rr (sort @rr_list){
  # printf "%-30s", "".basename($rr)." (count)";
  # foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
    # next if $top eq "5";
    # next if $top eq "ALL";
    # my %this_rr = %{$all_rr{"".basename($rr)." ".$top}};
    # printf "%-10s", (scalar keys %this_rr);
  # }
  # my %this_rr = %{$all_rr{"".basename($rr)." ALL"}};
  # printf "%-10s", (scalar keys %this_rr);
  # print "\n";
# }

# if ((scalar keys %pdb_cont_dist) < 1){
  # print "\nERROR!\n";
  # print "Number of true contacts in the pdb file is 0! Quitting..\n";
  # exit 1;
# }

# # Precision
# print "\n";
# printf "%-30s", "PRECISION";
# foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
  # $top = "Top-$top" if $top ne "ALL";
  # printf "%-10s", $top;
# }
# print "\n";

# open TEMP, ">>$output_folder/${seq_id}.EVA" or confess $!;
# foreach my $rr (sort @rr_list){
  # printf "%-30s", "".basename($rr)." (precision)";
  # foreach my $top (sort {$top_count{$a} <=> $top_count{$b}} keys %top_count){
    # my %this_rr = %{$all_rr{"".basename($rr)." ".$top}};
    # printf "%-10s", calc_precision(\%this_rr);
    # if($top eq "L/5"){
      # my $cal_pre=basename($rr)."-".$range."-".calc_precision(\%this_rr);
      # print TEMP "$cal_pre\n";
    # }
  # }
  # close TEMP;
  # print "\n";
# }

sub calc_precision{
  my $rrhash = shift;
  my %rr = %{$rrhash};
  confess "Cannot calculate precision! Empty selected contacts" if not scalar keys %rr;
  my %distances = rrhash2dist(\%rr, \%pdb_dist);
  #print Dumper(\%distances);
  confess "Distances could not be calculated for selected contacts! Something went wrong!" if not scalar keys %distances;
  my $satisfied = 0;
  foreach (sort {$distances{$a} <=> $distances{$b}}keys %distances){
    my @R = split /\s+/, $_;
    $satisfied++ if $distances{$_} <= $R[3];
  }
  return sprintf "%.2f", 100 * ($satisfied/(scalar keys %distances));
}

sub rrhash2dist{
  # Empty input returns empty output
  my $rrhash = shift;
  my %rr_hash = %{$rrhash};
  my %output = ();
  foreach (keys %rr_hash){
    my @C = split /\s+/, $rr_hash{$_};
    next if not defined $pdb_dist{$C[0]." ".$C[1]};
    $output{$rr_hash{$_}} = $pdb_dist{$C[0]." ".$C[1]};
  }
  return %output;
}

sub system_cmd{
  my $command = shift;
  confess "EXECUTE [$command]" if (length($command) < 5  and $command =~ m/^rm/);
  system($command);
  if($? != 0){
    my $exit_code  = $? >> 8;
    confess "Failed executing [$command]!<br>ERROR: $!";
  }
}

sub sort_rr_file_by_confidence{
  my $file_rr = shift;
  confess "No File RR!" if not -f $file_rr;
  my $seq = undef;
  if(rr_has_seq($file_rr)){
    $seq = seq_rr($file_rr);
  }
  my ($rr_sorted_fh, $rr_sorted_file) = tempfile();
  system_cmd("rm -f $rr_sorted_file");
  # Keep contact rows only
#system_cmd("sed -i '/^[A-Z]/d' $file_rr");
#system_cmd("sed -i '/^-]/d' $file_rr");
  # Some files have leading white spaces
#system_cmd("sed -i 's/^ *//' $file_rr");
  # Stable sort with -s option, i.e. maintain order in case confidence are equal
  # Also using -g option instead of -n because some predictors have exponential values in confidence
  system_cmd("sort -gr -s -k5 $file_rr > $rr_sorted_file");
  system_cmd("rm -f $file_rr");
  system_cmd("cat $rr_sorted_file >> $file_rr");
  system_cmd("rm -f $rr_sorted_file");
}

sub rr_rank_rows_hash{
  my $file_rr    = shift;
  my $count      = shift;
  my $conf_thres = shift;
  confess "Input file not defined" if not defined $file_rr;
  confess "Input file $file_rr does not exist!" if not -f $file_rr;
  confess "No contact count!" if not defined $count;
  my ($rr_temp_fh, $rr_temp_file) = tempfile();
  system_cmd("cp $file_rr $rr_temp_file");
  sort_rr_file_by_confidence($rr_temp_file);
  my %rr = ();
  my $i = 1;
  open RR, $rr_temp_file or confess $!;
  while(<RR>){
    my $row = $_;
    next unless $row =~ /[0-9]/;
    chomp $row;
    $row =~ s/\r//g;
    $row =~ s/^\s+//;
    next unless $row =~ /^[0-9]/;
    my @C = split /\s+/, $row ;
    confess "Expecting a pair in row [".$row."]!\n" if (not defined $C[0] || not defined $C[1]);
    confess "Confidence column not defined in row [".$row."] in file $file_rr!\nPlease make sure that the input RR file is in 5-column format!" if not defined $C[4];
    # Skip if native does not have the residue
    # next if not defined $pdb_rnum_rname{$C[0]};
    # next if not defined $pdb_rnum_rname{$C[1]};
    # Smaller residue number should come first
    $row = $C[1]." ".$C[0]." ".$C[2]." ".$C[3]." ".$C[4] if $C[0] > $C[1];
    if (defined $conf_thres){
      next if $C[4] < $conf_thres;
    }
    # Select only LR, MR, SR or all
    my $d = abs($C[0]-$C[1]);
    next if $d < $min_seq_sep;
    next if $d > $max_seq_sep;
    $rr{$i} = $row;
    $i++;
    last if $i > $count;
  }
  close RR;
  system_cmd("rm -f $rr_temp_file");
  return %rr;
}

sub seq_rr{
  my $file_rr = shift;
  confess "ERROR! Input file $file_rr does not exist!" if not -f $file_rr;
  my $seq;
  open RR, $file_rr or confess "ERROR! Could not open $file_rr! $!";
  while(<RR>){
    chomp $_;
    $_ =~ s/\r//g; # chomp does not remove \r
    $_ =~ s/^\s+//;
    $_ =~ s/\s+//g;
    next if ($_ =~ /^>/);
    next if ($_ =~ /^PFRMAT/);
    next if ($_ =~ /^TARGET/);
    next if ($_ =~ /^AUTHOR/);
    next if ($_ =~ /^SCORE/);
    next if ($_ =~ /^REMARK/);
    next if ($_ =~ /^METHOD/);
    next if ($_ =~ /^MODEL/);
    next if ($_ =~ /^PARENT/);
    last if ($_ =~ /^TER/);
    last if ($_ =~ /^END/);
    # Now, I can directly merge to RR files with sequences on top
    last if ($_ =~ /^[0-9]/);
    $seq .= $_;
  }
  close RR;
  confess "Input RR file does not have sequence row!</br>RR-file : <b>$file_rr</b></br>Please make sure that all input RR files have sequence headers!" if not defined $seq;
  return $seq;
}

sub rr_has_seq{
  my $file_rr = shift;
  confess "ERROR! Input file $file_rr does not exist!" if not -f $file_rr;
  my $seq;
  open RR, $file_rr or confess "ERROR! Could not open $file_rr! $!";
  while(<RR>){
    chomp $_;
    $_ =~ tr/\r//d; # chomp does not remove \r
    $_ =~ s/^\s+//;
    next if ($_ =~ /^PFRMAT/);
    next if ($_ =~ /^TARGET/);
    next if ($_ =~ /^AUTHOR/);
    next if ($_ =~ /^SCORE/);
    next if ($_ =~ /^REMARK/);
    next if ($_ =~ /^METHOD/);
    next if ($_ =~ /^MODEL/);
    next if ($_ =~ /^PARENT/);
    last if ($_ =~ /^TER/);
    last if ($_ =~ /^END/);
    last if ($_ =~ /^[0-9]/);
    $seq .= $_;
  }
  close RR;
  return 0 if not defined $seq;
  return 1;
}

sub load_rr{
  my $dir_rr = shift;
  confess ":( directory $dir_rr does not exist!" if not -d $dir_rr;
  my @rr_list = ();
  my @all_files = <$dir_rr/*>;
  foreach my $file (@all_files){
    next if length($file) < 2;
    open FILE, $file or confess $!;
    while(<FILE>){
      chomp $_;
      $_ =~ s/\r//g;
      $_ =~ s/^\s+//;
      next unless $_ =~ /^[0-9]/;
      my @C = split /\s+/, $_;
      confess "column 1 not defined in line [$_] in $file" if not defined $C[0];
      confess "column 2 not defined in line [$_] in $file" if not defined $C[1];
      confess "column 3 not defined in line [$_] in $file" if not defined $C[2];
      confess "column 4 not defined in line [$_] in $file" if not defined $C[3];
      confess "column 5 not defined in line [$_] in $file" if not defined $C[4];
      last;
    }
    close FILE;
    push @rr_list, $file;
  }
  confess "ERROR! Directory $dir_rr has no pdb files!\n" unless(@rr_list);
  return @rr_list;
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
  my $seq = shift;
  my $rnum = shift;
  my $residue = substr $seq, $rnum - 1, 1;
  confess "rnum not defined!" if not defined $rnum;
  confess "Could not find residue name for $rnum!" if not $residue;
  return "CA" if $residue eq "G";
  return "CB";
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
  return substr $seq, $start - 1;
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

sub xyz_pdb{
  my $chain = shift;
  confess "\nERROR! file $chain does not exist!" if not -f $chain;
  my %xyz_pdb = ();
  open CHAIN, $chain or confess $!;
  while(<CHAIN>){
    next if $_ !~ m/^ATOM/;
    $xyz_pdb{"".parse_pdb_row($_,"rnum")." ".parse_pdb_row($_,"aname")} = "".parse_pdb_row($_,"x")." ".parse_pdb_row($_,"y")." ".parse_pdb_row($_,"z");
  }
  close CHAIN;
  confess "\nERROR!: xyz_pdb is empty\n" if (not scalar keys %xyz_pdb);
  return %xyz_pdb;
}

####################################################################################################
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

####################################################################################################