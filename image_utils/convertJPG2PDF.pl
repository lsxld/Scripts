#!/usr/bin/perl
use strict;

my $tool_path="C:/Program Files/ImageMagick-7.0.5-Q16";
my $src_path="F:/LMMPPT_bak";

my @date_array=("0406","0407","0408");
my %title=("0406" => ["����Դ��˼άת��",
					  "ҽѧ��Ϣ���ݼ��ͻ�����ģʽ�Ĵ���",
					  "̽�ֻ���Ϊ���ĵ�ҽѧ��Ϣ�ǻ۷���",
					  "��ͳMI��������ϵĴ���ģʽ̽�ֺ�ʵ��",
					  "MI����רҵ��ת��IMI΢��ƽ̨",
					  "���ʱ�ڵ�ҽѧ��Ϣת��",
					  "��Ϣ��ըʱ����ҽѧ��Ϣ��׼����̽��",
					  "��ҽѧ��Ϣ��ҽѧ��ͨ�䱻��Ϊ������MedicalExcellence"],
		   "0407" => ["�ǻ�ҽѧ��ҽѧ��δ����չ�����»���",
					  "���ֻ�ʱ����ҽѧ��ֵ������",
					  "2016���2015��ҽѧ�����������Ԥ��δ��",
					  "�������ҽѧ�˲�ҽѧ��ת���뷢չ��������",
					  "��Ʒ�������ڹ�����RWE��ο��ٸ�Ч�ھ�����",
					  "�ƶ������ݲɼ�",
					  "֤�ݻ�������ϵ��ҽѧ���ݵ��ھ���ʹ��",
					  "��������ҽѧ�����������ʵ��",
					  "����InsigntGenerationҽѧ��ֵ",
					  "��������ҵ�Ƕ���ο���ҽѧ����",
					  "ר�ҹ��ʻ��ȡ�ͻ��۲�",
					  "KOL Insight���к��ٴ��о��ؼ��ɹ�ҪҪ��",
					  "KOL Insight�����²�Ʒ��׼ҽѧ���ʵʩ",
					  "KOL Insight���Ƴ����Ʒѧ������",
					  "MSL��InsightGeneration�еĽ�ɫ���ֵ"],
		   "0408" => ["Good MSL Practice-RDPACҽѧ���������Ƥ��",
		              "�ͻ�����MSL����ģ������������",
					  "MSL��Ϊ�ɿ���ս�Ժ������ķ�ʽ",
					  "MSL��γ�ΪKOL����ר��",
					  "MSLҽѧ��ͨ��������",
					  "������ҽѧ��ͨ��������",
					  "΢��ƽ̨��ҽѧ��Ϣ��Ч��ͨCaseStudy",
					  "�������ֻ�ƽ̨���д���ѧ������",
					  "����������KOL�۲�ʵ�־�׼DataCommunication",
					  "��ý��ҽѧ����ո¶ҽѧ��ֵ",
					  "ȥ���Ļ������µ����ն�ҽѧ������ģʽ",
					  "�Ʋ������߹��������ռ���ҽ���������Ͻ������",
					  "��ý�廼�߽�����ִ�м�����ģʽ",
					  "ҩ�ﾭ��ѧ��չ��ҽѧ������ְ�ܼ��¼�ֵ",
					  "mi��Ϣ�����ṩȫ����Ұҽѧ��ͨ����֧��"]
		);
foreach my $date (@date_array)
{
	for(my $i=0;$i<20;$i++)
	{
		if(-d "$src_path/$date/$i")
		{
			print "$date\_$i".$title{$date}->[$i-1].".pdf","\n";
			convert_dir("$src_path/$date/$i", "$date\_$i".$title{$date}->[$i-1].".pdf");
		}
	}
}

sub convert_dir
{
	my ($srcdir, $outpdf)=@_;
	my $command;
	if(not -e "$srcdir/convert_done")
	{
		$command="\"$tool_path/mogrify.exe\" -bordercolor black -border 1x1 -fuzz 60% -trim -resize 800 $srcdir/IMG*";
		print "Triming and Resizing $srcdir\n";
		system($command);
		$command="\"$tool_path/mogrify.exe\" -background black -deskew 40% $srcdir/*";
		print "Adjusting skew $srcdir\n";
		system($command);
		open(DONE,">$srcdir/convert_done");
		close(DONE);
	}
	$command="\"$tool_path/convert.exe\" $srcdir/IMG* $outpdf";
	print "Generate $outpdf\n";
	system($command);
}