
if (@ARGV != 2)
{
}

$new_dssp_dir = $ARGV[0];
$old_dssp_dir = $ARGV[1];

opendir(DIR,"$new_dssp_dir");

open(OUT,">$outputfile");
@files = readdir(DIR);
closedir(DIR);

$rmse = 0;
$file_num = 0;
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
 open(TMP,"$new_dssp");
 @content = <TMP>;
 close TMP;
 $new_acc = $content[9];
 chomp $new_acc;
 
 open(TMP,"$old_dssp");
 @content = <TMP>;
 close TMP;
 $old_acc = $content[9];
 chomp $old_acc;
 
 #print "$old_acc\n$new_acc\n\n";
 
 @old_acc_list = split(/\s/,$old_acc);
 @new_acc_list = split(/\s/,$new_acc);
 
 if(@old_acc_list != @new_acc_list)
 {
   print "$file has mismatch in acc\n";
   next;
 }
 if(@old_acc_list == 0)
 {
   print "$file has non acc\n\n";
   next;
 }
 $mse = 0;
 for($i=0;$i<@old_acc_list;$i++)
 {
     $mse += abs($old_acc_list[$i]-$new_acc_list[$i]);
     
 }
 $mse /= @old_acc_list;
 
 $rmse +=$mse;
  $file_num ++;
  print "$file:  $mse\n";
}


$rmse /=$file_num;

print "Average MAE: $rmse\n\n";