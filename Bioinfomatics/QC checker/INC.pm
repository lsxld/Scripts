use strict;
use Date::Calc qw(:all);
our %format;

$format{"Total RNA"}{"Left Title"}=["��ͬ���","Number of Samples","Sample Type","�����Լ�","�Լ�����","�ʼ췽��","�ʿر�׼","Date"];
$format{"Total RNA"}{"Above Title"}=["��������"];
$format{"Total RNA"}{"Head"}=["���","��Ʒ����","Ũ��","���","����","A260/A280","RIN","28S/18S","���"];
$format{"Total RNA"}{"Check"}=["Number of Samples","Sample Type","��������","�������","Ũ��x���=����","A260/A280","�ʿؽ��"];
$format{"Total RNA"}{"Settings"}=["�������",0.05];

$format{"miRNA"}{"Left Title"}=["��ͬ���","Number of Samples","Sample Type","�����Լ�","�Լ�����","�ʼ췽��","�ʿر�׼","Date"];
$format{"miRNA"}{"Above Title"}=["��������"];
$format{"miRNA"}{"Head"}=["���","��Ʒ����","Ũ��","���","����","A260/A280","RIN","28S/18S","���"];
$format{"miRNA"}{"Check"}=["Number of Samples","Sample Type","�����Լ�","��������","�������","Ũ��x���=����","A260/A280","�ʿؽ��"];
$format{"miRNA"}{"Settings"}=["�������",0.05];

$format{"DNA"}{"Left Title"}=["��ͬ���","Number of Samples","Sample Type","�����Լ�","�Լ�����","�ʼ췽��","Date","��������"];
$format{"DNA"}{"Above Title"}=[];
$format{"DNA"}{"Head"}=["���","��Ʒ����","Ũ��","A260/A280","A260/A230","���","����","���"];
$format{"DNA"}{"Check"}=["Number of Samples","Sample Type","��������","�������","Ũ��x���=����","A260/A280","A260/A230"];
$format{"DNA"}{"Settings"}=["�������",0.05];

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
						if($text=~/��g/)
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
						if($text=~/��g/)
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
			$log{$file}{$item}{'head'}="�����Ʒ�����Ƿ�Ϊ���֣��Ƿ��������������";
			if(not exists $content{"Number of Samples"})
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="δ�ҵ�Number of Samples\n";
			}
			elsif($content{"Number of Samples"} !~/\d+/)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="��Ʒ����Ϊ\"".$content{"Number of Samples"}."\"����Ϊ����\n";
			}
			elsif($content{SAMPLE_NUM} eq $content{"Number of Samples"})
			{
				$log{$file}{$item}{'result'}="pass";
			}
			else
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="��Ʒ����Ϊ".$content{"Number of Samples"}." ���������".$content{"SAMPLE_NUM"}."������\n";
			}
		}
		elsif($item eq "Sample Type")
		{
			$log{$file}{$item}{'head'}="�����Ʒ�����Ƿ�Ϊ����";
			if(not exists $content{"Sample Type"})
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="δ�ҵ�Sample Type\n";
			}
			elsif($content{"Sample Type"} =~/\d+/)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="��Ʒ����Ϊ\"".$content{"Sample Type"}."\"����������\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "Ũ��x���=����")
		{
			my $error=$settings{"�������"};
			my $adjust=(exists $settings{"��������"})?$settings{"��������"}:1;
			$log{$file}{$item}{'head'}="���Ũ��x����Ƿ�������������$error";
			my $flag=1;

			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $nd=$content{SAMPLES}{$i}{'Ũ��'};
				$nd=$nd/1000 if $settings{"Con_unit"} eq "ng";
				my $tj=$content{SAMPLES}{$i}{'���'};
				my $zl=$content{SAMPLES}{$i}{'����'};
				$zl=$zl/1000 if $settings{"Total_unit"} eq "ng";
				if(abs($nd*$tj*$adjust-$zl)>($error+1e-10))
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="���� $i: Ũ��($nd)x���($tj)=".$nd*$tj." ������ ����($zl)\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "��������")
		{
			$log{$file}{$item}{'head'}="��鵽��������������������ʱ���Ƿ���ʮ������";
			my $sample_date=$content{"��������"};
			my $date=$content{"Date"};
			my ($year,$month,$day)=parseDate($sample_date);
			my ($t_year,$t_month,$t_day)=parseDate($date);
			if($year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="δ֪�ĵ������ڸ�ʽ��$sample_date\n";
				next;
			}
			elsif($t_year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="δ֪�ĳ��������ڸ�ʽ��$sample_date\n";
				next;
			}
			my $inter_day=Delta_Days($year,$month,$day,$t_year,$t_month,$t_day);
			if($inter_day<0 || $inter_day>10)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="��������Ϊ$sample_date , ����������Ϊ$date, ���$inter_day��\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "�������")
		{
			$log{$file}{$item}{'head'}="�������������뵱ǰ���ʱ���Ƿ�������������";
			my $date=$content{"Date"};
			my ($year,$month,$day)=parseDate($date);
			my ($t_year,$t_month,$t_day)=Today();
			if($year==0)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="δ֪�ĳ��������ڸ�ʽ��$date\n";
				next;
			}
			my $inter_day=Delta_Days($year,$month,$day,$t_year,$t_month,$t_day);
			if($inter_day<0 || $inter_day>2)
			{
				$log{$file}{$item}{'result'}="fail";
				$PASS=0;
				$log{$file}{$item}{'error'}="����������Ϊ$date , ��������$inter_day��\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "A260/A280")
		{
			$log{$file}{$item}{'head'}="���A260/A280�Ƿ���1.5~2.2��Χ��";
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $num=$content{SAMPLES}{$i}{'A260/A280'};
				if($num<1.5 || $num>2.2)
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="���� $i: A260/A280=".$num." �����Ϲ涨��Χ\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "A260/A230")
		{
			$log{$file}{$item}{'head'}="���A260/A230�Ƿ���1.0~3.0��Χ��";
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $num=$content{SAMPLES}{$i}{'A260/A230'};
				if($num<1 || $num>23)
				{
					$flag=0;
					$log{$file}{$item}{'error'}.="���� $i: A260/A230=".$num." �����Ϲ涨��Χ\n";
					$PASS=0;
				}
			}
			$log{$file}{$item}{'result'}=$flag?"pass":"fail";
		}
		elsif($item eq "�����Լ�")
		{
			$log{$file}{$item}{'head'}="�������Լ���Ϊtrizol";
			my $reagent=$content{"�����Լ�"};
			if($reagent=~/trizol/i)
			{
				$PASS=0;
				$log{$file}{$item}{'result'}="fail";
				$log{$file}{$item}{'error'}="�����Լ�Ϊ\"$reagent\"\n";
			}
			else
			{
				$log{$file}{$item}{'result'}="pass";
			}
		}
		elsif($item eq "�ʿؽ��")
		{
			$log{$file}{$item}{'head'}="����ʿؽ���Ƿ���ȷ";
			my $stand=$content{"�ʿر�׼"};
			my $flag=1;
			for(my $i=1;$i<=$content{SAMPLE_NUM};$i++)
			{
				my $rin=$content{SAMPLES}{$i}{'RIN'};
				my $ss=$content{SAMPLES}{$i}{'28S/18S'};
				my $result=$content{SAMPLES}{$i}{'���'};
				if ($result!~/(Passed)|(Failed)|(�ϸ�)|(���ֽ���)|(����)/)
				{
					$log{$file}{$item}{'error'}.="���� $i: ���\"$result\"����ȷ��ӦΪPassed��Failed��ϸ�򲿷ֽ���򽵽�\n";
					next;
				}
				my $case1=($rin>=7.0 && $ss>=0.7);
				my $case2=($rin>=7.0 && $ss <=0.7);
				my $case3=($rin>=6.0 && $rin<7.0);
				my $case4=($rin<6.0);
				if($case1 && (($result ne "Passed") && ($result ne "�ϸ�")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="���� $i: RIN=$rin(>=7.0), 18S/28S=$ss(>=0.7), ӦΪ�ϸ��Passed �����Ϊ$result\n";
				}
				elsif($case2 && (($result ne "Failed") && ($result ne "���ֽ���")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="���� $i: RIN=$rin(>=7.0), 18S/28S=$ss(<0.7), ӦΪ���ֽ����Failed �����Ϊ$result\n";
				}
				elsif($case3 && (($result ne "Failed") && ($result ne "���ֽ���")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="���� $i: RIN=$rin(6.0~7.0) ӦΪ���ֽ����Failed �����Ϊ$result\n";
				}
				elsif($case4 && (($result ne "Failed") && ($result ne "����")))
				{
					$flag=0;
					$PASS=0;
					$log{$file}{$item}{'error'}.="���� $i: RIN=$rin(<6.0) ӦΪ�����Failed �����Ϊ$result\n";
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
