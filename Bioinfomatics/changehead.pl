#!/usr/bin/perl
$fafile=$ARGV[0];
$headfile=$ARGV[1];
$outputfile=$ARGV[2];
open(fasta,$fafile);
open(head,$headfile);
open(out,">$outputfile");
while($line=<fasta>)
{
	if($line=~/^>/)
	{
		$line=<head>;
		print out ">$line";
	}
	else
	{
		print out "$line";
	}
}

