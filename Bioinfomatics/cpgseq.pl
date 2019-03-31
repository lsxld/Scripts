open(CpG,"./input/nimble.cpg");
open(Output,">>nimble.fas");
open(Input,">./temp.fas");
<CpG>;
$nowchr=0;
$linecount=1;
while($line=<CpG>)
{
	@list=split("\t",$line);
	$chr=$list[0];
	$chr=~s/chr//;
	$chr=~s/X/23/;
	$chr=~s/Y/24/;
	if($chr != $nowchr)
	{
		close(Input);
		system("fastacmd -d /mnt/db/blastdb/ucsc_hs_genome -p F -s $chr -o ./temp.fas");
		$nowchr=$chr;
		open(Input,"./temp.fas");
	}
	$begin=$list[1];
	$end=$list[2];
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
	print Output (">CpG|",$linecount,"|chr",$chr,"|",$begin,"-",$end,"\n");
	print Output ($t,"\n\n"); 
	$linecount++;
}

sub addenter
{
	my($begin,$end)=@_;
	my($jump)=0;
	$jump=int(($end-$begin+(($begin-1) % 50))/ 50);
	$jump=$end-$begin+$jump+1;
}

