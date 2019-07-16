
if (@ARGV != 3)
{
}

$new_dssp_dir = $ARGV[0];
$old_dssp_dir = $ARGV[1];
$outputfile = $ARGV[2];

opendir(DIR,"$new_dssp_dir");

open(OUT,">$outputfile");
@files = readdir(DIR);
closedir(DIR);

foreach $file (@files)
{
  chomp $file;
  if($file eq '.' or $file eq '..' or index($file,'.seq')<0)
  {
    next;
  }
  
  $new_dssp = "$new_dssp_dir/$file";
  $old_dssp = "$old_dssp_dir/$file";
  if(!(-e $old_dssp))
  {
    print "Failed to find $old_dssp\n\n";
    sleep(1);
    next;
  }
  `head -n 7  $new_dssp > $new_dssp.tmp`;
  `head -n 7  $old_dssp > $old_dssp.tmp`;
  
  @compare = `diff $new_dssp.tmp $old_dssp.tmp`;
  if(@compare > 0)
  {
    print "$file has different dssp\n";
    print OUT "$file has different dssp\n";
  }
  
}
close OUT;