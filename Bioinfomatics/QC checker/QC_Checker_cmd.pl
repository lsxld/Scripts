use Win32::OLE;
use strict;
use utf8;
use Encode;
use Tkx;
use Getopt::Long;

our %log;
our %info;

my $selformat;
my $infile;
my $outfile;
my $erroronly=0;
if(!GetOptions(
					"f|format=s"=>\$selformat,
					"i|input=s"=>\$infile,
					"o|output=s"=>\$outfile,
					"erroronly"=>\$erroronly,
					"h|help"=>sub{help();},
					))
{
	die("Error in getting options\n");
}

require "INC.pm";
if($outfile)
{
	open(OUT,">$outfile") || die("Can not open $outfile to write\n");
	select(OUT);
}
$selformat="Auto Select" if($selformat eq "");

our $WORD=new Win32::OLE('Word.Application');
$WORD->{'Visible'} = 1;

my $file=decode("euc-cn",$infile);
my $result=CheckOneFile($selformat,$file);
print showResult($file);
print showInfo($file);

$WORD->quit();


sub showResult
{
	my $file=shift;
	my $onelog=$log{$file};
	my $resultstr="";
	foreach my $item (keys %$onelog)
	{
		my $flag=decode("euc-cn",$$onelog{$item}{"result"});
		next if ($erroronly && $flag eq "pass");
		my $result=($flag eq "pass")?"[正确]":"[错误]";
		$resultstr.=$result;
		my $head=decode("euc-cn",$$onelog{$item}{"head"});
		$resultstr.="$head\n";
		my $error=decode("euc-cn",$$onelog{$item}{"error"});
		$resultstr.="$error\n";
	}
	return encode("euc-cn",$resultstr);
}

sub showInfo
{
	my $file=shift;
	my $resultstr="";
	my $count=$info{$file}{'SAMPLE_NUM'};
	$resultstr.="共 $count 个样品:\n";
	my $oneinfo=$info{$file}{'SAMPLES'};
	my $colnum=3;
	my @showkey=("样品名称","RIN","28S/18S");
	foreach my $isam (1 .. $count)
	{
		foreach my $key (@showkey)
		{
			my $key_encode=encode("euc-cn",$key);
			if(exists($$oneinfo{$isam}{$key_encode}))
			{
				my $val=decode("euc-cn",$$oneinfo{$isam}{$key_encode});
				$resultstr.="$key:$val\t";
			}
		}
		$resultstr.="\n";
	}
	return encode("euc-cn",$resultstr);
}

sub help
{
	print "$0: <-i INPUT> [-o OUTPUT -f FORMAT]
	-i|input            Input word file, must provide full path
	-o|output           Output file, in text format, Default STDOUT
	-f|format           Could be 'Total RNA','miRNA','DNA' or 'Auto Select'(Default)
	-erroronly          Do not print out correct item
	";
	exit 0;
}