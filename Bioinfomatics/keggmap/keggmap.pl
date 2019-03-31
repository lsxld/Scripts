#!/usr/bin/perl
use SOAP::Lite;

sub SOAP::Serializer::as_ArrayOfstring{
  my ($self, $value, $name, $type, $attr) = @_;
  return [$name, {'xsi:type' => 'array', %$attr}, $value];
}

sub SOAP::Serializer::as_ArrayOfint{
  my ($self, $value, $name, $type, $attr) = @_;
  return [$name, {'xsi:type' => 'array', %$attr}, $value];
}


$wsdl = 'http://soap.genome.jp/KEGG.wsdl';

$serv = SOAP::Lite->service($wsdl);

open(Input,"pathwaylist.txt");
open(Output,">keggurl.txt");
$i=0;
$start=1;
while($line=<Input>)
{
	if($line=~/^>>/)
	{
		if($start==1)
		{
			$start=0;
		}
		else
		{
			search();
		}
		$i=0;
		$pathway=$line;
		$pathway=~s/>>//;
		$pathway=~s/_KEGG//;
		chomp($pathway);
	}
	else
	{
		@splitline=split("\t",$line);
		$genes=$splitline[0];
		$meanvalue=$splitline[1];
		if($meanvalue>0)
		{
			$c="red";
		}
		else
		{
			$c="blue";
		}
		@splitgene=split(" /// ",$genes);
		foreach $g (@splitgene)
		{
			$gene[$i]=$g;
			$color[$i]=$c;
			$i++;
		}
	}
}
search();

sub search
{
	$result=$serv->bfind("path $pathway human");
	$result=~/path:hsa[0-9]+/;
	$path=$&;
	$url=$serv->color_pathway_by_objects($path, \@gene,\@black,\@color);
	print Output "$pathway\n";
	print Output "$url\n";
	system("wget $url -O \"$pathway\".gif");
}
