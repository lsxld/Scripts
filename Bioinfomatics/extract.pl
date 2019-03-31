#!/usr/bin/perl
$output=$ARGV[0];
open(Out,">$output");
while($line=<STDIN>)
{
	if($line!~/##/)
	{
		@tmp=split("\t",$line);
		if($tmp[2]=~/exon_cluster/)
		{
			$annot=$tmp[8];
			if($annot=~/exon_cluster_id [0-9]+/)
			{
				$exon_id=$&;
				$exon_id=~/[0-9]+/;
				$exon_id=$&;
				print Out "$exon_id\t$tmp[0]\t$tmp[3]\t$tmp[4]\t$tmp[6]\n";
			}
		}
	}
}
