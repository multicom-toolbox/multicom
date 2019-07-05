#!/usr/bin/perl -w
 use FileHandle; # use FileHandles instead of open(),close()
 use Cwd;
 use Cwd 'abs_path';

######################## !!! customize settings here !!! ############################
#																					#
# Set directory of multicom databases and tools								        #

$multicom_db_tools_dir = "/data/commons/MULTICOM_db_tools_v1.1/";							        

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
system("rm $install_dir/installation/MULTICOM_test_codes/*.sh");
configure_file2($option_list,'installation');
print "#########  Configuring examples, done\n\n\n";

system("chmod +x $install_dir/installation/MULTICOM_test_codes/*sh");



system("cp $install_dir/src/run_multicom.sh $install_dir/bin/run_multicom.sh");
system("chmod +x $install_dir/bin/run_multicom.sh");



print "#########  (5) Configuring database update scripts\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_db_list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
configure_file2($option_list,'src');
print "#########  Configuring database update scripts, done\n\n\n";

=pod
print "#########  (6) Check the tools\n";

$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_tools_packages.list";

if (! -f $option_list)
{
        die "\nOption file $option_list not exists.\n";
}
open(IN,$option_list) || die "Failed to open file $option_list\n";
$file_indx=0;
while(<IN>)
{
	$file = $_;
	chomp $file;
	$tool_path = "${install_dir}/$file";
	if(!(-e "$tool_path"))
	{
		die "The tool <$tool_path> is not found. Please check the tool package or contact us\n";
	}
	
}
close IN;
=cut



### compress benchmark dataset
chdir("$install_dir/installation");
`tar -zxf benchmark.tar.gz`;



##### generate scripts for methods, saved in bin
#installation/MULTICOM_programs/.P1_run_hhsearch.sh

print "#########  (7) Configuring multicom programs\n";
$method_file = "$install_dir/method.list";
$option_list = "$install_dir/installation/MULTICOM_configure_files/multicom_programs_list";

`rm $install_dir/installation/MULTICOM_programs/*sh`;
`rm $install_dir/bin/*sh`;

$python_env = 0;
$boost_enable = 0;
if(!(-e $method_file) or !(-e $option_list))
{
	print "\nFailed to find method file ($method_file and $option_list), please contact us!\n\n";
}else{
	open(IN,$option_list) || die "Failed to open file $option_list\n";
	@contents = <IN>;
	close IN;
	%method_programs=();
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
		$method_programs{$tmp[0]} = $tmp[1];
	}
	
	open(IN,$method_file) || die "Failed to open file $method_file\n";
	@contents = <IN>;
	open(TMP,">$install_dir/installation/MULTICOM_configure_files/option.tmp");
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
		if(exists($method_programs{"${method}"}))
		{
			$file = $method_programs{"${method}"};
			print TMP "$file\n";
		}
		if(exists($method_programs{"${method}_easy"}))
		{
			$file = $method_programs{"${method}_easy"};
			print TMP "$file\n";
		}
		if(exists($method_programs{"${method}_hard"}))
		{
			$file = $method_programs{"${method}_hard"};
			print TMP "$file\n";
		}
	}
	close TMP;
	configure_file2("$install_dir/installation/MULTICOM_configure_files/option.tmp",'installation');
	`rm $install_dir/installation/MULTICOM_configure_files/option.tmp`;
	`cp $install_dir/installation/MULTICOM_programs/*sh $install_dir/bin/`;
	
	print "#########  Configuring examples, done\n\n\n";
	
	$method_indx = 0;
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
		$method_indx++;
		
		print  "\n################################################################# Method $method_indx: $method  #################################################################\n\n";
		if(exists($method_programs{"${method}"}))
		{
			$file = $method_programs{"${method}"};
			@tmp = split(/\//,$file);
			$program_file = pop @tmp;
			if(-e "$install_dir/bin/$program_file")
			{
				print "$install_dir/bin/$program_file <target id> <fasta> <output-directory>\n\n";
				print "\t** Example: $install_dir/bin/$program_file T1006 $install_dir/examples/T1006.fasta $install_dir/test_out/T1006_$method\n\n";
			}
			
		}
		if(exists($method_programs{"${method}_easy"}))
		{
			$file = $method_programs{"${method}_easy"};
			@tmp = split(/\//,$file);
			$program_file = pop @tmp;
			if(-e "$install_dir/bin/$program_file")
			{
				print "$install_dir/bin/$program_file <target id> <fasta> <output-directory>\n\n";
				print "\t** Example: $install_dir/bin/$program_file T1006 $install_dir/examples/T1006.fasta $install_dir/test_out/T1006_$method\n\n";
			}
		}
		if(exists($method_programs{"${method}_hard"}))
		{
			$file = $method_programs{"${method}_hard"};
			@tmp = split(/\//,$file);
			$program_file = pop @tmp;
			if(-e "$install_dir/bin/$program_file")
			{
				print "$install_dir/bin/$program_file <target id> <fasta> <output-directory>\n\n";
				print "\t** Example: $install_dir/bin/$program_file T1006 $install_dir/examples/T1006.fasta $install_dir/test_out/T1006_${method}_hard\n\n";
			}
		}
		
		if($method eq 'dncon2')
		{
			$python_env = 1;
			$boost_enable = 1;
		}
	}
	

}

system("chmod +x $install_dir/installation/MULTICOM_test_codes/*sh");

system("cp $install_dir/src/run_multicom.sh $install_dir/bin/run_multicom.sh");
system("chmod +x $install_dir/bin/*.sh");


system("mv $install_dir/installation/MULTICOM_test_codes/T0-run-multicom-*.sh $install_dir/examples");
system("chmod +x $install_dir/examples/*.sh");
system("chmod +x $install_dir/src/visualize_multicom_cluster/*.sh");




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
