#!/usr/bin/perl
$database=$ARGV[0];
$inputfile=$ARGV[1];

open(input,$inputfile);
while($line=<input>)
{
	@query=split("\t",$line);
	system("fastacmd -d $database -s $query[0] -L $query[1],$query[2]");
}
