#!/usr/bin/perl
$begin=$ARGV[1];
$end=$ARGV[2];
$file=$ARGV[0];
open(Input,"./temp.fas");
$t="";
$head=0;
while($t ne "\n")
{
	read(Input,$t,1);
	$head++;
}
$jump=&addenter(1,$begin)+$head-1;
seek(Input,$jump,0);
$jump=&addenter($begin,$end);
read(Input,$t,$jump);
$t=~s/\n//g;
print($t,"\n"); 

sub addenter
{
	my($begin,$end)=@_;
	my($jump)=0;
	$jump=int(($end-$begin+(($begin-1) % 50))/ 50);
	$jump=$end-$begin+$jump+1;
}
