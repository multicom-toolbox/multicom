#!/usr/bin/perl -w

$numArgs = @ARGV;
if($numArgs != 3)
{   
	print "the number of parameters is not correct!\n";
	exit(1);
}

$wordir		= "$ARGV[0]";
$start	= "$ARGV[1]";
$end	= "$ARGV[2]";

chdir($wordir);

for($i=$start;$i<=$end;$i++)
{
  $batchfile = "P1_run_sbatch_$i.sh";
  if(-e $batchfile)
  {
    $found = 0;
    opendir(DIR,$wordir)|| die "Failed to open dir $wordir\n";
    @files = readdir(DIR);
    foreach $file (@files)
    {
      chomp $file;
      if($file eq '.' or $file eq '..' or index($file,'P3_hhm_')<0)
      {
        next;
      }
      if(index($file,"P3_hhm_$i")>=0)
      {
        print "Found existing running file $file, ignore\n";
        $found = 1;
      }
    }
    if($found == 0)
    {
      print "Runnung $batchfile\n";
      #`sbatch $batchfile`;
      `sh $batchfile &`;
      
    }
  }
}

  
  
  
