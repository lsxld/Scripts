#!/usr/bin/perl
use strict;

my $tool_path="C:/Program Files/ImageMagick-7.0.5-Q16";
my $src_path="F:/LMMPPT_bak";

my @date_array=("0406","0407","0408");
my %title=("0406" => ["创新源于思维转变",
					  "医学信息传递及客户互动模式的创新",
					  "探讨患者为中心的医学信息智慧服务",
					  "传统MI服务基础上的创新模式探讨和实践",
					  "MI助力专业化转型IMI微信平台",
					  "变革时期的医学信息转型",
					  "信息爆炸时代的医学信息精准服务探讨",
					  "从医学信息至医学沟通变被动为主动的MedicalExcellence"],
		   "0407" => ["智慧医学会医学是未来发展带来新机遇",
					  "数字化时代的医学价值及创新",
					  "2016年和2015年医学事务基线数据预判未来",
					  "培养跨界医学人才医学部转型与发展决定因素",
					  "产品生命周期管理中RWE如何快速高效挖掘数据",
					  "移动化数据采集",
					  "证据环驱动体系内医学数据的挖掘与使用",
					  "大数据在医学事务领域最佳实践",
					  "重塑InsigntGeneration医学价值",
					  "管理层从商业角度如何看待医学驱动",
					  "专家顾问会获取客户观察",
					  "KOL Insight上市后临床研究关键成功要要素",
					  "KOL Insight助推新产品精准医学活动的实施",
					  "KOL Insight助推成熟产品学术交流",
					  "MSL在InsightGeneration中的角色与价值"],
		   "0408" => ["Good MSL Practice-RDPAC医学事务工作组白皮书",
		              "客户导向MSL能力模型与能力建设",
					  "MSL成为可靠的战略合作伙伴的方式",
					  "MSL如何成为KOL管理专家",
					  "MSL医学沟通工具先行",
					  "多渠道医学沟通策略先行",
					  "微信平台与医学信息有效沟通CaseStudy",
					  "利用数字化平台进行创新学术交流",
					  "大数据驱动KOL观察实现精准DataCommunication",
					  "多媒体医学教育崭露医学价值",
					  "去中心化趋势下第三终端医学教育新模式",
					  "云病房患者管理数据收集与医生教育整合解决方案",
					  "新媒体患者教育的执行及评估模式",
					  "药物经济学拓展了医学事务新职能及新价值",
					  "mi信息整合提供全局视野医学沟通策略支持"]
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