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
### install boost-1.55 
open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P1_install_boost.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile boost (will take ~20 min)\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd boost_1_55_0\n\n";
print OUT "./bootstrap.sh  --prefix=$multicom_db_tools_dir/tools/boost_1_55_0\n\n";
print OUT "./b2\n\n";
print OUT "./b2 install\n\n";
close OUT;

#### install OpenBlas
open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P2_install_OpenBlas.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile OpenBlas (will take ~5 min)\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools\n\n";
print OUT "cd OpenBLAS\n\n";
print OUT "make clean\n\n";
print OUT "make\n\n";
print OUT "make PREFIX=$multicom_db_tools_dir/tools/OpenBLAS install\n\n";
close OUT;


#### install freecontact

open(OUT,">$install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh") || die "Failed to open file $install_dir/installation/MULTICOM_manually_install_files/P3_install_freecontact.sh\n";
print OUT "#!/bin/bash -e\n\n";
print OUT "echo \" Start compile freecontact (will take ~1 min)\"\n\n";
print OUT "cd $multicom_db_tools_dir/tools/DNCON2\n\n";
print OUT "cd freecontact-1.0.21\n\n";
print OUT "autoreconf -f -i\n\n";
print OUT "make clean\n\n";
print OUT "./configure --prefix=$multicom_db_tools_dir/tools/DNCON2/freecontact-1.0.21 LDFLAGS=\"-L$multicom_db_tools_dir/tools/OpenBLAS/lib -L$multicom_db_tools_dir/tools/boost_1_55_0/lib\" CFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\"  CPPFLAGS=\"-I$multicom_db_tools_dir/tools/OpenBLAS/include -I$multicom_db_tools_dir/tools/boost_1_55_0/include\" --with-boost=$multicom_db_tools_dir/tools/boost_1_55_0/\n\n";
print OUT "make\n\n";
print OUT "make install\n\n";
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
	close OUT;
	
	`cp $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh.py2.6 $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh`;
}else{
	`cp $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh.py2.7 $install_dir/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.sh`;
}




#### (1) Download basic databases
print("#### (1) Download basic databases\n\n");
chdir($database_dir);
$basic_db_list = "cm_lib.tar.gz;atom.tar.gz;fr_lib.tar.gz;big.tar.gz";
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
$basic_tools_list = "blast-2.2.17.tar.gz;blast-2.2.20.tar.gz;blast-2.2.25.tar.gz;modeller-9.16.tar.gz;modeller9v7.tar.gz;tm_score.tar.gz;tm_score2.tar.gz;tm_align2.tar.gz;clustalw1.83.tar.gz;mmseqs2.tar.gz;boost_1_55_0.tar.gz;OpenBLAS.tar.gz;scwrl4.tar.gz;DNCON2.tar.gz;pairwiseQA.tar.gz;pspro2.tar.gz;model_eva1.0.tar.gz;model_check2.tar.gz;MSACompro_1.2.0.tar.gz;MSAProbs-0.9.4.tar.gz;Domain_assembly.tar.gz;TMalign.tar.gz;TMscore.tar.gz;betacon.tar.gz;betapro-1.0.tar.gz;disorder_new.tar.gz;dssp.tar.gz;energy.tar.gz;maxcluster64bit.tar.gz;tm_align.tar.gz";
@basic_tools = split(';',$basic_tools_list);
foreach $tool (@basic_tools)
{
	$toolname = substr($tool,0,index($tool,'.tar.gz'));
	if(-d "$tools_dir/$toolname")
	{
		if(-e "$tools_dir/$toolname/download.done")
		{
			print "\t$toolname is done!\n";
			next;
		}
	}elsif(-f "$tools_dir/$toolname")
	{
			print "\t$toolname is done!\n";
			next;
	}				
	if(-e $tool)
	{
		`rm $tool`;
	}
	`wget http://sysbio.rnet.missouri.edu/multicom_db_tools/tools/$tool`;
	if(-e "$tool")
	{
		print "\n\t$tool is found, start extracting files......\n\n";
		`tar -zxf $tool`;
		`echo 'done' > $toolname/download.done`;
		`rm $tool`;
		`chmod -R 755 $toolname`;
	}else{
		die "Failed to download $tool from http://sysbio.rnet.missouri.edu/multicom_db_tools/tools, please contact chengji\@missouri.edu\n";
	}
}


#### (3) Download uniref90
print("\n#### (3) Download uniref90\n\n");
$uniref_dir = "$multicom_db_tools_dir/databases/uniref";
if(!(-d "$uniref_dir"))
{
	`mkdir $uniref_dir`;
}
chdir($uniref_dir);

if(-e "uniref90.pal")
{
	print "\tuniref90 has been formatted, skip!\n";
}elsif(-e "uniref90.fasta")
{
	print "\tuniref90.fasta is found, start formating......\n";
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref90.fasta -o T -t uniref90 -n uniref90`;
		`chmod -R 755 uniref90*`;
}else{
	if(-e "uniref90.fasta.gz")
	{
		`rm uniref90.fasta.gz`;
	}
	`wget ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref90/uniref90.fasta.gz`;
	if(-e "uniref90.fasta.gz")
	{
		print "\tuniref90.fasta.gz is found, start extracting files\n";
	}else{
		die "Failed to download uniref90.fasta.gz from ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref90/\n";
	}
	`gzip -d uniref90.fasta.gz`;
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref90.fasta -o T -t uniref90 -n uniref90`;
		`chmod -R 755 uniref90*`;

}

#### (4) Generating uniref70
print("\n#### (4) Generating uniref70\n\n");
chdir($uniref_dir);

if(-e "uniref70.pal")
{
	print "\tuniref70 has been formatted, skip!\n";
}elsif(-e "uniref70.fasta")
{
	print "\tuniref70.fasta is found, start formating......\n";
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref70.fasta -o T -t uniref70 -n uniref70`;
}else{

	### run mmseq
	`mkdir $uniref_dir/create70`;
	chdir("$uniref_dir/create70");

	`$tools_dir/mmseqs2/bin/mmseqs createdb $uniref_dir/uniref90.fasta  uniref90`;
	`$tools_dir/mmseqs2/bin/mmseqs linclust uniref90 uniref70 tmp70 --min-seq-id 0.7`;
	`$tools_dir/mmseqs2/bin/mmseqs result2repseq uniref90 uniref70 uniref70_lin_req`;
	`$tools_dir/mmseqs2/bin/mmseqs result2flat uniref90 uniref90 uniref70_lin_req uniref70.fasta --use-fasta-header`;
	`cp uniref70.fasta $uniref_dir/uniref70.fasta`;
	`rm -rf $uniref_dir/create70`;
	
	chdir($uniref_dir);
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref70.fasta -o T -t uniref70 -n uniref70`;
		`chmod -R 755 uniref70*`;

}



#### (5) Download uniref50
print("\n#### (5) Download uniref50\n\n");
$uniref_dir = "$multicom_db_tools_dir/databases/uniref";
if(!(-d "$uniref_dir"))
{
	`mkdir $uniref_dir`;
}
chdir($uniref_dir);

if(-e "uniref50.pal")
{
	print "\tuniref50 has been formatted, skip!\n";
}elsif(-e "uniref50.fasta")
{
	print "\tuniref50.fasta is found, start formating......\n";
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref50.fasta -o T -t uniref50 -n uniref50`;
}else{
	`wget ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.fasta.gz`;
	if(-e "uniref50.fasta.gz")
	{
		print "\tuniref50.fasta.gz is found, start extracting files......\n";
	}else{
		die "Failed to download uniref50.fasta.gz from ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/\n";
	}
	`gzip -d uniref50.fasta.gz`;
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref50.fasta -o T -t uniref50 -n uniref50`;
	`chmod -R 755 uniref50*`;

}
=pod
#### (6) Generating uniref20
print("\n#### (6) Generating uniref20\n\n");
chdir($uniref_dir);

if(-e "uniref20.pal")
{
	print "\tuniref20 has been formatted, skip!\n";
}elsif(-e "uniref20.fasta")
{
	print "\tuniref20.fasta is found, start formating......\n";
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref20.fasta -o T -t uniref20 -n uniref20`;
}else{

	### run mmseq
	`mkdir $uniref_dir/create20`;
	chdir("$uniref_dir/create20");

	`$tools_dir/mmseqs2/bin/mmseqs createdb $uniref_dir/uniref50.fasta  uniref50`;
	`$tools_dir/mmseqs2/bin/mmseqs linclust uniref50 uniref20 tmp20 --min-seq-id 0.2`;
	`$tools_dir/mmseqs2/bin/mmseqs result2repseq uniref50 uniref20 uniref20_lin_req`;
	`$tools_dir/mmseqs2/bin/mmseqs result2flat uniref50 uniref50 uniref20_lin_req uniref20.fasta --use-fasta-header`;
	`cp uniref20.fasta $uniref_dir/uniref20.fasta`;
	`rm -rf $uniref_dir/create20`;
	
	chdir($uniref_dir);
	`$tools_dir/blast-2.2.25/bin/formatdb -i uniref20.fasta -o T -t uniref20 -n uniref20`;

}
=cut

#### (6) Linking databases
print("\n#### (6) Linking databases\n\n");

### linking sequence database 

-d "$database_dir/nr_latest" || `mkdir $database_dir/nr_latest`;
-d "$database_dir/nr70_90" || `mkdir $database_dir/nr70_90`;
#-d "$database_dir/nr20" ||  `mkdir $database_dir/nr20`;

opendir(DBDIR,"$uniref_dir") || die "Failed to open $uniref_dir\n";
@files = readdir(DBDIR);
closedir(DBDIR);
foreach $file (@files)
{
	if($file eq '.' or $file eq '..')
	{
		next;
	}
	
	if(substr($file,0,9) eq 'uniref90.')
	{
		$subfix = substr($file,9);
		if(-l "$database_dir/nr70_90/nr90.$subfix")
		{	
			$status = system("rm $database_dir/nr70_90/nr90.$subfix");
			if($status)
			{
				die "Failed to remove file ($database_dir/nr70_90/nr90.$subfix), check the permission\n";
			}
		}
		if($subfix eq 'pal')
		{
			## change to nr90
			open(TMP,"$uniref_dir/$file");
			open(TMPOUT,">$database_dir/nr70_90/nr90.pal");
			while(<TMP>)
			{
				$li=$_;
				chomp $li;
				if(index($li,'uniref90')>=0)
				{
					$li =~ s/uniref90/nr90/g;
					print TMPOUT "$li\n";
				}else{
					print TMPOUT "$li\n";
				}
			}
			close TMP;
			close TMPOUT;
		}else{
			
			$status = system("ln -s $uniref_dir/$file $database_dir/nr70_90/nr90.$subfix");
			if($status)
			{
				die "Failed to link database ($database_dir/nr70_90/nr90.$subfix), check the permission\n";
			}
			
			`chmod -R 755 $database_dir/nr70_90/nr90.$subfix`;
		}
	}
	
	if(substr($file,0,9) eq 'uniref70.')
	{
		$subfix = substr($file,9);
		if(-l "$database_dir/nr70_90/nr70.$subfix")
		{
			
			$status = system("rm $database_dir/nr70_90/nr70.$subfix");
			if($status)
			{
				die "Failed to remove file ($database_dir/nr70_90/nr70.$subfix), check the permission\n";
			}
			
		}
		if($subfix eq 'pal')
		{
			## change to nr90
			open(TMP,"$uniref_dir/$file");
			open(TMPOUT,">$database_dir/nr70_90/nr70.pal");
			while(<TMP>)
			{
				$li=$_;
				chomp $li;
				if(index($li,'uniref70')>=0)
				{
					$li =~ s/uniref70/nr70/g;
					print TMPOUT "$li\n";
				}else{
					print TMPOUT "$li\n";
				}
			}
			close TMP;
			close TMPOUT;
		}else{
			
			$status = system("ln -s $uniref_dir/$file $database_dir/nr70_90/nr70.$subfix");
			if($status)
			{
				 die "Failed to link database ($database_dir/nr70_90/nr70.$subfix), check the permission\n";
			}
			
			`chmod -R 755 $database_dir/nr70_90/nr70.$subfix`;
		}
		
	}
	
	if(substr($file,0,9) eq 'uniref90.')
	{
		$subfix = substr($file,9);
		if(-l "$database_dir/nr_latest/nr.$subfix")
		{
			`rm $database_dir/nr_latest/nr.$subfix`; 
		}
		if($subfix eq 'pal')
		{
			## change to nr90
			open(TMP,"$uniref_dir/$file");
			open(TMPOUT,">$database_dir/nr_latest/nr.pal");
			while(<TMP>)
			{
				$li=$_;
				chomp $li;
				if(index($li,'uniref90')>=0)
				{
					$li =~ s/uniref90/nr/g;
					print TMPOUT "$li\n";
				}else{
					print TMPOUT "$li\n";
				}
			}
			close TMP;
			close TMPOUT;
		}else{
			
			$status = system("ln -s $uniref_dir/$file $database_dir/nr_latest/nr.$subfix");
			if($status)
			{
				 die "Failed to link database($database_dir/nr_latest/nr.$subfix), check the permission\n";
			}
			
			`chmod -R 755 $database_dir/nr_latest/nr.$subfix`;
		}
		
	}
=pod
	if(substr($file,0,9) eq 'uniref20.')
	{
		$subfix = substr($file,9);
		if(-l "$database_dir/nr20/nr20.$subfix")
		{
			`rm $database_dir/nr20/nr20.$subfix`; 
		}
		if($subfix eq 'pal')
		{
			## change to nr90
			open(TMP,"$uniref_dir/$file");
			open(TMPOUT,">$database_dir/nr20/nr20.pal");
			while(<TMP>)
			{
				$li=$_;
				chomp $li;
				if(index($li,'uniref20')>=0)
				{
					$li =~ s/uniref20/nr20/g;
					print TMPOUT "$li\n";
				}else{
					print TMPOUT "$li\n";
				}
			}
			close TMP;
			close TMPOUT;
		}else{
			`ln -s $uniref_dir/$file $database_dir/nr20/nr20.$subfix`;
		}
	}
=cut
}

#### (7) Setting up tools and databases for methods
print("\n#### (7) Setting up tools and databases for methods\n\n");

$method_file = "$install_dir/method.list";
$method_info = "$install_dir/installation/server_info";

if(!(-e $method_file) or !(-e $method_info))
{
	print "\nFailed to find method file ($method_file and $method_info), please contact us!\n\n";
}else{
	
	open(IN,$method_info) || die "Failed to open file $method_info\n";
	@contents = <IN>;
	close IN;
	%method_db_tools=();
	foreach $line (@contents)
	{
		chomp $line;
		if(substr($line,0,1) eq '#')
		{
			next;
		}
		$line =~ s/^\s+|\s+$//g;
		if($line eq '')
		{
			next;
		}
		@tmp = split(':',$line);
		$method_db_tools{$tmp[0]} = $tmp[1];
	}
	
	open(IN,$method_file) || die "Failed to open file $method_file\n";
	@contents = <IN>;
	foreach $method (@contents)
	{
		chomp $method;
		if(substr($method,0,1) eq '#')
		{
			next;
		}
		$method =~ s/^\s+|\s+$//g;
		if($method eq '')
		{
			next;
		}
		if(exists($method_db_tools{"${method}_tools"}) and exists($method_db_tools{"${method}_databases"}))
		{
			print "\n\tSetting for method <$method>\n\n";
			### tools
			chdir($tools_dir);
			$basic_tools_list = $method_db_tools{"${method}_tools"};
			@basic_tools = split(';',$basic_tools_list);
			foreach $tool (@basic_tools)
			{
				$toolname = substr($tool,0,index($tool,'.tar.gz'));

				if(-d "$tools_dir/$toolname")
				{
					if(-e "$tools_dir/$toolname/download.done")
					{
						print "\t$toolname is done!\n";
						next;
					}
				}elsif(-f "$tools_dir/$toolname")
				{
						print "\t$toolname is done!\n";
						next;
				}
				
				if(-e $tool)
				{
					`rm $tool`;
				}				
				`wget http://sysbio.rnet.missouri.edu/multicom_db_tools/tools/$tool`;
				
				if(-e "$tool")
				{
					print "\n\t\t$tool is found, start extracting files......\n\n";
					`tar -zxf $tool`;
					
					if($tool eq 'ffas_soft.tar.gz')
					{
						chdir("$tools_dir/$toolname/blast/db/");
						if(!(-e "nr85s.tar.gz"))
						{
							die "!!!! Failed to find nr85s.tar.gz in <$tools_dir/$toolname/blast/db/>, please contact us\n\n";
						}
						`tar -zxf nr85s.tar.gz`;
						
					}
					chdir($tools_dir);
					`echo 'done' > $toolname/download.done`;
					`rm $tool`;
					`chmod -R 755 $toolname`;
				}else{
					die "Failed to download $tool from http://sysbio.rnet.missouri.edu/multicom_db_tools/tools, please contact chengji\@missouri.edu\n";
				}
			}
			
			### databases
			chdir($database_dir);
			$basic_db_list = $method_db_tools{"${method}_databases"};
			@basic_db = split(';',$basic_db_list);
			foreach $db (@basic_db)
			{
				if($db eq 'uniprot20/uniprot20_2016_02')
				{
					
					chdir("$database_dir/$db");
					
					
					$uniprot20_dir = "$multicom_db_tools_dir/databases/uniprot20/";
					if(-e "$uniprot20_dir/uniprot20_2016_02/download.done" and -e "$uniprot20_dir/uniprot20_2016_02/uniprot20_2016_02_hhm_db" and -e "$uniprot20_dir/uniprot20_2016_02/uniprot20_2016_02_a3m_db" )
					{
						print "\t\t$db is done!\n";
						next;
					}
					
					-d $uniprot20_dir || `mkdir $uniprot20_dir/`;;
					chdir($uniprot20_dir);
					
					if(-e "uniprot20_2016_02/uniprot20_2016_02_hhm.ffdata")
					{
						print "\t\tuniprot20_2016_02 has been downloaded, skip!\n";
						`echo 'done' > uniprot20_2016_02/download.done`;
					
					}else{
						print("\n\t\t#### Download uniprot20\n\n");
						if(-e "uniprot20_2016_02.tgz")
						{
							`rm uniprot20_2016_02.tgz`;
						}
						`wget http://wwwuser.gwdg.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/old-releases/uniprot20_2016_02.tgz`;
						if(-e "uniprot20_2016_02.tgz")
						{
							print "\t\tuniprot20_2016_02.tgz is found, start extracting files......\n";
							`tar -xf uniprot20_2016_02.tgz`;
							`echo 'done' > uniprot20_2016_02/download.done`;
							`rm uniprot20_2016_02.tgz`;
							`chmod -R 755 uniprot20_2016_02`;
						}else{
							die "Failed to download uniprot20_2016_02.tgz from http://wwwuser.gwdg.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/old-releases/\n";
						}

					}
					chdir("$uniprot20_dir/uniprot20_2016_02/");
					if(-l "uniprot20_2016_02_a3m_db")
					{
						`rm uniprot20_2016_02_a3m_db`; 
						`rm uniprot20_2016_02_hhm_db`; 
					
						$status = system("rm uniprot20_2016_02_a3m_db");
						if($status)
						{
							 die "Failed to remove file (uniprot20_2016_02_a3m_db), check the permission\n";
						}
						$status = system("rm uniprot20_2016_02_hhm_db");
						if($status)
						{
							 die "Failed to remove file (uniprot20_2016_02_hhm_db), check the permission\n";
						}
					}
					
					$status = system("ln -s uniprot20_2016_02_a3m.ffdata uniprot20_2016_02_a3m_db");
					if($status)
					{
						 die "Failed to link database(uniprot20_2016_02_a3m_db), check the permission\n";
					}
					$status = system("ln -s uniprot20_2016_02_hhm.ffdata uniprot20_2016_02_hhm_db");
					if($status)
					{
						 die "Failed to link database(uniprot20_2016_02_hhm_db), check the permission\n";
					}
			
					`chmod -R 755 uniprot20_2016_02_a3m_db`;
					`chmod -R 755 uniprot20_2016_02_hhm_db`;
					
					next;
				}
				
				if($db eq 'uniprot30/uniclust30_2017_10')
				{
					
					chdir("$database_dir/$db");
					
					
					$uniprot30_dir = "$multicom_db_tools_dir/databases/uniprot30/";
					if(-e "$uniprot30_dir/uniclust30_2017_10/download.done" and -e "$uniprot30_dir/uniclust30_2017_10/uniclust30_2017_10_hhm_db" )
					{
						print "\t\t$db is done!\n";
						next;
					}
					
					-d $uniprot30_dir || `mkdir $uniprot30_dir/`;;
					chdir($uniprot30_dir);
					
					if(-e "uniclust30_2017_10/uniclust30_2017_10_hhm.ffdata")
					{
						print "\t\tuniclust30_2017_10 has been downloaded, skip!\n";
						`echo 'done' > uniclust30_2017_10/download.done`;
					
					}else{
						print("\n\t\t#### Download uniprot30\n\n");
						if(-e "uniclust30_2017_10_hhsuite.tar.gz")
						{
							`rm uniclust30_2017_10_hhsuite.tar.gz`;
						}
						`wget http://wwwuser.gwdg.de/~compbiol/uniclust/2017_10/uniclust30_2017_10_hhsuite.tar.gz`  || die "Failed to download, check permission or file path\n";
						if(-e "uniclust30_2017_10_hhsuite.tar.gz")
						{
							print "\t\tuniclust30_2017_10_hhsuite.tar.gz is found, start extracting files......\n";
							`tar -zxf uniclust30_2017_10_hhsuite.tar.gz`;
							`echo 'done' > uniclust30_2017_10/download.done`;
							`rm uniclust30_2017_10_hhsuite.tar.gz`;
							`chmod -R 755 uniclust30_2017_10`;
						}else{
							die "Failed to download uniclust30_2017_10_hhsuite.tar.gz from http://wwwuser.gwdg.de/~compbiol/uniclust/2017_10/\n";
						}
					}
					chdir("$uniprot30_dir/uniclust30_2017_10/");
					if(-l "uniclust30_2017_10_a3m_db")
					{
						`rm uniclust30_2017_10_a3m_db`; 
						`rm uniclust30_2017_10_hhm_db`; 
					}
				
					`ln -s uniclust30_2017_10_a3m.ffdata uniclust30_2017_10_a3m_db`;
					`ln -s uniclust30_2017_10_hhm.ffdata uniclust30_2017_10_hhm_db`;
					`chmod -R 755 uniclust30_2017_10_a3m_db`;
					`chmod -R 755 uniclust30_2017_10_hhm_db`;
					
					next;
				}
				
				
				$dbname = substr($db,0,index($db,'.tar.gz'));
				if(-e "$database_dir/$dbname/download.done")
				{
					print "\t\t$dbname is done!\n";
					next;
				}
				`wget http://sysbio.rnet.missouri.edu/multicom_db_tools/databases/$db`  || die "Failed to download, check permission or file path\n";
				if(-e "$db")
				{
					print "\t\t$db is found, start extracting files......\n\n";
					`tar -zxf $db`;
					`echo 'done' > $dbname/download.done`;
					`rm $db`;
					`chmod -R 755 $dbname`;
				}else{
					die "Failed to download $db from http://sysbio.rnet.missouri.edu/multicom_db_tools/databases, please contact chengji\@missouri.edu\n";
				}
			}
			
			
			#### link raptox NR database 
			if($method eq 'raptorx')
			{
				$raptorx_nr = "$tools_dir/RaptorX4/CNFsearch1.66/databases/NR_new/";
				if(!(-d $raptorx_nr))
				{
					next;
				}
				$uniref_dir = "$multicom_db_tools_dir/databases/uniref";
				chdir($uniref_dir);
				opendir(DBDIR,"$uniref_dir") || die "Failed to open $uniref_dir\n";
				@files = readdir(DBDIR);
				closedir(DBDIR);
				foreach $file (@files)
				{
					if($file eq '.' or $file eq '..')
					{
						next;
					}
					
					if(substr($file,0,9) eq 'uniref90.')
					{
						$subfix = substr($file,9);
						if(-l "$raptorx_nr/nr90.$subfix")
						{
							`rm $raptorx_nr/nr90.$subfix`; 
						}
						if($subfix eq 'pal')
						{
							## change to nr90
							open(TMP,"$uniref_dir/$file");
							open(TMPOUT,">$raptorx_nr/nr90.pal");
							while(<TMP>)
							{
								$li=$_;
								chomp $li;
								if(index($li,'uniref90')>=0)
								{
									$li =~ s/uniref90/nr90/g;
									print TMPOUT "$li\n";
								}else{
									print TMPOUT "$li\n";
								}
							}
							close TMP;
							close TMPOUT;
						}else{
							`ln -s $uniref_dir/$file $raptorx_nr/nr90.$subfix`;
							`chmod -R 755 $raptorx_nr/nr90.$subfix`;
						}
					}
					
					if(substr($file,0,9) eq 'uniref70.')
					{
						$subfix = substr($file,9);
						if(-l "$raptorx_nr/nr70.$subfix")
						{
							`rm $raptorx_nr/nr70.$subfix`; 
						}
						if($subfix eq 'pal')
						{
							## change to nr90
							open(TMP,"$uniref_dir/$file");
							open(TMPOUT,">$raptorx_nr/nr70.pal");
							while(<TMP>)
							{
								$li=$_;
								chomp $li;
								if(index($li,'uniref70')>=0)
								{
									$li =~ s/uniref70/nr70/g;
									print TMPOUT "$li\n";
								}else{
									print TMPOUT "$li\n";
								}
							}
							close TMP;
							close TMPOUT;
						}else{
							`ln -s $uniref_dir/$file $raptorx_nr/nr70.$subfix`;
							`chmod -R 755 $raptorx_nr/nr70.$subfix`;
						}
						
					}
				}
			}
			
		}else{
			print "Failed to find database/tool definition for method $method\n";
		}
	}
}


print "#########  (2) Configuring tools\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_tools_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_tools($option_list,'tools',$multicom_db_tools_dir);

print "#########  Configuring tools, done\n\n\n";



$tooldir = $multicom_db_tools_dir.'/tools/pspro2/';
if(-d $tooldir)
{
	print "#########  Setting up pspro2\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}


$tooldir = $multicom_db_tools_dir.'/tools/pspro2_lite/';
if(-d $tooldir)
{
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}

$tooldir = $multicom_db_tools_dir.'/tools/Domain_assembly/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up Domain_assembly\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl $tooldir");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}

$tooldir = $multicom_db_tools_dir.'/tools/nncon1.0/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up nncon1.0\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}

$tooldir = $multicom_db_tools_dir.'/tools/model_eva1.0/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up modeleva\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}


$tooldir = $multicom_db_tools_dir.'/tools/betacon/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up betacon\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}


$tooldir = $multicom_db_tools_dir.'/tools/betapro-1.0/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up betapro-1.0\n";
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}

######
$tooldir = $multicom_db_tools_dir.'/tools/disorder_new/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up disorder\n"; 
	chdir $tooldir;
	if(-f 'configure.pl')
	{
		$status = system("perl configure.pl");
		if($status){
			die "Failed to run perl configure.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}



$tooldir = $multicom_db_tools_dir.'/tools/RaptorX4/CNFsearch1.66/';
if(-d $tooldir)
{
	print "\n\n#########  Setting up raptorx\n";
	chdir $tooldir;
	if(-f 'setup.pl')
	{
		$status = system("perl setup.pl");
		if($status){
			die "Failed to run perl setup.pl\n";
			exit(-1);
		}
	}else{
		die "The setup.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}


$tooldir = $multicom_db_tools_dir.'/tools/SCRATCH-1D_1.1/';
if(-d $tooldir)
{
	print "\n#########  Setting up SCRATCH \n";
	chdir $tooldir;
	if(-f 'install.pl')
	{
		$status = system("perl install.pl");
		if($status){
			die "Failed to run perl install.pl \n";
			exit(-1);
		}
	}else{
		die "The configure.pl file for $tooldir doesn't exist, please contact us(Jie Hou: jh7x3\@mail.missouri.edu)\n";
	}
}

my($addr_mod9v7) = $multicom_db_tools_dir."/tools/modeller9v7/bin/mod9v7";
if(-e $addr_mod9v7)
{
	print "\n#########  Setting up MODELLER 9v7 \n";
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
	#system("chmod 777 $deep_mod9v7");
	$modeller_conf = $multicom_db_tools_dir."/tools/modeller9v7/modlib/modeller/config.py";
	$OUT = new FileHandle ">$modeller_conf";
	print $OUT "install_dir = r\'$multicom_db_tools_dir/tools/modeller9v7/\'\n";
	print $OUT "license = \'MODELIRANJE\'";
	$OUT->close();
	#system("chmod 777 $modeller_conf");
	system("cp $deep_mod9v7 $addr_mod9v7");
	print "Done\n";
}



my($addr_mod9v16) = $multicom_db_tools_dir."/tools/modeller-9.16/bin/mod9.16";
if(-e $addr_mod9v16)
{
	print "\n#########  Setting up MODELLER 9v16 \n";
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
	#system("chmod 777 $deep_mod9v16");
	$modeller_conf = $multicom_db_tools_dir."/tools/modeller-9.16/modlib/modeller/config.py";
	$OUT = new FileHandle ">$modeller_conf";
	print $OUT "install_dir = r\'$multicom_db_tools_dir/tools/modeller-9.16/\'\n";
	print $OUT "license = \'MODELIRANJE\'";
	$OUT->close();
	#system("chmod 777 $modeller_conf");
	system("cp $deep_mod9v16 $addr_mod9v16");
	print "Done\n";
}

####### update prc database 
$prc_db = "$multicom_db_tools_dir/databases/prc_db/";
if(-d $prc_db)
{
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
}


$addr_scwrl4 = $multicom_db_tools_dir."/tools/scwrl4";
if(-d $addr_scwrl4)
{
	print "\n#########  Setting up scwrl4 \n";
	$addr_scwrl_orig = $addr_scwrl4."/"."Scwrl4.ini";
	$addr_scwrl_back = $addr_scwrl4."/"."Scwrl4.ini.back";
	system("cp $addr_scwrl_orig $addr_scwrl_back");
	@ttt = ();
	$OUT = new FileHandle ">$addr_scwrl_orig";
	$IN=new FileHandle "$addr_scwrl_back";
	while(defined($line=<$IN>))
	{
		chomp($line);
		@ttt = split(/\s+/,$line);
		
		if(@ttt>1 && $ttt[1] eq "FilePath")
		{
			print $OUT "\tFilePath\t=\t$addr_scwrl4/bbDepRotLib.bin\n"; 
		}
		else
		{
			print $OUT $line."\n";
		}
	}
	$IN->close();
	$OUT->close();
	print "Done\n";
}


print "\n\n";




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
					next;
					#die "\nOption file $option_default not exists.\n";
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


