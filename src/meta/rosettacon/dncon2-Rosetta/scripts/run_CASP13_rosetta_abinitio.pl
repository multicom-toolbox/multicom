#! /usr/bin/perl -w
use Cwd 'abs_path';
use FileHandle;
if(@ARGV !=3)
{
	die "The number of parameter is not correct!\n";
}

$targetname = $ARGV[0];
$fasta_seq = abs_path($ARGV[1]);
$dir_output = abs_path($ARGV[2]);


$Rosetta_starttime = time();

$rosetta_install_dir='/home/casp13/tools/rosetta_bin_linux_2018.09.60072_bundle';
$output_prefix_name='Rosetta_abinitio';
$final_model_number=5;


if(!(-d $dir_output))
{
	`mkdir $dir_output`;
}

my($ren_rosetta_dir)=$dir_output."/rosetta_abinitio_$targetname";
if(!(-d $ren_rosetta_dir))
{
	`mkdir $ren_rosetta_dir`;
}

print "1. Generating rosetta fragments\n/home/casp13/dncon2-Rosetta/scripts/make_rosetta_fragment.sh $fasta_seq abini $ren_rosetta_dir 100  &>> $dir_output/runRosetta_abinitio.log\n\n";
`/home/casp13/dncon2-Rosetta/scripts/make_rosetta_fragment.sh $fasta_seq abini $ren_rosetta_dir 100  &>> $dir_output/runRosetta_abinitio.log`;

#(need discuss which nr database use in make_fragment.pl)

print "2. Running rosetta with contact constraints\n/home/casp13/dncon2-Rosetta/scripts/run_rosetta_no_fragment_abinitio.sh $fasta_seq abini $ren_rosetta_dir   100 $ren_dncon2_features/$targetname.dncon2.contact.cst  &>> $dir_output/runRosetta_abinitio.log\n\n";
`/home/casp13/dncon2-Rosetta/scripts/run_rosetta_no_fragment_abinitio.sh $fasta_seq abini $ren_rosetta_dir   100 $ren_dncon2_features/$targetname.dncon2.contact.cst &>> $dir_output/runRosetta_abinitio.log`;



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

