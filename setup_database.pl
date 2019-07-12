#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

 # perl /home/jh7x3/multicom_v1.1/setup_database.pl
 
######################## !!! customize settings here !!! ############################
#																					#
# Set directory of multicom databases and tools								        #

$multicom_db_tools_dir = "/data/commons/MULTICOM_db_tools/";							        
						        

######################## !!! End of customize settings !!! ##########################

######################## !!! Don't Change the code below##############

$install_dir = getcwd;
$install_dir=abs_path($install_dir);


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
        die "\nPlease check the installation directory setting and run the configure program under the main directory of multicom.\n";
}
print " OK!\n";


if(!-d $multicom_db_tools_dir)
{
	$status = system("mkdir $multicom_db_tools_dir");
	if($status)
	{
		die "Failed to create folder $multicom_db_tools_dir\n";
	}
}
$multicom_db_tools_dir=abs_path($multicom_db_tools_dir);



if ( substr($multicom_db_tools_dir, length($multicom_db_tools_dir) - 1, 1) ne "/" )
{
        $multicom_db_tools_dir .= "/";
}

=pod
if (prompt_yn("multicom database will be installed into <$multicom_db_tools_dir> ")){

}else{
	die "The installation is cancelled!\n";
}
=cut

print "Start install multicom into <$multicom_db_tools_dir>\n"; 



chdir($multicom_db_tools_dir);

$database_dir = "$multicom_db_tools_dir/databases";
$tools_dir = "$multicom_db_tools_dir/tools";


if(!-d $database_dir)
{
	$status = system("mkdir $database_dir");
	if($status)
	{
		die "Failed to create folder ($database_dir), check permission or folder path\n";
	}
	`chmod -R 755 $database_dir`;
}
if(!-d $tools_dir)
{ 
	$status = system("mkdir $tools_dir");
	if($status)
	{
		die "Failed to create folder ($tools_dir), check permission or folder path\n";
	}
	`chmod -R 755 $tools_dir`;
}

####### tools compilation 
if(-e "$install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh")
{
	`rm $install_dir/installation/MULTICOM_manually_install_files/*sh`;
}

##### check gcc version
$check_gcc = system("gcc -dumpversion");
if($check_gcc)
{
	print "Failed to find gcc in system, please check gcc version";
	exit;
}

$gcc_v = `gcc -dumpversion`;
chomp $gcc_v;
@gcc_version = split(/\./,$gcc_v);
if($gcc_version[0] != 4)
{
	print "!!!! Warning: gcc 4.X.X is recommended for boost installation, currently is $gcc_v\n\n";
	sleep(2);
	
}


if($gcc_version[0] ==4 and $gcc_version[1]<6) #gcc 4.6
{
	print "\nGCC $gcc_v is used, install boost-1.38.00\n\n";
	### install boost-1.38 
	open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh\n";
	print OUT "#!/bin/bash -e\n\n";
	print OUT "echo \" Start compile boost (will take ~20 min)\"\n\n";
	print OUT "cd $multicom_db_tools_dir/tools\n\n";
	print OUT "cd boost_1_38_0\n\n";
	print OUT "./configure  --prefix=$multicom_db_tools_dir/tools/boost_1_38_0\n\n";
	print OUT "make\n\n";
	print OUT "make install\n\n";
	print OUT "echo \"installed\" > $multicom_db_tools_dir/tools/boost_1_38_0/install.done\n\n";
	close OUT;
	
	#### install freecontact using boost 1.38

	open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh\n";
	print OUT "#!/bin/bash -e\n\n";
	print OUT "echo \" Start compile freecontact (will take ~1 min)\"\n\n";
	print OUT "cd $multicom_db_tools_dir/tools/DNCON2\n\n";
	print OUT "cd freecontact-1.0.21\n\n";
	print OUT "autoreconf -f -i\n\n";
	print OUT "#make clean\n\n";
	print OUT "./configure --prefix=$multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21 LDFLAGS=\"-L$multicom_db_tools_dir/tools/OpenBLAS/lib -L$multicom_db_tools_dir/tools/boost_1_38_0/lib\" CFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_38_0/include/boost-1_38\"  CPPFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_38_0/include/boost-1_38\" --with-boost=$multicom_db_tools_dir/tools/boost_1_38_0/\n\n";
	print OUT "make\n\n";
	print OUT "make install\n\n";
	
	print OUT "if [[ -f \"bin/freecontact\" ]]; then\n";
	print OUT "\techo \"bin/freecontact exists\"\n";
	print OUT "\techo \"installed\" > $multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21/install.done\n\n";
	print OUT "else\n\n";
	print OUT "\techo \"bin/freecontact doesn't exist, check the installation\"\n";
	print OUT "fi\n\n";
	
	close OUT;

}else{
	print "\nGCC $gcc_v is used, install boost-1.55.00\n\n";
	### install boost-1.55 
	open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh\n";
	print OUT "#!/bin/bash -e\n\n";
	print OUT "echo \" Start compile boost (will take ~20 min)\"\n\n";
	print OUT "cd $multicom_db_tools_dir/tools\n\n";
	print OUT "cd boost_1_55_0\n\n";
	print OUT "./bootstrap.sh  --prefix=$multicom_db_tools_dir/tools/boost_1_55_0\n\n";
	print OUT "./b2\n\n";
	print OUT "./b2 install\n\n";
	print OUT "echo \"installed\" > $multicom_db_tools_dir/tools/boost_1_55_0/install.done\n\n";
	close OUT;
	
	#### install freecontact using boost 1.55

	open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh\n";
	print OUT "#!/bin/bash -e\n\n";
	print OUT "echo \" Start compile freecontact (will take ~1 min)\"\n\n";
	print OUT "cd $multicom_db_tools_dir/tools/DNCON2\n\n";
	print OUT "cd freecontact-1.0.21\n\n";
	print OUT "autoreconf -f -i\n\n";
	print OUT "#make clean\n\n";
	print OUT "./configure --prefix=$multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21 LDFLAGS=\"-L$multicom_db_tools_dir/tools/OpenBLAS/lib -L$multicom_db_tools_dir/tools/boost_1_55_0/lib\" CFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\"  CPPFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\" --with-boost=$multicom_db_tools_dir/tools/boost_1_55_0/\n\n";
	print OUT "make\n\n";
	print OUT "make install\n\n";
	
	print OUT "if [[ -f \"bin/freecontact\" ]]; then\n";
	print OUT "\techo \"bin/freecontact exists\"\n";
	print OUT "\techo \"installed\" > $multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21/install.done\n\n";
	print OUT "else\n\n";
	print OUT "\techo \"bin/freecontact doesn't exist, check the installation\"\n";
	print OUT "fi\n\n";
	
	close OUT;	
}


#### install OpenBlas
open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile OpenBlas (will take ~5 min)\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd OpenBLAS\n\n";
print OUT "#make clean\n\n";
print OUT "make\n\n";
print OUT "make PREFIX=$multicom_db_tools_dir/tools/OpenBLAS install\n\n";
print OUT "echo \"installed\" > $multicom_db_tools_dir/tools/OpenBLAS/install.done\n\n";
close OUT;




=pod
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
=cut

#### create python virtual environment

open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P4_python_virtual.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P4_python_virtual.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start install python virtual environment (will take ~1 min)\"\n\n";
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
print OUT "pip install --upgrade pillow\n\n";
print OUT "NOW=\$(date +\"%m-%d-%Y\")\n\n";
print OUT "mkdir -p ~/.keras\n\n";
print OUT "cp ~/.keras/keras.json ~/.keras/keras.json.\$NOW.\$RANDOM\n\n";
print OUT "cp $install_dir/installation/MULTICOM_configure_files/keras_multicom.json ~/.keras/keras.json\n\n";
print OUT "echo \"installed\" > $multicom_db_tools_dir/tools/python_virtualenv/install.done\n\n";
close OUT;


if(!(-e "/usr/bin/python2.6"))
{
	#### create python2.6 library

	open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P5_python2.6_library.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P5_python2.6_library.sh\n";
	print OUT "#!/bin/bash -e\n\n";
	print OUT "echo \" Start install python2.6 library (will take ~5 min)\"\n\n";
	print OUT "cd $multicom_db_tools_dir/tools\n\n";
	print OUT "#wget http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tgz\n\n";
	print OUT "#tar xzf Python-2.6.8.tgz\n\n";
	print OUT "cd Python-2.6.8\n\n";
	print OUT "make clean\n\n";
	print OUT "./configure --prefix=$multicom_db_tools_dir/tools/Python-2.6.8 --with-threads --enable-shared --with-zlib=/usr/include\n\n";
	print OUT "make\n\n";
	print OUT "make install\n\n";
	print OUT "echo \"installed\" > $multicom_db_tools_dir/tools/Python-2.6.8/install.done\n\n";
	close OUT;
	
	`cp $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh.py2.6 $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh`;
}else{
	`cp $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh.py2.7 $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh`;
}




#### (1) Download basic databases
print("#### (1) Download basic databases\n\n");
chdir($database_dir);
$basic_db_list = "cm_lib.tar.gz;seq.tar.gz;atom.tar.gz;fr_lib.tar.gz;big.tar.gz";
@basic_db = split(';',$basic_db_list);
foreach $db (@basic_db)
{
	$dbname = substr($db,0,index($db,'.tar.gz'));
	if(-e "$database_dir/$dbname/download.done")
	{
		print "\t$dbname is done!\n";
		next;
	}
	if(-e $db)
	{
		`rm $db`;
	}
	`wget http://sysbio.rnet.missouri.edu/multicom_db_tools/databases/$db`;
	
	if(-e "$db")
	{
		print "\t$db is found, start extracting files......\n\n";
		`tar -zxf $db`;
		`echo 'done' > $dbname/download.done`;
		`rm $db`;
		`chmod -R 755 $dbname`;
	}else{
		die "Failed to download $db from http://sysbio.rnet.missouri.edu/multicom_db_tools/databases, please contact chengji\@missouri.edu\n";
	}
}

#### (2) Download basic tools
print("\n#### (2) Download basic tools\n\n");

chdir($tools_dir);
$basic_tools_list = "blast-2.2.17.tar.gz;blast-2.2.20.tar.gz;blast-2.2.25.tar.gz;modeller-9.16.tar.gz;modeller9v7.tar.gz;tm_s