#!/usr/bin/perl -w

#convert CASP7 predicted models in one directory into models 
#matching with true targets

if (@ARGV != 3)
{
	die "need 3 parameters: zhang target dir, casp prediction dir, output dir.\n";
}


$zhang_dir = shift @ARGV;
$casp_dir = shift @ARGV;
$output_dir = shift @ARGV;

#-d $output_dir || die "can't find output dir: $output_dir.\n";

`mkdir $output_dir`;

opendir(ZHANG, $zhang_dir) || die "can't read zhang dir.\n";
@targets = readdir ZHANG;
closedir ZHANG;

opendir(CASP, $casp_dir) || die "can't read casp dir.\n";
@casp = readdir CASP;
closedir CASP;

@tfiles = ();
while (@targets)
{
	$tfile = shift @targets;
	if ($tfile eq "." || $tfile eq "..")
	{
		next;
	}
	push @tfiles, $tfile;
}

@cfiles = ();
while (@casp)
{
	$cfile = shift @casp;
	if ($cfile eq "." || $cfile eq "..")
	{
		next;
	}
	push @cfiles, $cfile;
}

#do conversion
while (@tfiles)
{
	$tfile = shift @tfiles;
	$tid = substr($tfile, 0, 5);
	#find the corresponding predicted model file
	for($i =0; $i <@cfiles; $i++)
	{
		$cfile = $cfiles[$i];
		if ($cfile =~ /$tid/)
		{
			system("./pre2zhang.pl $casp_dir/$cfile $zhang_dir/$tfile $output_dir/$cfile");
		}	
	}		
}








