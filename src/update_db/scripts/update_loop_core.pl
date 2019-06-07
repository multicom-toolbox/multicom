#!/usr/bin/perl -w
####################################################################
#Update the FOLDpro database regularly 01:xx:xx every day once 
#Update NR, HHSearch and Compass databases (new)
#Input: update script (pdb), update script (nr),  db option file
#Author: Jianlin Cheng
#Date: 1/20/2006
####################################################################
if (@ARGV != 6)
{
	die "need  four parameters: pdb update script (update_main.pl), nr update script (update_nr.sh), compass update script (update_compass_db.sh), hhsearch udpate script, prc update script,  db option file.\n";
}
$update_script = shift @ARGV;
$nr_script = shift @ARGV;
$update_compass = shift @ARGV;
$update_hhsearch15 = shift @ARGV;
$update_prc = shift @ARGV; 
$option_file = shift @ARGV;

-f $update_script || die "can't find update script: $update_script\n";
-f $nr_script || die "can't find $nr_script.\n";
-f $update_compass || die "can't find $update_compass.\n";
-f $update_hhsearch15 || die "can't find $update_hhsearch15.\n";
-f $update_prc || die "can't find $update_prc.\n";
-f $option_file || die "can't find option file: $option_file\n";

#record the updating state the day 1 to day 31
for ($i = 0; $i <= 31; $i++)
{
	$days[$i] = 0; 	
}

#enter into a loop for the database updating
if (-f "update_core.log")
{
	`>update_core.log`; 
}
#while (1)
{
	print "MULTICOM database update loop...\n";
	$date = `date`;
	chomp $date;
	@fields = split(/\s+/, $date);
	$day = $fields[2];
	$time = $fields[3];
	$hour = $minute = $second = 0;
	($hour, $minute, $second) = split(/:/, $time);

#	if ($hour == 1 && $days[$day] == 0) #read hour 1, and is not updated today yet
	{
		#set the update flag for the day
		for ($i = 0; $i <= 31; $i++)
		{
			$days[$i] = 0; 	
		}
		$days[$day] = 1; 
		
		#update the database 
		print "\nstart to update database on $date\n";
		system("$update_script $option_file >> update_core.log");
		$date = `date`;
		print "finish updating database on $date";

		#update hhsearch db
		print "start to update hhsearch15 database\n";
		`echo start to update hhsearch15 database >> update_core.log`;
		`date >> update_core.log`;
		system("$update_hhsearch15");
		`date >> update_core.log`;
		`echo finish updating hhsearch15 database >> update_core.log`;
		print "finish updating hhsearch15 database.\n";

		#update prc db
		print "start to update PRC database\n";
		`echo start to update PRC database >> update_core.log`;
		`date >> update_core.log`;
		system("$update_prc");
		`date >> update_core.log`;
		`echo finish updating PRC database >> update_core.log`;
		print "finish updating PRC database.\n";

		#update ffas db
		print "start to update FFAS database\n";
		`echo start to update FFAS database >> update_core.log`;
		`date >> update_core.log`;
		system("/home/chengji/casp8/ffas/build_db_update.pl");
		`date >> update_core.log`;
		`echo finish updating FFAS database >> update_core.log`;
		print "finish updating FFAS database.\n";


	}

#	sleep(120);
}


