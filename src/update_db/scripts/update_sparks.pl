#!/usr/bin/perl -w

#add sp3 update
print "start to update sparks database\n";
`echo start to update sparks database >> update.log`;
`date >> update.log`;
system("/home/chengji/sparks/lib-bin/updatelib_sp3.job > sparks.log");	
`date >> update.log`;
`echo finish updating sparks database >> update.log`;
print "finish updateing sparks database.\n";	


