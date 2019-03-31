use Tkx;
use strict;
use utf8;
use Encode;

our %format;
our %log;
our %info;
our $WORD;

my $bcount=6;

my $mw=Tkx::widget->new(".");
Tkx::wm_title(".","QC报告检查");
Tkx::wm_geometry(".","800x600+50+50");
my $frame=$mw->new_ttk__frame;
$frame->configure(-padding=>"0 0");
$frame->g_grid(-row=>0,-column=>0,-sticky=>"nesw");

my $combox=$frame->new_ttk__combobox(-state=>"readonly");
$combox->g_grid(-row=>0,-column=>0,-columnspan=>$bcount,-sticky=>"nesw");
$combox->configure(-values=>"{Auto Select} ".Tkx::list(keys %format));
$combox->current(0);

my $b_start=$frame->new_ttk__button(-text=>"开始检查");
$b_start->g_grid(-row=>0,-column=>$bcount,-sticky=>"nesw",-columnspan=>2,-rowspan=>2);

my $b_add=$frame->new_ttk__button(-text=>"添加文件...");
$b_add->g_grid(-row=>1,-column=>0,-sticky=>"nesw");

my $b_del=$frame->new_ttk__button(-text=>"删除所选");
$b_del->g_grid(-row=>1,-column=>1,-sticky=>"nesw");

my $b_all=$frame->new_ttk__button(-text=>"全部选择");
$b_all->g_grid(-row=>1,-column=>2,-sticky=>"nesw");

my $b_inv=$frame->new_ttk__button(-text=>"反向选择");
$b_inv->g_grid(-row=>1,-column=>3,-sticky=>"nesw");

my $b_mark=$frame->new_ttk__button(-text=>"设置/取消标记");
$b_mark->g_grid(-row=>1,-column=>4,-sticky=>"nesw");

my $b_result=$frame->new_ttk__button(-text=>"设为合格/不合格");
$b_result->g_grid(-row=>1,-column=>5,-sticky=>"nesw");

my $treeview=$frame->new_ttk__treeview;
$treeview->configure(-columns=>"id type result",-height=>25);
$treeview->column("#0",-width=>420);
$treeview->heading("#0",-text=>"文件");
$treeview->column("result",-width=>50,-anchor=>"center");
$treeview->heading("result",-text=>"结果");
$treeview->column("id",-width=>150,-anchor=>"w");
$treeview->heading("id",-text=>"合同编号");
$treeview->column("type",-width=>100,-anchor=>"center");
$treeview->heading("type",-text=>"报告类型");
$treeview->g_grid(-row=>2,-column=>0,-columnspan=>$bcount+1,-sticky=>"nesw");
$treeview->selection();
my $sbar_tree=$frame->new_ttk__scrollbar(-orient=>"vertical",-command=>[$treeview,"yview"]);
$treeview->configure(-yscrollcommand=>[$sbar_tree,"set"]);
$sbar_tree->g_grid(-row=>2,-column=>$bcount+1,-sticky=>"wns");
$treeview->tag_configure("mark",-background=>"#FFC85A");
$treeview->tag_configure("pass",-background=>"green");
$treeview->tag_configure("fail",-background=>"red");

my $tabframe=$frame->new_ttk__notebook;
$tabframe->g_grid(-row=>3,-column=>0,-columnspan=>$bcount+1,-sticky=>"news");

my $resultbox=$tabframe->new_tk__text;
$tabframe->add($resultbox,-text=>"详细信息");
my $sbar_text=$frame->new_ttk__scrollbar(-orient=>"vertical",-command=>[$resultbox,"yview"]);
$resultbox->configure(-yscrollcommand=>[$sbar_text,"set"]);
$sbar_text->g_grid(-row=>3,-column=>$bcount+1,-sticky=>"wns");
$resultbox->configure(-state=>"disabled");
$resultbox->tag_configure("bold_blue",-foreground=>"blue",-font=>"黑体 10 bold");
$resultbox->tag_configure("bold_red",-foreground=>"red",-font=>"黑体 11 bold");
$resultbox->tag_configure("bold_green",-foreground=>"darkgreen",-font=>"黑体 11 bold");
$resultbox->tag_configure("bold",-foreground=>"black",-font=>"黑体 11 bold");
$resultbox->tag_configure("normal",-foreground=>"black",-font=>"宋体 10 normal");

my $infobox=$tabframe->new_tk__text;
$tabframe->add($infobox,-text=>"样本信息");
$infobox->configure(-state=>"disabled");
$infobox->tag_configure("bold_blue",-foreground=>"blue",-font=>"黑体 10 bold");
$infobox->tag_configure("bold_green",-foreground=>"darkgreen",-font=>"黑体 10 bold");
$infobox->tag_configure("bold",-foreground=>"black",-font=>"黑体 10 bold");


$mw->g_grid_rowconfigure(0 ,-weight=>1);
$mw->g_grid_columnconfigure(0,-weight=>1);
$frame->g_grid_rowconfigure(2,-weight=>2);
$frame->g_grid_rowconfigure(3,-weight=>1);
foreach (1 .. $bcount) {$frame->g_grid_columnconfigure($_-1,-weight=>1);}

$b_add->configure(-command=>sub{
		my $filetype=[['Microsoft Word','.doc'],['All','*']];
		my $fn=Tkx::tk___getOpenFile(-title=>"Select QC files",-multiple=>1,-filetypes=>$filetype);
		my @files=Tkx::SplitList($fn);
		InsertFile(@files);
	});
$b_del->configure(-command=>sub{
		$treeview->delete($treeview->selection);
		foreach (Tkx::SplitList($treeview->selection)) {delete $log{$_}; }
	});
$b_all->configure(-command=>sub{
		$treeview->selection_set($treeview->children(""));
	});
$b_inv->configure(-command=>sub{
		$treeview->selection_toggle($treeview->children(""));
	});
$b_mark->configure(-command=>sub{
		my @selfiles=Tkx::SplitList($treeview->selection);
		foreach my $file (@selfiles) {toggleMark($file);}
	});
$b_result->configure(-command=>sub{
		my @selfiles=Tkx::SplitList($treeview->selection);
		foreach my $file (@selfiles) {toggleResult($file);}
	});
$b_start->configure(-command=>sub{
		my $selformat=$combox->get;
		my @selfiles=Tkx::SplitList($treeview->selection);
		my $total=scalar(@selfiles);
		my $fail_count=0;
		my $BB_count=0;
		foreach my $file (@selfiles)
		{
			my $result=CheckOneFile($selformat,$file);
			$fail_count+=(1-$result);
			$result?SetPass($file):SetFail($file);
			showResult($file);
			showInfo($file);
			
			my $key=encode("euc-cn","合同编号");
			my $text=decode("euc-cn",$info{$file}{$key});
			$treeview->set($file,"id",$text);
			$treeview->set($file,"type",$info{$file}{'FORMAT'});
			if($text=~/^BB/)
			{
				$treeview->tag_remove("mark",Tkx::list($file));
				$treeview->tag_add("mark",Tkx::list($file));
				$BB_count++;
			}
		}
		Tkx::tk___messageBox(-type=>"ok",-title=>"信息",-message=>"共检查$total 个文件,$fail_count 个不合格");
		Tkx::tk___messageBox(-type=>"ok",-title=>"信息",-icon=>"warning",-message=>"有$BB_count 个合同编号以BB开头,请注意") if $BB_count>0;
	});
$treeview->g_bind("<1>",[sub{
		my $file=$treeview->identify_item(@_);
		$treeview->selection_remove($treeview->children("")) if $file eq "";
		return if $file eq "";
		showResult($file);
		showInfo($file);
	},Tkx::Ev("%x","%y")]);

$treeview->g_bind("<B1-Motion>",[sub{
		my $file=$treeview->identify_item(@_);
		return if $file eq "";
		$treeview->selection_add(Tkx::list($file));
	},Tkx::Ev("%x","%y")]);

$treeview->g_bind("<B1-ButtonPress>",[sub{
		$treeview->selection_remove($treeview->children(""));
	},Tkx::Ev("%x","%y")]);

$treeview->g_bind("<Double-1>",[sub{
		my $file=$treeview->identify_item(@_);
		return if $file eq "";
		my $selformat=$combox->get; 
		my $tmpfile=encode("euc-cn",$file);
		$tmpfile=~s/\//\\\\/g;
		if($WORD->Documents==undef)
		{
			$WORD->quit;
			$WORD=new Win32::OLE('Word.Application');
			$WORD->{'Visible'} = 1;
		}
		$WORD->Documents->close;
		$WORD->Documents->Open($tmpfile);
	},Tkx::Ev("%x","%y")]);

$treeview->g_bind("<3>",[sub{
		my $file=$treeview->identify_item(@_);
		return if $file eq "";
		toggleResult($file);
	},Tkx::Ev("%x","%y")]);

$treeview->g_bind("<2>",[sub{
		my $file=$treeview->identify_item(@_);
		return if $file eq "";
		toggleMark($file);
	},Tkx::Ev("%x","%y")]);

Tkx::MainLoop();

sub showResult
{
	$resultbox->configure(-state=>"normal");
	my $file=shift;
	$resultbox->delete("1.0","end");
	$resultbox->insert_end("$file\n","bold_blue");
	my $onelog=$log{$file};
	foreach my $item (keys %$onelog)
	{
		my $flag=decode("euc-cn",$$onelog{$item}{"result"});
		my $result=($flag eq "pass")?"[正确]":"[错误]";
		$resultbox->insert_end($result,($flag eq "pass")?"bold_green":"bold_red");
		my $head=decode("euc-cn",$$onelog{$item}{"head"});
		$resultbox->insert_end($head,"bold");
		$resultbox->insert_end("\n");
		my $error=decode("euc-cn",$$onelog{$item}{"error"});
		$resultbox->insert_end($error,"normal");
		$resultbox->insert_end("\n");
	}
	$resultbox->configure(-state=>"disabled");
}

sub showInfo
{
	$infobox->configure(-state=>"normal");
	my $file=shift;
	$infobox->delete("1.0","end");
	$infobox->insert_end("$file\n","bold_blue");
	my $count=$info{$file}{'SAMPLE_NUM'};
	$infobox->insert_end("共 $count 个样品:\n","bold_green");	
	my $oneinfo=$info{$file}{'SAMPLES'};
	my $colnum=3;
	foreach my $isam (1 .. $count)
	{
		my $key=encode("euc-cn","样品名称");
		my $name=decode("euc-cn",$$oneinfo{$isam}{$key});
		$infobox->insert_end("$name\t","bold");
		$infobox->insert_end("\n\n") if $isam % $colnum ==0;
	}
	$infobox->configure(-state=>"disabled");
}

sub InsertFile
{
	my @files=@_;
	foreach my $file (@files)
	{
		$treeview->insert("","end",-id=>$file,-text=>"$file") if not $treeview->exists($file);
	}
	$treeview->selection_set(Tkx::list(@files));
}

sub SetPass
{
	my $file=shift;
	$treeview->set($file,"result","合格");
	$treeview->tag_remove("fail",Tkx::list($file));
	$treeview->tag_add("pass",Tkx::list($file));
}

sub SetFail
{
	my $file=shift;
	$treeview->set($file,"result","不合格");
	$treeview->tag_remove("pass",Tkx::list($file));
	$treeview->tag_add("fail",Tkx::list($file));
}

sub toggleResult
{
	my $file=shift;
	my $result=$treeview->set($file,"result");
	($result eq "合格")? SetFail($file):SetPass($file);
}

sub toggleMark
{
	my $file=shift;
	$treeview->tag_has("mark",$file) ? $treeview->tag_remove("mark",Tkx::list($file)):$treeview->tag_add("mark",Tkx::list($file));
}

1;
