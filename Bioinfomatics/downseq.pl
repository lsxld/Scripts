#!/usr/bin/perl
use Bio::DB::RefSeq;
use Bio::SeqIO;
open(Seqfile,"../data/output/nimseq.tmp");
@split=<Seqfile>;
chomp(@split);
my $db = Bio::DB::RefSeq->new(-retrievaltype=>'tempfile',-format=>'fasta'); # if you want NT seqs
# use STDOUT to write sequences
my $out = new Bio::SeqIO(-format => 'largefasta',-file=>'>1.txt');
my $seqio=$db->get_Stream_by_id(@split);
print "Success!!","\n";
while(my $seq=$seqio->next_seq)
{
	print $seq->primary_id,"\n";
#	$out->write_seq($seq);
}
