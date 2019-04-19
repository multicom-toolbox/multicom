#!/usr/bin/perl -w

open(WANG, "wang.list");
@wang = <WANG>;
close WANG;

while (@wang)
{
	$line = shift @wang;
	chomp $line;
	@fields = split(/\s+/, $line);
	for ($i = 1; $i <= 5; $i++)
	{
		`cp ./final_$fields[0]/$fields[0]-$i-s.pdb ./wang`;
	}
}
