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


#$files		="lib/library.py,scripts/P2_alignment_generation/gen_query_temp_align_proc.pl,software/pspro2/configure.pl,scripts/P1_run_fold_recognition/Analyze_top5_folds.py,scripts/P1_run_fold_recognition/run_multicom_fr.pl,training/P1_evaluate.sh,training/P1_train.sh,training/predict_single.py,training/predict_main.py,training/training_main.py";
$files='src/multicom_ve.pl;src/meta/script/multicom_server_ve.pl';

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

print "#########  Setting up option file\n";
$option_default = $install_dir.'/src/multicom_system_option_casp13.default';
$option_new = $install_dir.'/src/multicom_system_option_casp13';

$option_default = $install_dir.'/src/multicom_system_option_hard_casp13.default';
$option_new = $install_dir.'/src/multicom_system_option_hard_casp13';


$option_default = $install_dir.'/src/test_system/multicom_option_casp13.default';
$option_new = $install_dir.'/src/test_system/multicom_option_casp13';

#blast
$option_default = $install_dir.'/src/meta/blast/cm_option_adv.default';
$option_new = $install_dir.'/src/meta/blast/cm_option_adv';

#psiblast
$option_default = $install_dir.'/src/meta/psiblast/cm_option_adv.default';
$option_new = $install_dir.'/src/meta/psiblast/cm_option_adv';
$option_default = $install_dir.'/src/meta/psiblast/psiblast_option_hard.default';
$option_new = $install_dir.'/src/meta/psiblast/psiblast_option_hard';

#csiblast
$option_default = $install_dir.'/src/meta/csblast/csiblast_option.default';
$option_new = $install_dir.'/src/meta/csblast/csiblast_option';
$option_default = $install_dir.'/src/meta/csblast/csiblast_option.default';
$option_new = $install_dir.'/src/meta/csblast/csiblast_option';
$option_default = $install_dir.'/src/meta/csblast/csiblast_option_hard.default';
$option_new = $install_dir.'/src/meta/csblast/csiblast_option_hard';


#sam
$option_default = $install_dir.'/src/meta/sam/sam_option_nr.default';
$option_new = $install_dir.'/src/meta/sam/sam_option_nr';
$option_default = $install_dir.'/src/meta/sam/sam_option_hard.default';
$option_new = $install_dir.'/src/meta/sam/sam_option_hard';

#prc
$option_default = $install_dir.'/src/meta/prc/prc_option.default';
$option_new = $install_dir.'/src/meta/prc/prc_option';
$option_default = $install_dir.'/src/meta/prc/prc_option_hard.default';
$option_new = $install_dir.'/src/meta/prc/prc_option_hard';

#hmmer
$option_default = $install_dir.'/src/meta/hmmer/hmmer_option.default';
$option_new = $install_dir.'/src/meta/hmmer/hmmer_option';
$option_default = $install_dir.'/src/meta/hmmer/hmmer_option_hard.default';
$option_new = $install_dir.'/src/meta/hmmer/hmmer_option_hard';

#hmmer3
$option_default = $install_dir.'/src/meta/hmmer3/hmmer3_option.default';
$option_new = $install_dir.'/src/meta/hmmer3/hmmer3_option';
$option_default = $install_dir.'/src/meta/hmmer3/hmmer3_option_hard.default';
$option_new = $install_dir.'/src/meta/hmmer3/hmmer3_option_hard';

#hhsearch
$option_default = $install_dir.'/src/meta/hhsearch/hhsearch_option_cluster.default';
$option_new = $install_dir.'/src/meta/hhsearch/hhsearch_option_cluster';
$option_default = $install_dir.'/src/meta/hhsearch/hhsearch_option_hard.default';
$option_new = $install_dir.'/src/meta/hhsearch/hhsearch_option_hard';
$option_default = $install_dir.'/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8.default';
$option_new = $install_dir.'/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8';

#hhsearch1.5
$option_default = $install_dir.'/src/meta/hhsearch1.5/hhsearch1.5_option.default';
$option_new = $install_dir.'/src/meta/hhsearch1.5/hhsearch1.5_option';
$option_default = $install_dir.'/src/meta/hhsearch1.5/hhsearch1.5_option_hard.default';
$option_new = $install_dir.'/src/meta/hhsearch1.5/hhsearch1.5_option_hard';

#hhsearch1.5.1
$option_default = $install_dir.'/src/meta/hhsearch151/hhsearch151_option.default';
$option_new = $install_dir.'/src/meta/hhsearch151/hhsearch151_option';
$option_default = $install_dir.'/src/meta/hhsearch151/hhsearch151_option_hard.default';
$option_new = $install_dir.'/src/meta/hhsearch151/hhsearch151_option_hard';

#compass
$option_default = $install_dir.'/src/meta/compass/compass_option.default';
$option_new = $install_dir.'/src/meta/compass/compass_option';
$option_default = $install_dir.'/src/meta/compass/compass_option_hard.default';
$option_new = $install_dir.'/src/meta/compass/compass_option_hard';

#multicom
$option_default = $install_dir.'/src/meta/multicom/cm_option_adv.default';
$option_new = $install_dir.'/src/meta/multicom/cm_option_adv';

#construct
$option_default = $install_dir.'/src/meta/construct/construct_option.default';
$option_new = $install_dir.'/src/meta/construct/construct_option';

#msa
$option_default = $install_dir.'/src/meta/msa/msa_option.default';
$option_new = $install_dir.'/src/meta/msa/msa_option';

#hhpred
$option_default = $install_dir.'/src/meta/hhpred/hhpred_option.default';
$option_new = $install_dir.'/src/meta/hhpred/hhpred_option';
$option_default = $install_dir.'/src/meta/hhpred/hhpred_option_hard.default';
$option_new = $install_dir.'/src/meta/hhpred/hhpred_option_hard';

#ffas
$option_default = $install_dir.'/src/meta/ffas/ffas_option.default';
$option_new = $install_dir.'/src/meta/ffas/ffas_option';

#hhblits
$option_default = $install_dir.'/src/meta/hhblits/hhblits_option.default';
$option_new = $install_dir.'/src/meta/hhblits/hhblits_option';

#hhblits3
$option_default = $install_dir.'/src/meta/hhblits3/hhblits3_option.default';
$option_new = $install_dir.'/src/meta/hhblits3/hhblits3_option';

#muster
$option_default = $install_dir.'/src/meta/muster/muster_option_version4.default';
$option_new = $install_dir.'/src/meta/muster/muster_option_version4';

#hhsuite
$option_default = $install_dir.'/src/meta/hhsuite/hhsuite_option.default';
$option_new = $install_dir.'/src/meta/hhsuite/hhsuite_option';
$option_default = $install_dir.'/src/meta/hhsuite/super_option.default';
$option_new = $install_dir.'/src/meta/hhsuite/super_option';

#fugue
$option_default = $install_dir.'/src/meta/fugue/fugue_option.default';
$option_new = $install_dir.'/src/meta/fugue/fugue_option';

#raptorx
$option_default = $install_dir.'/src/meta/raptorx/raptorx_option_version3.default';
$option_new = $install_dir.'/src/meta/raptorx/raptorx_option_version3';

#newblast
$option_default = $install_dir.'/src/meta/newblast/newblast_option.default';
$option_new = $install_dir.'/src/meta/newblast/newblast_option';

#CONFOLD
$option_default = $install_dir.'/src/meta/confold2/CONFOLD_option.default';
$option_new = $install_dir.'/src/meta/confold2/CONFOLD_option';

#UNICON3d
$option_default = $install_dir.'/src/meta/unicon3d/Unicon3D_option.default';
$option_new = $install_dir.'/src/meta/unicon3d/Unicon3D_option';

#rosettacon
$option_default = $install_dir.'/src/meta/rosettacon/rosettacon_option.default';
$option_new = $install_dir.'/src/meta/rosettacon/rosettacon_option';

#fusicon
$option_default = $install_dir.'/src/meta/fusioncon/fusioncon_option.default';
$option_new = $install_dir.'/src/meta/fusioncon/fusioncon_option';





open(IN,$option_default) || die "Failed to open file $option_default\n";
open(OUT,">$option_new") || die "Failed to open file $option_new\n";
while(<IN>)
{
	$line = $_;
	chomp $line;

	if(index($line,'SOFTWARE_PATH')>=0)
	{
		$line =~ s/SOFTWARE_PATH/$install_dir/g;
		print OUT $line."\n";
	}else{
		print OUT $line."\n";
	}
}
close IN;
close OUT;



print "#########  Setting up pspro2\n";
$ssprodir = $install_dir.'/software/pspro2/';
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

print "\n#########  Setting up SCRATCH \n";
$ssprodir = $install_dir.'/software/SCRATCH-1D_1.1/';
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


print "\n#########  Setting up MODELLER \n";
my($addr_mod913) = $install_dir."/software/"."modeller9.13/bin/mod9.13";
if (!-s $addr_mod913) {
	die "Please check $addr_mod913, you can download the modeller and install it by yourself if the current one in the tool folder is not working well, the key is MODELIRANJE.  please install it to the folder $tool_path/modeller9.13, with the file mod9.13 in the bin directory\n";
}

my($deep_mod913) = $install_dir."/software/"."modeller9.13/bin/modeller9.13local";
$OUT = new FileHandle ">$deep_mod913";
$IN=new FileHandle "$addr_mod913";
while(defined($line=<$IN>))
{
        chomp($line);
        @ttt = split(/\=/,$line);

        if(@ttt>1 && $ttt[0] eq "MODINSTALL9v13")
        {
                print $OUT "MODINSTALL9v13=\"$install_dir/software/modeller9.13\"\n";
        }
        else
        {
                print $OUT $line."\n";
        }
}
$IN->close();
$OUT->close();
system("chmod 755 $deep_mod913");
my($modeller_conf) = $install_dir."/software/"."modeller9.13/modlib/modeller/config.py";
$OUT = new FileHandle ">$modeller_conf";
print $OUT "install_dir = r\'$install_dir/software/modeller9.13/\'\n";
print $OUT "license = \'MODELIRANJE\'";
$OUT->close();
system("chmod 755 $modeller_conf");
print "Done\n";

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
