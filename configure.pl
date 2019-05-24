#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

######################## !!! customize settings here !!! ############################
#																					#
# Set installation directory of multicom to your unzipped multicom directory            #
     
$install_dir = "/your_path/multicom";
######################## !!! End of customize settings !!! ##########################

if($install_dir eq "/your_path/multicom")
{# user forgets to set the default path of multicom, try to solve this problem
    $install_dir = getcwd;
    $install_dir=abs_path($install_dir);
}


if(!-s $install_dir)
{
	die "The multicom directory ($install_dir) is not existing, please revise the customize settings part inside the configure.pl, set the path as  your unzipped multicom directory\n";
}
if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
        $install_dir .= "/";
}

print "checking whether the configuration file run in the installation folder ...";
$cur_dir = `pwd`;
chomp $cur_dir;
$configure_file = "$cur_dir/configure.pl";
if (! -f $configure_file || $install_dir ne "$cur_dir/")
{
        die "\nPlease check the installation directory setting and run the configure program in the installation directory of multicom.\n";
}
print " OK!\n";


################Don't Change the code below##############

if (! -d $install_dir)
{
	die "can't find installation directory.\n";
}
if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
	$install_dir .= "/"; 
}


if (prompt_yn("multicom will be installed into <$install_dir> ")){

}else{
	die "The installation is cancelled!\n";
}
print "Start install multicom into <$install_dir>\n"; 

=pod
#$files		="lib/library.py,scripts/P2_alignment_generation/gen_query_temp_align_proc.pl,software/pspro2/configure.pl,scripts/P1_run_fold_recognition/Analyze_top5_folds.py,scripts/P1_run_fold_recognition/run_multicom_fr.pl,training/P1_evaluate.sh,training/P1_train.sh,training/predict_single.py,training/predict_main.py,training/training_main.py";
$files='src/multicom_ve.pl;src/meta/script/multicom_server_ve.pl;src/meta/script/multicom_server_hard_ve.pl';

@updatelist		=split(/,/,$files);

foreach my $file (@updatelist) {
	$file2update=$install_dir.$file;
	
	$check_log ='GLOBAL_PATH=';
	open(IN,$file2update) || die "Failed to open file $file2update\n";
	open(OUT,">$file2update.tmp") || die "Failed to open file $file2update.tmp\n";
	while(<IN>)
	{
		$line = $_;
		chomp $line;

		if(index($line,$check_log)>=0)
		{
			print $file2update."\n";
			print "Current ".$line."\n";
			print "Change to ".substr($line,0,index($line, '=')+1)." \'".$install_dir."\';\n\n\n";
			print OUT substr($line,0,index($line, '=')+1)."\'".$install_dir."\';\n";
		}else{
			print OUT $line."\n";
		}
	}
	close IN;
	close OUT;
	system("mv $file2update.tmp $file2update");
	system("chmod 755  $file2update");


}


$files		="software/spem-release/spem/bin/scan_spem_alone.job,software/psipred/runpsipred_new";


# psipred
/data/jh7x3/multicom_github/multicom/tools/psipred/runpsipred.default



@updatelist		=split(/,/,$files);

foreach my $file (@updatelist) {
	$file2update=$install_dir.$file;
	
	$check_log ='GLOBAL_PATH=';
	open(IN,$file2update) || die "Failed to open file $file2update\n";
	open(OUT,">$file2update.tmp") || die "Failed to open file $file2update.tmp\n";
	while(<IN>)
	{
		$line = $_;
		chomp $line;

		if(index($line,$check_log)>=0)
		{
			print $file2update."\n";
			print "Current ".$line."\n";
			print "Change to ".substr($line,0,index($line, '=')+1).$install_dir."\n\n\n";
			print OUT substr($line,0,index($line, '=')+1).$install_dir."\n";
		}else{
			print OUT $line."\n";
		}
	}
	close IN;
	close OUT;
	system("mv $file2update.tmp $file2update");
	system("chmod 755  $file2update");


}
=cut



print "#########  (1) Configuring option files\n";

$option_list = "$install_dir/installation/multicom_option_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file($option_list,'src');
print "#########  Configuring option files, done\n\n\n";



print "#########  (2) Configuring tools\n";

$option_list = "$install_dir/installation/multicom_tools_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file($option_list,'tools');
print "#########  Configuring tools, done\n\n\n";

print "#########  (3) Configuring scripts\n";

$option_list = "$install_dir/installation/multicom_scripts_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file($option_list,'src');
print "#########  Configuring scripts, done\n\n\n";





print "#########  Setting up pspro2\n";
$ssprodir = $install_dir.'/tools/pspro2/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "#########  Setting up nncon1.0\n";
$ssprodir = $install_dir.'/tools/nncon1.0/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for nncon1.0 doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}


print "\n\n#########  Setting up modeleva\n";
$ssprodir = $install_dir.'/tools/model_eva1.0/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n\n#########  Setting up betacon\n";
$ssprodir = $install_dir.'/tools/betacon/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}


######
print "\n\n#########  Setting up disorder\n"; 
$ssprodir = $install_dir.'/tools/disorder_new/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for disorder doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}




print "\n\n#########  Setting up raptorx\n";
$ssprodir = $install_dir.'/tools/RaptorX4/CNFsearch1.66/';
chdir $ssprodir;
if(-f 'setup.pl')
{
	$status = system("perl setup.pl");
	if($status){
		die "Failed to run perl setup.pl\n";
		exit(-1);
	}
}else{
	die "The setup.pl file for sspro doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n#########  Setting up SCRATCH \n";
$ssprodir = $install_dir.'/tools/SCRATCH-1D_1.1/';
chdir $ssprodir;
if(-f 'install.pl')
{
	$status = system("perl install.pl");
	if($status){
		die "Failed to run perl install.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}


print "\n#########  Setting up MODELLER 9v7 \n";
my($addr_mod9v7) = $install_dir."/tools/modeller9v7/bin/mod9v7";
if (!-s $addr_mod9v7) {
	die "Please check $addr_mod9v7, you can download the modeller and install it by yourself if the current one in the tool folder is not working well, the key is MODELIRANJE.  please install it to the folder tools/modeller9v7, with the file mod9v7 in the bin directory\n";
}

my($deep_mod9v7) = $install_dir."/tools/modeller9v7/bin/modeller9v7local";
$OUT = new FileHandle ">$deep_mod9v7";
$IN=new FileHandle "$addr_mod9v7";
while(defined($line=<$IN>))
{
        chomp($line);
        @ttt = split(/\=/,$line);

        if(@ttt>1 && $ttt[0] eq "MODINSTALL9v7")
        {
                print $OUT "MODINSTALL9v7=\"$install_dir/tools/modeller9v7\"\n";
        }
        else
        {
                print $OUT $line."\n";
        }
}
$IN->close();
$OUT->close();
system("chmod 755 $deep_mod9v7");
my($modeller_conf) = $install_dir."/tools/modeller9v7/modlib/modeller/config.py";
$OUT = new FileHandle ">$modeller_conf";
print $OUT "install_dir = r\'$install_dir/tools/modeller9v7/\'\n";
print $OUT "license = \'MODELIRANJE\'";
$OUT->close();
system("chmod 755 $modeller_conf");
system("cp $deep_mod9v7 $addr_mod9v7");
print "Done\n";


print "\n#########  Setting up MODELLER 9v16 \n";
my($addr_mod9v16) = $install_dir."/tools/modeller-9.16/bin/mod9.16";
if (!-s $addr_mod9v16) {
	die "Please check $addr_mod9v16, you can download the modeller and install it by yourself if the current one in the tool folder is not working well, the key is MODELIRANJE.  please install it to the folder tools/modeller-9.16, with the file mod9v7 in the bin directory\n";
}

my($deep_mod9v16) = $install_dir."/tools/modeller-9.16/bin/modeller9v16local";
$OUT = new FileHandle ">$deep_mod9v16";
$IN=new FileHandle "$addr_mod9v16";
while(defined($line=<$IN>))
{
        chomp($line);
        @ttt = split(/\=/,$line);

        if(@ttt>1 && $ttt[0] eq "MODINSTALL9v16")
        {
                print $OUT "MODINSTALL9v16=\"$install_dir/tools/modeller-9.16\"\n";
        }
        else
        {
                print $OUT $line."\n";
        }
}
$IN->close();
$OUT->close();
system("chmod 755 $deep_mod9v16");
my($modeller_conf) = $install_dir."/tools/modeller-9.16/modlib/modeller/config.py";
$OUT = new FileHandle ">$modeller_conf";
print $OUT "install_dir = r\'$install_dir/tools/modeller-9.16/\'\n";
print $OUT "license = \'MODELIRANJE\'";
$OUT->close();
system("chmod 755 $modeller_conf");
system("cp $deep_mod9v16 $addr_mod9v16");
print "Done\n";


print "\n#########  Setting up scwrl4 \n";

#/data/jh7x3/multicom_github/multicom/tools/scwrl4/
#./install_Scwrl4_Linux



####### update prc database 
$prc_db = "$install_dir/databases/prc_db/";
if(!(-d $prc_db))
{
	die "PRC database $prc_db is not found\n";
}
opendir(PRCDIR,"$prc_db") || die "Failed to open directory $prc_db\n";
@prcfiles = readdir(PRCDIR);
closedir(PRCDIR);
open(PRCLIB,">$prc_db/prcdb.lib")  || die "Failed to write $prc_db/prcdb.lib\n";
foreach $prcfile (@prcfiles)
{
	if($prcfile eq '.' or $prcfile eq '..' or substr($prcfile,length($prcfile)-4) ne '.mod')
	{
		next;
	}
	print PRCLIB "$prc_db/$prcfile\n";
	
}
close PRCLIB;






sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}
sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}


sub configure_file{
	my ($option_list,$prefix) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			$option_default = $install_dir.$file.'.default';
			$option_new = $install_dir.$file;
			$file_indx++;
			print "$file_indx: Configuring $option_new\n";
			if (! -f $option_default)
			{
					die "\nOption file $option_default not exists.\n";
			}	
			
			open(IN1,$option_default) || die "Failed to open file $option_default\n";
			open(OUT1,">$option_new") || die "Failed to open file $option_new\n";
			while(<IN1>)
			{
				$line = $_;
				chomp $line;

				if(index($line,'SOFTWARE_PATH')>=0)
				{
					$line =~ s/SOFTWARE_PATH/$install_dir/g;
					$line =~ s/\/\//\//g;
					print OUT1 $line."\n";
				}else{
					print OUT1 $line."\n";
				}
			}
			close IN1;
			close OUT1;
		}
	}
	close IN;
}


=pod
database downloading 


/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/chain_stx_info
/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/pdb_cm
/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/pdb_cm.phr
/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/pdb_cm.pin
/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/pdb_cm.psq
/home/casp13/MULTICOM_package/software/prosys_database/cm_lib/pdb_cm_all_sel.fasta 


/home/casp13/MULTICOM_package/software/prosys_database/atom.tar.gz

/home/casp13/MULTICOM_package/software/prosys_database/nr_latest/



=cut
