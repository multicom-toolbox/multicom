#!/usr/bin/perl -w
####################################################################
#Update the MULTICOM database regularly 01:xx:xx every day once 
#Update NR, HHSearch and Compass databases (new)
#Input: update script (pdb), update script (nr),  db option file
#Author: Jianlin Cheng
#Date: 1/20/2006
#Revised date: 12/30/2009
####################################################################
if (@ARGV != 5)
{
	die "need  four parameters: pdb update script (update_main.pl), nr update script (update_nr.sh), compass update script (update_compass_db.sh), hhsearch1.5 update script, db option file.\n";
}
$update_script = shift @ARGV;
$nr_script = shift @ARGV;
$update_compass = shift @ARGV;
$update_hhsearch15 = shift @ARGV; 
$option_file = shift @ARGV;

-f $update_script || die "can't find update script: $update_script\n";
-f $nr_script || die "can't find $nr_script.\n";
-f $update_compass || die "can't find $update_compass.\n";
-f $update_hhsearch15 || die "can't find $update_hhsearch15.\n";
-f $option_file || die "can't find option file: $option_file\n";

#record the updating state the day 1 to day 31
for ($i = 0; $i <= 31; $i++)
{
	$days[$i] = 0; 	
}

#enter into a loop for the database updating
if (-f "update.log")
{
	`>update.log`; 
}
while (1)
{
	$date = `date`;
	chomp $date;
	@fields = split(/\s+/, $date);
	$day = $fields[2];
	$time = $fields[3];
	$hour = $minute = $second = 0;
	($hour, $minute, $second) = split(/:/, $time);

	if ($hour == 1 && $days[$day] == 0) #read hour 1, and is not updated today yet
	{
		#set the update flag for the day
		for ($i = 0; $i <= 31; $i++)
		{
			$days[$i] = 0; 	
		}
		$days[$day] = 1; 
		
		#update the database 
		print "\nstart to update database on $date\n";
		system("$update_script $option_file >> update.log");
		$date = `date`;
		print "finish updating database on $date";

		#update nr database every Saturday 
		#update compass database every saturday
		$weekday = $fields[0]; 
		if ($weekday eq "Sat")
		{
			print "start to update nr database\n";
			`echo start to update NR database >> update.log`;
			`date >> update.log`;
			system("$nr_script >> update.log"); 
			print "finish updating nr database (see update.log for details) on $date";
			`date >> update.log`;
			`echo finish updating NR database >> update.log`;

			print "start to update hhsearch15 database\n";
			`echo start to update hhsearch15 database >> update.log`;
			`date >> update.log`;
			system("$update_hhsearch15");
			`date >> update.log`;
			`echo finish updating hhsearch15 database >> update.log`;
			print "finish updating hhsearch15 database.\n";

			print "start to update compass database\n";
			`echo start to update compass database >> update.log`;
			`date >> update.log`;
			system("$update_compass");
			`date >> update.log`;
			`echo finish updating compass database >> update.log`;
			print "finish updating compass database.\n";

			#add sp3 update
			print "start to update sparks database\n";
			`echo start to update sparks database >> update.log`;
			`date >> update.log`;
			system("/home/chengji/sparks/lib-bin/updatelib_sp3.job > sparks.log");	
			`date >> update.log`;
			`echo finish updating sparks database >> update.log`;
			print "finish updateing sparks database.\n";	

		}


	}

	sleep(120);
}


