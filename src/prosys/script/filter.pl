#!/usr/bin/perl -w
#Filter Rych's pairs list from html file. 
$file = shift @ARGV;

open(FILE, "$file");

while (<FILE>)
{
	$line = $_;
	chomp $line; 
	$flag1 ='<pre><font face="Courier New,Courier"><font size="+1">'; 
	$length = length($flag1); 
	$flag2 = '</font></font></pre>'; 

	#print "$line\n";
	#print "$flag1 : $flag2\n";
	#<STDIN>;

	if (index($line, $flag1) >= 0 && index($line, $flag2) >= 0)
	{
		$idx2 = index($line, $flag2);
		$content = substr($line, $length, $idx2 - $length);  
		print "$content\n"; 
	}
}
close FILE; 
