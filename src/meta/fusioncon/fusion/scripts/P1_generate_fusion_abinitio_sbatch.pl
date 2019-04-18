$numArgs = @ARGV;
if($numArgs != 4)
{
        print "the number of parameters is not correct!\n";
        exit(1);
}

$fasta_dir         = "$ARGV[0]"; #/storage/htc/bdm/Collaboration/CASP13/dncon2_Rosetta_experiments/Fasta/
$rr_dir       = "$ARGV[1]"; #/storage/htc/bdm/Collaboration/CASP13/dncon2_Rosetta_experiments/DNCON2-Filtered/
$outfolder      = "$ARGV[2]"; #/storage/htc/bdm/Collaboration/CASP13/dncon2_Rosetta_experiments/Jie_run/run_L
$sbatch_folder  = "$ARGV[3]"; #/storage/htc/bdm/Collaboration/CASP13/dncon2_Rosetta_experiments/Jie_run/run_L/shortL_sbatch


opendir(DIR,"$fasta_dir") || die "Failed to open directory $fasta_dir\n\n";
@files = readdir(DIR);
closedir(DIR);

$c=0;
foreach $file (@files)
{
  chomp $file;
  if($file eq '.' or $file eq '..' or index($file,'.fasta') <0)
  {
      next;
  }
  
  $targetid = substr($file,0,index($file,'.fasta'));
  
  
  $fastafile = "$fasta_dir/$targetid.fasta";
  $rrfile = "$rr_dir/$targetid.rr";
  
  $work_dir = "$outfolder/$targetid";
  
  
  if(!(-e $fastafile) or !(-e $rrfile))
  {
  	die "Failed to find $fastafile,$rrfile\n\n";
  	
  }


	$c++;
	$runfile="$sbatch_folder/P1_run_sbatch_$c.sh";
	print "Generating $runfile\n";
	open(SH,">$runfile") || die "Failed to write $runfile\n";
	print SH "#!/bin/bash -l\n";
	print SH "#SBATCH -J  P1_rose_$c\n";
	print SH "#SBATCH -o P1_rose_$c-%j.out\n";
	print SH "#SBATCH -p Lewis\n";
	print SH "#SBATCH -N 1\n";
	print SH "#SBATCH -n 1\n";
	print SH "#SBATCH --mem 10G\n";
	print SH "#SBATCH -t 1-20:00:00\n";
	print SH "mkdir $work_dir\n";
	print SH "cd $work_dir\n\n";
	print SH "/home/casp13/fusion/scripts/Fusion_Abinitio_with_contact.sh   --target  $targetid    --fasta $fastafile   --email jh7x3\@mail.missouri.edu --dir  $work_dir  --timeout  10  --cpu 5 --decoy 100 --model  5 &> runFusion_$targetid.log\n\n";
	close SH;


}
  
