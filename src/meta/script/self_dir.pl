#!/usr/bin/perl -w
################################################################
#remodel all the pdb files using Modeller in a directory
#Author: Jianlin Cheng
#Date: 6/29/2010
################################################################

if (@ARGV != 2)
{
	die "need two parameters: self model script, model dir.\n";
}

$self_program = shift @ARGV;
$model_dir = shift @ARGV;

-f $self_program || die "can't find $self_program.\n";
-d $model_dir || die "can't find $model_dir.\n";

opendir(MDIR, $model_dir) || die "can't open $model_dir.\n";
@models = readdir(MDIR);
closedir MDIR;

chdir $model_dir;
foreach $model (@models)
{
	if ($model =~ /(.+)\.pdb$/)
	{
		$name = $1;
		print "self remodel $model using Modeller...\n";
		system("$self_program $model ${name}self");

		$self_model =	$name . "self.pdb"; 
		if (-f $self_model)
		{
			`mv $model $name.org`; 
			`mv ${name}self.pdb $model`; 	
		}
	}	
}




