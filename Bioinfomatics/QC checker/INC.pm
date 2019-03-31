use strict;
use Date::Calc qw(:all);
our %format;

$format{"Total RNA"}{"Left Title"}=["合同编号","Number of Samples","Sample Type","抽提试剂","试剂批号","质检方法","质控标准","Date"];
$format{"Total RNA"}{"Above Title"}=["到样日期"];
$format{"Total RNA"}{"Head"}=["序号","样品名称","浓度","体积","总量","A260/A280","RIN","28S/18S","结果"];
$format{"Total RNA"}{"Check"}=["Number of Samples","Sample Type","到样日期","最后日期","浓度x体积=总量","A260/A280","质控结果"];
$format{"Total RNA"}{"Settings"}=["总量误差",0.05];

$format{"miRNA"}{"Left Title"}=["合同编号","Number of Samples","Sample Type","抽提试剂","试剂批号","质检方法","质控标准","Date"];
$format{"miRNA"}{"Above Title"}=["到样日期"];
$format{"miRNA"}{"Head"}=["序号","样品名称","浓度","体积","总量","A260/A280","RIN","28S/18S","结果"];
$format{"miRNA"}{"Check"}=["Number of Samples","Sample Type","抽提试剂","到样日期","最后日期","浓度x体积=总量","A260/A280","质控结果"];
$format{"miRNA"}{"Settings"}=["总量误差",0.05];

$format{"DNA"}{"Left Title"}=["合同编号","Number of Samples","Sample Type","抽提试剂","试剂批号","质检方法","Date","到样日期"];
$format{"DNA"}{"Above Title"}=[];
$format{"DNA"}{"Head"}=["序号","样品名称","浓度","A260/A280","A260/A230","体积","总量","结果"];
$format{"DNA"}{"Check"}=["Number of Samples","Sample Type","到样日期","最后日期","浓度x体积=总量","A260/A280","A260/A230"];
$format{"DNA"}{"Settings"}=["总量误差",0.05];

use Win32::OLE;
our @title_get_right;
our @title_get_below;
our @sample_head;
our @check_items;
our %settings;
our %log;
our %info;
our $WORD;
our %content;

sub CheckOneFile
{
	my ($sel_format,$file)=@_;
	my $tmpfile=encode("euc-cn",$file);
	$tmpfile=~s/\//\\\\/g;
	if($WORD->Documents==undef)
	{
		$WORD->quit;
		$WORD=new Win32::OLE('Word.Application');
		$WORD->{'Visible'} = 1;
	}
	else
	{
		$WORD->Documents->close;
	}
	my $qc_doc=$WORD->Documents->Open($tmpfile) || die "Can not open $file\n";
	$sel_format=getFormat($qc_doc) if $sel_format eq "Auto Select";
	return 0 if $sel_format eq "Unknown";

	@title_get_right=@{$format{$sel_format}{"Left Title"}};
	@title_get_below=@{$format{$sel_format}{"Above Title"}};
	@sample_head=@{$format{$sel_format}{"Head"}};
	@check_items=@{$format{$sel_format}{"Check"}};
	%settings=@{$format{$sel_format}{"Settings"}};

	%content=();
	getContent($qc_doc);
	delete($info{$file});
	$info{$file}{'FORMAT'}=$sel_format;
	saveContent($file);
	delete($log{$file});
	return checkContent($file);
}

sub getFormat
{
	my $qc_doc=shift;
	my $table=$qc_doc->Tables(1);
	my $head=get_cell_text($table,2,2);
	foreach my $f (keys %format)
	{
		return $f if($head=~/$f/);
	}
	return 'Unkown';
}
sub getContent
{
	my $qc_doc=shift;
	my $table_count=$qc_doc->Tables->{'Count'};
	my ($flag_sample,$flag_sample_head);
	foreach my $itable (1 .. $table_count)
	{
		my $table=$qc_doc->Tables($itable);
		my $row_count=$table->Rows->{'Count'};
		my $col_count=$table->Columns->{'Count'};
		foreach my $irow (1 .. $row_count)
		{
			$flag_sample_head=1 if(get_cell_text($table,$irow,1)=~/^No\./);
			$flag_sample=1 if($flag_sample_head && get_cell_text($table,$irow,1) == 1);
			$flag_sample=0 if($flag_sample && get_cell_text($table,$irow,1) != $content{'SAMPLE_NUM'}+1);
			if($flag_sample_head && (not exists $settings{"Con_unit"}))
			{
				foreach my $icol (1 .. $col_count)
				{
					my $text=get_cell_text($table,$irow,$icol);
					if($text =~/Con\./)
					{
						if($text=~/μg/)
						{
							$settings{"Con_unit"}="ug";
						}
						elsif($text=~/ng/)
						{
							$settings{"Con_unit"}="ng";
						}
						else
						{
							$settings{"Con_unit"}="ug";
						}
					}
					if($text =~/Total/)
					{
						if($text=~/μg/)
						{
							$settings{"Total_unit"}="ug";
						}
						elsif($text=~/ng/)
						{
							$settings{"Total_unit"}="ng";
						}
						else
						{
							$settings{"Total_unit"}="ug";
						}
					}
				}
				
			}
			if($flag_sample)
			{
				my $sample_num=$content{'SAMPLE_NUM'}+1;
				$content{'SAMPLE_NUM'}=$sample_num;
				foreach my $icol (1 .. $col_count)
				{
					next if $icol>scalar(@sample_head);
					my $text=get_cell_text($table,$irow,$icol);
					$content{'SAMPLES'}{$sample_num}{$sample_head[$icol-1]}=$text;
				}
			}
			else
			{
				foreach my $icol (1 .. $col_count)
				{
					my $cell_text=get_cell_text($table,$irow,$icol);
					foreach my $key_word (@title_get_right)
					{
						$content{$key_word}=get_right_cell($table,$irow,$icol) if $cell_text=~/$key_word/;
					}
					foreach my $key_word (@title_get_below)
					{
						$content{$key_word}=get_below_cell($table,$irow,$icol) if $cell_text=~/$key_word/;
					}
				}
			}
		}
	}
}

sub saveContent
{
	my $file=shift;
	foreach my $key_word (@title_get_right,@title_get_below) { $info{$file}{$key_word}=$content{$key_word}; }
	foreach my $isam (1 .. $content{'SAMPLE_NUM'}) 
	{
		foreach my $head (@sample_head)
		{
			$info{$file}{'SAMPLES'}{$isam}{$head}=$content{'SAMPLES'}{$isam}{$head};
		}
	}
	$info{$file}{'SAMPLE_NUM'}=$content{'SAMPLE_NUM'};
}
sub get_cell_text
{
	my ($table,$i,$j)=@_;
	my $cell=$table->Cell($i,$j);
	my $cell_text="";
	$cell_text=$cell->Range->{'Text'} if $cell;
	$cell_text=~s/[\r\n]//g;
	$cell_text=~s/\x7//g;
	$cell_text=~s/^\s+//g;
	$cell_text=~s/\s+$//g;
	return $cell_text;
}
sub get_right_cell
{
	my ($table,$i,$j)=@_;
	return get_cell_text($table,$i,$j+1);
}
sub get_below_cell
{
	my ($table,$i,$j)=@_;
	return get_cell_text($table,$i+1,$j);
}
sub checkContent
{
	my $file=shift;
	my $PASS=1;
	foreach my $item (@check_items)
	{
		if($item eq "Number of Samples")
		{
			$log{$file}{$item}{'head'}="检查样品数量是否为数字，是否与表格中行数相等";
			if(not exists $content{"Number of Samples"})
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="未找到Number of Samples\n";
			}
			elsif($content{"Number of Samples"} !~/\d+/)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="样品数量为\"".$content{"Number of Samples"}."\"必须为数字\n";
			}
			elsif($content{SAMPLE_NUM} eq $content{"Number of Samples"})
			{
				$log{$file}{$item}{'result'}="pass";
			}
			else
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="样品数量为".$content{"Number of Samples"}." 而表格中有".$content{"SAMPLE_NUM"}."个样本\n";
			}
		}
		elsif($item eq "Sample Type")
		{
			$log{$file}{$item}{'head'}="检查样品类型是否不为数字";
			if(not exists $content{"Sample Type"})
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="未找到Sample Type\n";
			}
			elsif($content{"Sample Type"} =~/\d+/)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="样品类型为\"".$content{"Sample Type"}."\"不能是数字\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "浓度x体积=总量")
		{
			my $error=$settings{"总量误差"};
			my $adjust=(exists $settings{"总量调整"})?$settings{"总量调整"}:1;
			$log{$file}{$item}{'head'}="检查浓度x体积是否与总量相差不超过$error";
			my $flag=1;

			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $nd=$content{SAMPLES}{$i}{'浓度'};
				$nd=$nd/1000 if $settings{"Con_unit"} eq "ng";
				my $tj=$content{SAMPLES}{$i}{'体积'};
				my $zl=$content{SAMPLES}{$i}{'总量'};
				$zl=$zl/1000 if $settings{"Total_unit"} eq "ng";
				if(abs($nd*$tj*$adjust-$zl)>($error+1e-10))
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="样本 $i: 浓度($nd)x体积($tj)=".$nd*$tj." 不等于 总量($zl)\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "到样日期")
		{
			$log{$file}{$item}{'head'}="检查到样日期与出报告日期相差时间是否在十天以内";
			my $sample_date=$content{"到样日期"};
			my $date=$content{"Date"};
			my ($year,$month,$day)=parseDate($sample_date);
			my ($t_year,$t_month,$t_day)=parseDate($date);
			if($year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="未知的到样日期格式：$sample_date\n";
				next;
			}
			elsif($t_year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="未知的出报告日期格式：$sample_date\n";
				next;
			}
			my $inter_day=Delta_Days($year,$month,$day,$t_year,$t_month,$t_day);
			if($inter_day<0 || $inter_day>10)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="到样日期为$sample_date , 出报告日期为$date, 相差$inter_day天\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "最后日期")
		{
			$log{$file}{$item}{'head'}="检查出报告日期与当前相差时间是否在两天天以内";
			my $date=$content{"Date"};
			my ($year,$month,$day)=parseDate($date);
			my ($t_year,$t_month,$t_day)=Today();
			if($year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="未知的出报告日期格式：$date\n";
				next;
			}
			my $inter_day=Delta_Days($year,$month,$day,$t_year,$t_month,$t_day);
			if($inter_day<0 || $inter_day>2)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="出报告日期为$date , 与今天相差$inter_day天\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "A260/A280")
		{
			$log{$file}{$item}{'head'}="检查A260/A280是否在1.5~2.2范围内";
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $num=$content{SAMPLES}{$i}{'A260/A280'};
				if($num<1.5 || $num>2.2)
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="样本 $i: A260/A280=".$num." 不符合规定范围\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "A260/A230")
		{
			$log{$file}{$item}{'head'}="检查A260/A230是否在1.0~3.0范围内";
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $num=$content{SAMPLES}{$i}{'A260/A230'};
				if($num<1 || $num>23)
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="样本 $i: A260/A230=".$num." 不符合规定范围\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "抽提试剂")
		{
			$log{$file}{$item}{'head'}="检查抽提试剂不为trizol";
			my $reagent=$content{"抽提试剂"};
			if($reagent=~/trizol/i)
			{
				$PASS=0;
				$log{$file}{$item}{'result'}="fail";
				$log{$file}{$item}{'error'}="抽提试剂为\"$reagent\"\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "质控结果")
		{
			$log{$file}{$item}{'head'}="检查质控结果是否正确";
			my $stand=$content{"质控标准"};
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $rin=$content{SAMPLES}{$i}{'RIN'};
				my $ss=$content{SAMPLES}{$i}{'28S/18S'};
				my $result=$content{SAMPLES}{$i}{'结果'};
				if ($result!~/(Passed)|(Failed)|(合格)|(部分降解)|(降解)/)
				{
					$log{$file}{$item}{'error'}.="样本 $i: 结果\"$result\"不正确，应为Passed或Failed或合格或部分降解或降解\n";
					next;
				}
				my $case1=($rin>=7.0 && $ss>=0.7);
				my $case2=($rin>=7.0 && $ss <=0.7);
				my $case3=($rin>=6.0 && $rin<7.0);
				my $case4=($rin<6.0);
				if($case1 && (($result ne "Passed") && ($result ne "合格")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="样本 $i: RIN=$rin(>=7.0), 18S/28S=$ss(>=0.7), 应为合格或Passed 而结果为$result\n";
				}
				elsif($case2 && (($result ne "Failed") && ($result ne "部分降解")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="样本 $i: RIN=$rin(>=7.0), 18S/28S=$ss(<0.7), 应为部分降解或Failed 而结果为$result\n";
				}
				elsif($case3 && (($result ne "Failed") && ($result ne "部分降解")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="样本 $i: RIN=$rin(6.0~7.0) 应为部分降解或Failed 而结果为$result\n";
				}
				elsif($case4 && (($result ne "Failed") && ($result ne "降解")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="样本 $i: RIN=$rin(<6.0) 应为降解或Failed 而结果为$result\n";
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
	}
	return $PASS;
}

sub parseDate
{
	my $str=shift;
	if($str=~/(\d+)[\/-](\d+)[\/-](\d+)/)
	{
		return ($1,$2,$3);
	}
	else
	{
		return (0,0,0);
	}
}

1;
