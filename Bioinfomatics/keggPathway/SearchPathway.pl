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


open(Input,"selectgene");
open(Output,">pathway.txt");
$n=1;
while($line=<Input>)
{
	chomp($line);
	@splitline=split("\t",$line);
	
	$result=$serv->get_pathways_by_genes(["rno:".$splitline[1]]);
	print "$n\n";
	foreach $tmp (@{$result})
	{
		$name=$serv->btit($tmp);
		print Output "$line\t$name";
	}
	$n++;
}
close(Input);
close(Output);
