#!/usr/bin/perl -w
#####################################################################################
#change chain id from "A" to " " for rosetta models
#Author: Jianlin Cheng
#####################################################################################
if (@ARGV != 1)
{
	print "need input rosetta model file.\n";
}

$pdb_file = shift @ARGV; 

open(AB, $pdb_file) || die "can't read $pdb_file.\n";;
@ab = <AB>;
close AB;
open(AB, ">$pdb_file");
while (@ab)
{
     $line = shift @ab;
     if ($line =~ /^ATOM/)
     {
           $left = substr($line, 0, 21);
           $right = substr($line, 22);
           $record = "$left $right";
           print AB $record;
     }
}
close AB;


