#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

######################## !!! customize settings here !!! ############################
#																					#
# Set directory of multicom databases and tools								        #

$multicom_db_tools_dir = "/home/casp14/MULTICOM_db_tools/";							        

######################## !!! End of customize settings !!! ##########################

######################## !!! Don't Change the code below##############


$install_dir = getcwd;
$install_dir=abs_path($install_dir);


if(!-s $install_dir)
{
	die "The multicom directory ($install_dir) is not existing, please revise the customize settings part inside the configure.pl, set the path as  your unzipped multicom directory\n";
}

if(!-d $multicom_db_tools_dir)
{
	die "The multicom databases/tools folder ($multicom_db_tools_dir) is not existing\n";
}

if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
        $install_dir .= "/";
}

if ( substr($multicom_db_tools_dir, length($multicom_db_tools_dir) - 1, 1) ne "/" )
{
        $multicom_db_tools_dir .= "/";
}



print "checking whether the configuration file run in the installation folder ...";
$cur_dir = `pwd`;
chomp $cur_dir;
$configure_file = "$cur_dir/configure.pl";
if (! -f $configure_file || $install_dir ne "$cur_dir/")
{
        die "\nPlease check the installation directory setting and run the configure program under the main directory of multicom.\n";
}
print " OK!\n";



if (! -d $install_dir)
{
	die "can't find installation directory.\n";
}
if ( substr($install_dir, length($install_dir) - 1, 1) ne "/" )
{
	$install_dir .= "/"; 
}


######### check the multicom database and tools

$database_dir = "$multicom_db_tools_dir/databases";
$tools_dir = "$multicom_db_tools_dir/tools";

if(!(-d $database_dir) or !(-d $tools_dir))
{
	die "Failed to find databases and tools under $multicom_db_tools_dir/\n";
}

if($multicom_db_tools_dir eq "$cur_dir/")
{
	die "Same directory as MULTICOM main folder. Differnt path for original databases/tools folder $multicom_db_tools_dir is recommended.\n";
}
#create link for databases and tools
`rm ${install_dir}databases`; 
`rm ${install_dir}tools`; 
`ln -s $database_dir ${install_dir}databases`;
`ln -s $tools_dir ${install_dir}tools`;




if (prompt_yn("multicom will be installed into <$install_dir> ")){

}else{
	die "The installation is cancelled!\n";
}
print "Start install multicom into <$install_dir>\n"; 


print "#########  (1) Configuring option files\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_option_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file($option_list,'src');
print "#########  Configuring option files, done\n\n\n";



print "#########  (2) Configuring tools\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_tools_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_tools($option_list,'tools',$multicom_db_tools_dir);
print "#########  Configuring tools, done\n\n\n";

print "#########  (3) Configuring scripts\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_scripts_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file($option_list,'src');
print "#########  Configuring scripts, done\n\n\n";



print "#########  (4) Configuring examples\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_examples_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file2($option_list,'installation');
print "#########  Configuring examples, done\n\n\n";

system("chmod +x $install_dir/installation/MULTICOM_test_codes/*sh");



system("cp $install_dir/src/run_multicom.sh $install_dir/bin/run_multicom.sh");
system("chmod +x $install_dir/bin/run_multicom.sh");



print "#########  Setting up pspro2\n";
$ssprodir = $multicom_db_tools_dir.'/tools/pspro2/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "#########  Setting up nncon1.0\n";
$ssprodir = $multicom_db_tools_dir.'/tools/nncon1.0/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}


print "\n\n#########  Setting up modeleva\n";
$ssprodir = $multicom_db_tools_dir.'/tools/model_eva1.0/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n\n#########  Setting up betacon\n";
$ssprodir = $multicom_db_tools_dir.'/tools/betacon/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n\n#########  Setting up betapro-1.0\n";
$ssprodir = $multicom_db_tools_dir.'/tools/betapro-1.0/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}


######
print "\n\n#########  Setting up disorder\n"; 
$ssprodir = $multicom_db_tools_dir.'/tools/disorder_new/';
chdir $ssprodir;
if(-f 'configure.pl')
{
	$status = system("perl configure.pl");
	if($status){
		die "Failed to run perl configure.pl \n";
		exit(-1);
	}
}else{
	die "The configure.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}




print "\n\n#########  Setting up raptorx\n";
$ssprodir = $multicom_db_tools_dir.'/tools/RaptorX4/CNFsearch1.66/';
chdir $ssprodir;
if(-f 'setup.pl')
{
	$status = system("perl setup.pl");
	if($status){
		die "Failed to run perl setup.pl\n";
		exit(-1);
	}
}else{
	die "The setup.pl file for $ssprodir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
}

print "\n#########  Setting up SCRATCH \n";
$ssprodir = $multicom_db_tools_dir.'/tools/SCRATCH-1D_1.1/';
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
my($addr_mod9v7) = $multicom_db_tools_dir."/tools/modeller9v7/bin/mod9v7";
if (!-s $addr_mod9v7) {
	die "Please check $addr_mod9v7, you can download the modeller and install it by yourself if the current one in the tool folder is not working well, the key is MODELIRANJE.  please install it to the folder tools/modeller9v7, with the file mod9v7 in the bin directory\n";
}

my($deep_mod9v7) = $multicom_db_tools_dir."/tools/modeller9v7/bin/modeller9v7local";
$OUT = new FileHandle ">$deep_mod9v7";
$IN=new FileHandle "$addr_mod9v7";
while(defined($line=<$IN>))
{
        chomp($line);
        @ttt = split(/\=/,$line);

        if(@ttt>1 && $ttt[0] eq "MODINSTALL9v7")
        {
                print $OUT "MODINSTALL9v7=\"$multicom_db_tools_dir/tools/modeller9v7\"\n";
        }
        else
        {
                print $OUT $line."\n";
        }
}
$IN->close();
$OUT->close();
system("chmod 755 $deep_mod9v7");
$modeller_conf = $multicom_db_tools_dir."/tools/modeller9v7/modlib/modeller/config.py";
$OUT = new FileHandle ">$modeller_conf";
print $OUT "install_dir = r\'$multicom_db_tools_dir/tools/modeller9v7/\'\n";
print $OUT "license = \'MODELIRANJE\'";
$OUT->close();
system("chmod 755 $modeller_conf");
system("cp $deep_mod9v7 $addr_mod9v7");
print "Done\n";


print "\n#########  Setting up MODELLER 9v16 \n";
my($addr_mod9v16) = $multicom_db_tools_dir."/tools/modeller-9.16/bin/mod9.16";
if (!-s $addr_mod9v16) {
	die "Please check $addr_mod9v16, you can download the modeller and install it by yourself if the current one in the tool folder is not working well, the key is MODELIRANJE.  please install it to the folder tools/modeller-9.16, with the file mod9v7 in the bin directory\n";
}

my($deep_mod9v16) = $multicom_db_tools_dir."/tools/modeller-9.16/bin/modeller9v16local";
$OUT = new FileHandle ">$deep_mod9v16";
$IN=new FileHandle "$addr_mod9v16";
while(defined($line=<$IN>))
{
        chomp($line);
        @ttt = split(/\=/,$line);

        if(@ttt>1 && $ttt[0] eq "MODINSTALL9v16")
        {
                print $OUT "MODINSTALL9v16=\"$multicom_db_tools_dir/tools/modeller-9.16\"\n";
        }
        else
        {
                print $OUT $line."\n";
        }
}
$IN->close();
$OUT->close();
system("chmod 755 $deep_mod9v16");
$modeller_conf = $multicom_db_tools_dir."/tools/modeller-9.16/modlib/modeller/config.py";
$OUT = new FileHandle ">$modeller_conf";
print $OUT "install_dir = r\'$multicom_db_tools_dir/tools/modeller-9.16/\'\n";
print $OUT "license = \'MODELIRANJE\'";
$OUT->close();
system("chmod 755 $modeller_conf");
system("cp $deep_mod9v16 $addr_mod9v16");
print "Done\n";


####### update prc database 
$prc_db = "$multicom_db_tools_dir/databases/prc_db/";
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




####### tools compilation 

### install boost-1.55 
open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile boost (will take ~20 min)\n\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd boost_1_55_0\n\n";
print OUT "./bootstrap.sh  --prefix=$multicom_db_tools_dir/tools/boost_1_55_0\n\n";
print OUT "./b2\n\n";
print OUT "./b2 install\n\n";
close OUT;

#### install OpenBlas
open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile OpenBlas (will take ~5 min)\n\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd OpenBLAS\n\n";
print OUT "make clean\n\n";
print OUT "make\n\n";
print OUT "make PREFIX=$multicom_db_tools_dir/tools/OpenBLAS install\n\n";
close OUT;


#### install freecontact

open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile freecontact (will take ~1 min)\n\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools/DNCON2\n\n";
print OUT "cd freecontact-1.0.21\n\n";
print OUT "autoreconf -f -i\n\n";
print OUT "make clean\n\n";
print OUT "./configure --prefix=$multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21 LDFLAGS=\"-L$multicom_db_tools_dir/tools/OpenBLAS/lib -L$multicom_db_tools_dir/tools/boost_1_55_0/lib\" CFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\"  CPPFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\" --with-boost=$multicom_db_tools_dir/tools/boost_1_55_0/\n\n";
print OUT "make\n\n";
print OUT "make install\n\n";
close OUT;

#### install scwrl4

open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P4_install_scwrl4.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P4_install_scwrl4.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile freecontact (will take ~1 min)\"\n\n";
print OUT "echo \" \"\n\n";
print OUT "echo \" \"\n\n";
print OUT "echo \" !!!!!!!! Please copy and set the installation path of scwrl to <${multicom_db_tools_dir}tools/scwrl4> !!!!!!!! \"\n\n";
print OUT "echo \" \"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd scwrl4\n\n";
print OUT "./install_Scwrl4_Linux\n\n";
close OUT;


#### create python virtual environment

open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P5_python_virtual.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P5_python_virtual.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start install python virtual environment (will take ~1 min)\n\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "rm -rf python_virtualenv\n\n";
print OUT "virtualenv python_virtualenv\n\n";
print OUT "source $multicom_db_tools_dir/tools/python_virtualenv/bin/activate\n\n";
print OUT "pip install --upgrade pip\n\n";
print OUT "pip install --upgrade numpy==1.12.1\n\n";
print OUT "pip install --upgrade keras==1.2.2\n\n";
print OUT "pip install --upgrade theano==0.9.0\n\n";
print OUT "pip install --upgrade h5py\n\n";
print OUT "pip install --upgrade matplotlib\n\n";
print OUT "NOW=\$(date +\"%m-%d-%Y\")\n\n";
print OUT "cp ~/.keras/keras.json ~/.keras/keras.json.\$NOW.\$RANDOM\n\n";
print OUT "cp $install_dir/installation/MULTICOM_configure_files/keras_multicom.json ~/.keras/keras.json\n\n";
close OUT;





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


sub configure_tools{
	my ($option_list,$prefix,$DBtool_path) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			$option_default = $DBtool_path.$file.'.default';
			$option_new = $DBtool_path.$file;
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
					$line =~ s/SOFTWARE_PATH/$DBtool_path/g;
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



sub configure_file2{
	my ($option_list,$prefix) = @_;
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	$file_indx=0;
	while(<IN>)
	{
		$file = $_;
		chomp $file;
		if ($file =~ /^$prefix/)
		{
			@tmparr = split('/',$file);
			$filename = pop @tmparr;
			chomp $filename;
			$filepath = join('/',@tmparr);
			$option_default = $install_dir.$filepath.'/.'.$filename.'.default';
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
