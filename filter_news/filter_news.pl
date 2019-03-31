#!/usr/bin/perl
use strict;

my $in_html=$ARGV[0];
my $out_html=$ARGV[1];
open(IN,$in_html) || die("Could not open $in_html\n");
open(OUT,">$out_html") || die("Could not open $out_html for write\n");

my $inside_body=0;
my $inside_grp=0;
my $inside_news=0;
my @line_grp=();
my @news_grp=();
my $current_title="";
my %title_hash=();
my $linenum=0;
while(my $line=<IN>)
{
	$linenum++;
	chomp($line);
	if($line=~/\<body/)
	{
		$inside_body=1;
	}
	if($line=~/\/body\>/)
	{
		$inside_body=0;
	}
	if($inside_body)
	{
		if($line=~/^<p /)
		{
			$inside_grp=1;
		}
		if($inside_grp)
		{
			push(@line_grp,$line);
		}
		else
		{
			if($inside_news)
			{
				push(@news_grp,$line);
			}
			else
			{
				print OUT "$line\n";
			}
		}
		if($line=~/\/p\>/)
		{
			$inside_grp=0;
			my $whole_line=join(" ",@line_grp);
			if($whole_line=~/\<a href=.+<u>/)
			{
				$inside_news=1;
				if($whole_line=~/\<span style.+[^\>]+\>(.+)\<\/span\>\<\/u\>/)
				{
					$current_title=$1;
				}
				else
				{
					die("$linenum: $whole_line do not have title\n");
				}
			}
			if($inside_news)
			{
				push(@news_grp,join("\n",@line_grp));
				if($whole_line=~/\S{3} \d+, \d{4} \d+:\d{2}:\d{2}/)
				{
					$inside_news=0;
					if(not exists($title_hash{$current_title}))
					{
						print OUT join("\n",@news_grp);
						print OUT "\n";
						$title_hash{$current_title}=1;
					}
					else
					{
						#print OUT "!!!!!Duplicate News!!!!!$current_title\n";
						print "Find duplicated title at line $linenum : $current_title\n";
					}
					@news_grp=();
				}
			}
			else
			{
				print OUT join("\n",@line_grp);
				print OUT "\n";
			}
			@line_grp=();
		}
	}
	else
	{
		print OUT "$line\n";
	}
}