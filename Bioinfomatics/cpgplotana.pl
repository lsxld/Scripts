#!/usr/bin/perl
if(@ARGV!=3)
{
	print("usage:\ncpgplotana.pl cpgplotreportfile cpgidfile outputfile\n");
	print("cpgidfile head:contigid/chrid start stop\n");
	exit(0);
	}
$input=$ARGV[0];
$output=$ARGV[2];
$ID=$ARGV[1];
open(Report,$input);
open(Output,">$output");
open(ID,"$ID");
print Output ("seqid\tFoundNo\tfrom\tend\tlength\tSumCG\tPerCG\tObsExp\n");
while($line=<Report>)
{
	if($line=~/ID/)
	{	
		$line=~/[0-9]+-[0-9]+/;
		$line=$&;
		$line=~/-/;
		$seqid=$`."_".$';
		$id=<ID>;
		@tmp=split("\t",$id);
#		$seqid=$tmp[0]."_".$seqid;
		$seqid=$tmp[0];chomp($seqid);
		while($line!~/\/\//)
		{
			if($line!~/FT/)
			{		
				$line=<Report>;
				next;
			}
			else
			{
				if($line=~/no islands/)
				{
					$find="none";$from="none";$end="none";
					$length="none";$SumCG="none";$PerCG="none";$ObsExp="none";
					print Output ("$seqid\t$find\t$from\t$end\t$length\t$SumCG\t$PerCG\t$ObsExp\n");
					last;
				}
				else
				{
					$find=1;
					while($line!~/numislands/)
					{
						$line=~/[0-9]+\.\.[0-9]+/;$local=$&;
						$local=~/\.\./;
						$from=$`;
						$end=$';
						$line=<Report>;$line=~/[0-9]+$/;$length=$&;
						$line=<Report>;$line=~/[0-9]+$/;$SumCG=$&;
						$line=<Report>;$line=~/=/;$PerCG=$';chomp($PerCG);
						$line=<Report>;$line=~/=/;$ObsExp=$';chomp($ObsExp);
						print Output ("$seqid\t$find\t$from\t$end\t$length\t$SumCG\t$PerCG\t$ObsExp\n");
						$find++;
						$line=<Report>;
					}
				}
			}
			last;
		}
	}
}
