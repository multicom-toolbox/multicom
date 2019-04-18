#! /usr/bin/perl -w
use Cwd 'abs_path';
use FileHandle;
if(@ARGV <3 or @ARGV >5)
{
	die "The number of parameter is not correct!\n";
}

$targetname = $ARGV[0];
$fasta_seq = abs_path($ARGV[1]);
$dir_output = abs_path($ARGV[2]);
$contact_file = $ARGV[3]; # optional
$fragmentdir = $ARGV[4]; # optional


$Rosetta_starttime = time();

$rosetta_install_dir='/home/casp13/tools/rosetta_bin_linux_2018.09.60072_bundle';
$output_prefix_name='Rosetta_dncon2';
$final_model_number=5;
if(!defined($contact_file))
{
	$contact_file='None';
}

if(!(-d $dir_output))
{
	`mkdir $dir_output`;
}

my($ren_dncon2_features)=$dir_output."/dncon2";
if(!(-d $ren_dncon2_features))
{
	`mkdir $ren_dncon2_features`;
}


if($contact_file ne 'None')
{
	print "Detecting contact file $contact_file, validating......\n\n";
	
	if(-e $contact_file)
	{
		`cp $contact_file $ren_dncon2_features/$targetname.dncon2.rr`;
	}
}
$dncon2_starttime = time();
$res = "$dir_output/dncon2.is_running";
if(-e "$ren_dncon2_features/$targetname.dncon2.rr")
{
	print "$ren_dncon2_features/$targetname.dncon2.rr generated!\n\n";
}else{
   
   $cmd = "/home/casp13/DNCON2/dncon2-v1.0.sh  $fasta_seq  $ren_dncon2_features";
   $OUT = new FileHandle ">$res";
   print $OUT "1. generating dncon2 score\n   $cmd \n\n";
   print  "1. generating dncon2 score\n   $cmd \n\n";
   $OUT->close();
   $ren_return_val=system("$cmd &>> $res");
	if ($ren_return_val)
	{
		$dncon2_finishtime = time();
		$dncon2_diff_hrs = ($dncon2_finishtime - $dncon2_starttime)/3600;
		print "1. dncon2 modeling finished within $dncon2_diff_hrs hrs!\n\n";
		
		system("mv $dir_output/dncon2.is_running $dir_output/dncon2.is_finished");
		open(TMP,">>$dir_output/dncon2.is_finished");
		print TMP "ERROR! dncon2 execution <$cmd> failed!\n";
		print TMP "dncon2 modeling finished within $dncon2_diff_hrs hrs!\n\n";
		close TMP;				
		print "ERROR! dncon2 execution failed!";
		exit 0;
	}
	print "$ren_dncon2_features/$targetname.dncon2.rr generated!\n\n"; 
	$dncon2_finishtime = time();
	$dncon2_diff_hrs = ($dncon2_finishtime - $dncon2_starttime)/3600;
	system("mv $dir_output/dncon2.is_running $dir_output/dncon2.is_finished");
	open(TMP,">>$dir_output/dncon2.is_finished");
	print TMP "dncon2 modeling finished within $dncon2_diff_hrs hrs!\n\n";
	close TMP;			
}


my($ren_rosetta_dir)=$dir_output."/rosetta_results_${targetname}_shortL";
if(!(-d $ren_rosetta_dir))
{
	`mkdir $ren_rosetta_dir`;
	`mkdir $ren_rosetta_dir/abini`;
}

if(-e "$fragmentdir/abini/aaabini03_05.200_v1_3" and -e "$fragmentdir/abini/aaabini09_05.200_v1_3")
{
	print "Found existing rosetta fragments, copying\n\n";
	`cp $fragmentdir/abini/aaabini03_05.200_v1_3 $ren_rosetta_dir/abini`;
	`cp $fragmentdir/abini/aaabini09_05.200_v1_3  $ren_rosetta_dir/abini`;
}

#source /home/casp13/python_virtualenv/bin/activate
#print "1. Converting dncon2 format\nperl /home/casp13/dncon2-Rosetta/scripts/P1_convert_dncon2evfold.pl $ren_dncon2_features/$targetname.dncon2.rr $fasta_seq $ren_dncon2_features/$targetname.dncon2.rr2evfold.rr\n\n";
#`perl /home/casp13/dncon2-Rosetta/scripts/P1_convert_dncon2evfold.pl $ren_dncon2_features/$targetname.dncon2.rr $fasta_seq $ren_dncon2_features/$targetname.dncon2.rr2evfold.rr`;

#$PROTOCOL="$rosetta_install_dir/demos/protocol_capture/rasrec_evolutionary_restraints";


#print "2. Generating dncon2 contact map\nperl /home/casp13/dncon2-Rosetta/scripts/P1_convert_dncon2evfold.pl $ren_dncon2_features/$targetname.dncon2.rr $fasta_seq $ren_dncon2_features/$targetname.dncon2.rr2evfold.rr\n\n";
#`$PROTOCOL/scripts/create_evfold_contactmap.py -i $ren_dncon2_features/$targetname.dncon2.rr2evfold.rr -f $fasta_seq -o $ren_dncon2_features/$targetname.dncon2.cmp`;


#print "3. Generating dncon2 constraints\n$PROTOCOL/scripts/extract_top_cm_restraints.py $ren_dncon2_features/$targetname.dncon2.cmp  -r_fasta $fasta_seq -r_num_perc  5.0 -r_f  BOUNDED -r_ub 8  -r_lb 3.5 -r_atom CB -o $ren_dncon2_features/$targetname.dncon2.contact.cst\n\n";
#`$PROTOCOL/scripts/extract_top_cm_restraints.py $ren_dncon2_features/$targetname.dncon2.cmp  -r_fasta $fasta_seq -r_num_perc  5.0 -r_f  BOUNDED -r_ub 8  -r_lb 3.5 -r_atom CB -o $ren_dncon2_features/$targetname.dncon2.contact.cst`;

chdir($ren_dncon2_features);
print "1. Filtering dncon2 \nperl /home/casp13/dncon2-Rosetta/scripts/convea_range_resultv2.pl -rr $targetname.dncon2.rr  -fasta $fasta_seq  -smin 6 -smax 11 -top L\n";
`perl /home/casp13/dncon2-Rosetta/scripts/convea_range_resultv2.pl -rr $targetname.dncon2.rr  -fasta $fasta_seq  -smin 6 -smax 11 -top L`;


print "2. Generating dncon2 constraints\nperl /home/casp13/dncon2-Rosetta/scripts/P1_convert_dncon2constraints.pl $targetname-Short-range-L.rr.raw  $fasta_seq $targetname.rr.shortL.contact.cst 3.5 8\n";
`perl /home/casp13/dncon2-Rosetta/scripts/P1_convert_dncon2constraints.pl $targetname-Short-range-L.rr.raw  $fasta_seq $targetname.rr.shortL.contact.cst 3.5 8`;



if(!(-e "$targetname.rr.shortL.contact.cst"))
{
	die "Failed to generate $targetname.rr.shortL.contact.cst\n\n";
}
#$PROTOCOL/scripts/extract_top_cm_restraints.py T0579.cmp  -r_fasta T0579.fasta -r_num_perc 5.0 -r_f  SIGMOID -r_atom CB

chdir($ren_rosetta_dir);
if(-e "$ren_rosetta_dir/abini/aaabini03_05.200_v1_3" and -e "$ren_rosetta_dir/abini/aaabini09_05.200_v1_3")
{
	print "4. Found existing rosetta fragments\n\n";
}else{
	print "4. Generating rosetta fragments\n/home/casp13/dncon2-Rosetta/scripts/make_rosetta_fragment.sh $fasta_seq abini $ren_rosetta_dir 100  &>> $dir_output/runRosetta.log\n\n";
	`/home/casp13/dncon2-Rosetta/scripts/make_rosetta_fragment.sh $fasta_seq abini $ren_rosetta_dir 100  &>> $dir_output/runRosetta.log`;
}
#(need discuss which nr database use in make_fragment.pl)

print "5. Running rosetta with contact constraints\n/home/casp13/dncon2-Rosetta/scripts/run_rosetta_no_fragment_withContact.sh $fasta_seq abini $ren_rosetta_dir   100 $ren_dncon2_features/$targetname.rr.shortL.contact.cst &>> $dir_output/runRosetta.log\n\n";
`/home/casp13/dncon2-Rosetta/scripts/run_rosetta_no_fragment_withContact.sh $fasta_seq abini $ren_rosetta_dir   100 $ren_dncon2_features/$targetname.rr.shortL.contact.cst &>> $dir_output/runRosetta.log`;



####### 6. Running clustering to select top5 models
print "\n6. Running clustering to select top5 models\n\n";

$modelnum=0;	

## record the model list 
%all_model = ();
opendir(DIR,"$ren_rosetta_dir/abini/");
@models = readdir(DIR);
closedir(DIR);
open(OUT,">$ren_rosetta_dir/model.list") || die "Failed to open file $ren_rosetta_dir/model.list\n";
foreach $file (@models)
{
	chomp $file;
	if ($file ne '.' and $file ne '..'  and index($file,'.pdb')>=0)
	{
		$modelnum++;
		$all_model{$file} = 1;
		print OUT "$ren_rosetta_dir/abini/$file\n";
	}
}
close OUT;
if($modelnum == 0)
{
	die "No model is generated in <$ren_rosetta_dir/abini/>\n\n";
}else{
	print "Total $modelnum models are found for QA analysis\n";
}
### running maxcluster 
if(-d "$ren_rosetta_dir/maxcluster")
{
	`rm -rf $ren_rosetta_dir/maxcluster/*`;
}else{
	`mkdir $ren_rosetta_dir/maxcluster/`;
}
$clusternum = int($modelnum/5);
$maxcluster_score_file = $ren_rosetta_dir.'/maxcluster/'.$targetname.'.maxcluster_results';
print("/home/casp13/Confold2-Unicon3D/UniCon3D/maxcluster64bit -l  $ren_rosetta_dir/model.list -ms 5 -C 5 -is $clusternum  > $maxcluster_score_file\n");
system("/home/casp13/Confold2-Unicon3D/UniCon3D/maxcluster64bit -l  $ren_rosetta_dir/model.list -ms 5 -C 5 -is $clusternum  > $maxcluster_score_file"); 

if(!(-e $maxcluster_score_file))
{
	die "maxcluster score $maxcluster_score_file can't not be generated\n";
}

$maxcluster_centroid = $ren_rosetta_dir.'/maxcluster/'.$targetname.'.centroids';
system("grep -A 8 \"INFO  : Cluster  Centroid  Size        Spread\" $maxcluster_score_file | grep $targetname > $maxcluster_centroid");

open(CENT,"$maxcluster_centroid") || die "Failed to open file $maxcluster_centroid\n";
my @centroids = <CENT>;
chomp @centroids;
close CENT;

my @pdb_list = ();

if(-d "$ren_rosetta_dir/top_models")
{
	`rm -rf $ren_rosetta_dir/top_models/*`;
}else{
	`mkdir $ren_rosetta_dir/top_models/`;
}

open(OUT,">$ren_rosetta_dir/selected.info") || die "Failed to open file $ren_rosetta_dir/selected.info\n";
for (my $i = 0; $i < $final_model_number; $i++){
        next if not defined $centroids[$i];
        my @C = split /\s+/, $centroids[$i];
        next if not defined $C[7];
        next if not -f $C[7];
        push @pdb_list, $C[7]; 
        print "Added ".$C[7]." to top $final_model_number list\n";
        print OUT "Added ".$C[7]." to top $final_model_number list\n";
		$mod_file = $C[7];
		$indx=($i+1);
		`cp $mod_file $ren_rosetta_dir/top_models/${output_prefix_name}-$indx.pdb`;
		`cp $mod_file $ren_rosetta_dir/${output_prefix_name}-$indx.pdb`;
}

print "\n";
print OUT "\n";
print "Rank the ".@pdb_list." models selected [expected = $final_model_number] ..\n";
print OUT "Rank the ".@pdb_list." models selected [expected = $final_model_number] ..\n";
die "Error! Top models could not be found!" if scalar(@pdb_list) < 1;

close OUT;


$Rosetta_finishtime = time();
$full_diff_hrs = ($Rosetta_finishtime - $Rosetta_starttime)/3600;
print "\n####### Rosetta-dncon2 modeling finished within $full_diff_hrs hrs!\n\n";

