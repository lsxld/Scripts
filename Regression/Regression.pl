#!/tool/pandora64/.package/perl-5.8.8/bin/perl
use lib "/home/shixliu/tools/Regression/Tkx-1.07";
use Tkx;
use strict;
use utf8;
use Encode;
use DBI;

our $debug =0;
our %DVDB=("SRDC"=>{"HOST"=>"srdcit4","USER"=>"reguser","PASSWD"=>"123456",
				"PROJECTS"=>["Tonga","Iceland","Carrizo","Amur"]},
#           "CYB" =>{"HOST"=>"cybvpgsql03.amd.com","USER"=>"reguser","PASSWD"=>"474noSJ6",
#			   "PROJECTS"=>["Tonga","Iceland","Carrizo","Amur"]},
           "CYB" =>{"HOST"=>"cybvpgsql04.amd.com","USER"=>"reguser","PASSWD"=>"474noSJ6",
			   "PROJECTS"=>["Bermuda","Treasure","Fiji","Polaris22"]},
	   );
#our %LOGDIR=("CYB_Tonga_chiplevel_asic"=>"/proj/gpg-sys/Tree/tonga/gpuC_tonga_chiplevel/cds/out/tonga_amd64rh3.0_dbg/logs");
our $db;
our @Projects;
our @Sites=("CYB");
our @Suites=();
our @Trees=();
our @Tests=();
our %Bookmark=();
our @Bookmark_files=("$ENV{HOME}/Bookmark.txt","/home/shixliu/tools/Regression/Bookmark.txt");

our $sel_site=$Sites[0];
refreshProjects();
our $sel_project=$Projects[0];
our $sel_suite;
our $sel_tree;
our $show_count=1;

connectDB($sel_site,$sel_project);
getTrees();
getSuites();

my $mw=Tkx::widget->new(".");
Tkx::wm_title(".","Regression Result");
Tkx::wm_geometry(".","1024x768+50+50");

my $height1=25;
my $height2=80;
my $width1=250;
my $width2=100;
my $frame_lu=$mw->new_ttk__frame(-height=>$height1,-width=>$width1);
$frame_lu->g_grid(-row=>0,-column=>0,-sticky=>"nesw");
my $frame_ru=$mw->new_ttk__frame(-height=>$height1,-width=>$width2);
$frame_ru->g_grid(-row=>0,-column=>1,-sticky=>"nesw");
my $frame_ld=$mw->new_ttk__frame(-height=>$height2,-width=>$width1);
$frame_ld->g_grid(-row=>1,-column=>0,-sticky=>"nesw");
my $frame_rd=$mw->new_ttk__frame(-height=>$height2,-width=>$width2);
$frame_rd->g_grid(-row=>1,-column=>1,-sticky=>"nesw");

my $lab_bookmark=$frame_lu->new_ttk__label(-text=>"Bookmark",-font=>"Consolas 15 bold",-anchor=>"center");
$lab_bookmark->g_grid(-row=>0,-column=>0,-sticky=>"nesw");
my $columnl=0;
my $but_add=$frame_ld->new_ttk__button(-text=>"Add");
$but_add->g_grid(-row=>1,-column=>$columnl++,-sticky=>"nesw");
my $but_del=$frame_ld->new_ttk__button(-text=>"Delete");
$but_del->g_grid(-row=>1,-column=>$columnl++,-sticky=>"nesw");
my $but_save=$frame_ld->new_ttk__button(-text=>"Save");
$but_save->g_grid(-row=>1,-column=>$columnl++,-sticky=>"nesw");
my $but_reload=$frame_ld->new_ttk__button(-text=>"Reload");
$but_reload->g_grid(-row=>1,-column=>$columnl++,-sticky=>"nesw");
my $tv_bookmark=$frame_ld->new_ttk__treeview;
my @bm_heads=("site","project","tree","suite");
my @bm_heads_text=("Site","Project","Tree","Suite");
$tv_bookmark->configure(-columns=>Tkx::list(@bm_heads),-show=>"headings",-displaycolumns=>Tkx::list(@bm_heads));
$tv_bookmark->g_grid(-row=>0,-column=>0,-sticky=>"nesw",-columnspan=>$columnl);
for(my $i=0;$i<@bm_heads;$i++)
{
	$tv_bookmark->heading($bm_heads[$i],-text=>$bm_heads_text[$i]);
	$tv_bookmark->column($bm_heads[$i],-stretch=>1);
}
$tv_bookmark->column("site",-width=>20);
$tv_bookmark->column("project",-width=>40);
$tv_bookmark->column("tree",-width=>90);
$tv_bookmark->column("suite",-width=>30);
getBookmark();

my $column1=0;
my $lab_site=$frame_ru->new_ttk__label(-text=>"Site",-anchor=>"center");
$lab_site->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $box_site=$frame_ru->new_ttk__combobox(-state=>"readonly",-textvariable=>\$sel_site,-width=>3);
$box_site->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
$box_site->configure(-values=>Tkx::list(@Sites));
$box_site->current(0);

my $lab_project=$frame_ru->new_ttk__label(-text=>"Project",-anchor=>"center");
$lab_project->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $box_project=$frame_ru->new_ttk__combobox(-state=>"readonly",-textvariable=>\$sel_project,-width=>5);
$box_project->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
$box_project->configure(-values=>Tkx::list(@Projects));
$box_project->current(0);

my $lab_tree=$frame_ru->new_ttk__label(-text=>"Tree",-anchor=>"center");
$lab_tree->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $box_tree=$frame_ru->new_ttk__combobox(-state=>"readonly",-textvariable=>\$sel_tree,-width=>10);
$box_tree->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
$box_tree->configure(-values=>Tkx::list(@Trees));

my $lab_suite=$frame_ru->new_ttk__label(-text=>"Suite",-anchor=>"center");
$lab_suite->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $box_suite=$frame_ru->new_ttk__combobox(-state=>"readonly",-textvariable=>\$sel_suite,-width=>3);
$box_suite->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
$box_suite->configure(-values=>Tkx::list(@Suites));

my $lab_num=$frame_ru->new_ttk__label(-text=>"Latest Round",-anchor=>"center");
$lab_num->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $num_box=$frame_ru->new_tk__spinbox(-from =>1,-to =>200,-textvariable =>\$show_count,-width=>3);
$num_box->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");
my $but_view=$frame_ru->new_ttk__button(-text=>"View");
$but_view->g_grid(-row=>0,-column=>$column1++,-sticky=>"nesw");

my $tv_regress=$frame_rd->new_ttk__treeview;
my @heads=("changelist","starttime","endtime","pass","fail","total","rate","logdir");
my @heads_text=("ChangeList","Start Time","End Time","Pass","Fail","Total","Passing Rate","Log Directory");
$tv_regress->configure(-columns=>Tkx::list(@heads));
$tv_regress->column("#0",-width=>100);
$tv_regress->heading("#0",-text=>"RunID");
for(my $i=0;$i<@heads;$i++)
{
	$tv_regress->column($heads[$i],-anchor=>"w",-width=>90);
	$tv_regress->heading($heads[$i],-text=>$heads_text[$i]);
}
$tv_regress->column("starttime",-width=>150);
$tv_regress->column("endtime",-width=>150);
$tv_regress->column("pass",-width=>40);
$tv_regress->column("fail",-width=>40);
$tv_regress->column("total",-width=>50);
$tv_regress->column("rate",-anchor=>"center");
$tv_regress->column("logdir",-width=>300);
$tv_regress->g_grid(-row=>0,-column=>0,-sticky=>"nesw");
$tv_regress->tag_configure("allpass",-background=>"#AAFFAA");
$tv_regress->tag_configure("allfail",-background=>"#FFAAAA");
$tv_regress->tag_configure("allpart",-background=>"#FFFFAA");
$tv_regress->tag_configure("blockpass",-foreground=>"#009900");
$tv_regress->tag_configure("blockfail",-foreground=>"#AA0000");
$tv_regress->tag_configure("blockpart",-foreground=>"#888800");
my $sbar_regress=$frame_rd->new_ttk__scrollbar(-orient=>"vertical",-command=>[$tv_regress,"yview"]);
$sbar_regress->g_grid(-row=>0,-column=>1,-sticky=>"wns");
$tv_regress->configure(-yscrollcommand=>[$sbar_regress,"set"]);
my $sbar_regress_v=$frame_rd->new_ttk__scrollbar(-orient=>"horizontal",-command=>[$tv_regress,"xview"]);
$sbar_regress_v->g_grid(-row=>1,-column=>0,-sticky=>"ewn",-columnspan=>2);
$tv_regress->configure(-xscrollcommand=>[$sbar_regress_v,"set"]);

$frame_ld->g_grid_propagate(0);
$frame_lu->g_grid_propagate(0);
$frame_ru->g_grid_propagate(0);
$frame_rd->g_grid_propagate(0);
$mw->g_grid_rowconfigure(1 ,-weight=>1);
$mw->g_grid_columnconfigure(1,-weight=>1);
$frame_lu->g_grid_rowconfigure(0,-weight=>1);
$frame_lu->g_grid_columnconfigure(0,-weight=>1);
$frame_ld->g_grid_rowconfigure(0,-weight=>1);
foreach (1 .. $columnl) {$frame_ld->g_grid_columnconfigure($_-1,-weight=>1);}
$frame_ru->g_grid_rowconfigure(0,-weight=>1);
foreach (1 .. $column1) {$frame_ru->g_grid_columnconfigure($_-1,-weight=>1);}
$frame_rd->g_grid_rowconfigure(0,-weight=>1);
$frame_rd->g_grid_columnconfigure(0,-weight=>1);

$box_site->g_bind("<<ComboboxSelected>>",sub{
	refreshProjects();
	$box_project->configure(-values=>Tkx::list(@Projects));
	$sel_project=$Projects[0];
	refreshDB();
	});
$box_project->g_bind("<<ComboboxSelected>>",sub{
	refreshDB();
	});
$box_tree->g_bind("<<ComboboxSelected>>",sub{
	getSuites();
	$box_suite->configure(-values=>Tkx::list(@Suites));
	});

$but_add->configure(-command=>sub{
		addBookmark($sel_site,$sel_project,$sel_tree,$sel_suite);
	});

$but_del->configure(-command=>sub{
		my $item=$tv_bookmark->selection;
		return if $item eq "";
		delete($Bookmark{$item});
		$tv_bookmark->delete($item);
	});

$but_reload->configure(-command=>sub{
		getBookmark();
	});

$but_save->configure(-command=>sub{
		my $file=$Bookmark_files[0];
		if(open(OUT,">$file"))
		{
			foreach my $item (Tkx::SplitList($tv_bookmark->children("")))
			{
				print OUT "$item\n";
			}
			close(OUT);
		}
	});

$but_view->configure(-command=>sub{
	show_summary();
	});

$tv_regress->g_bind("<Double-1>",[sub{
		my $rrid=$tv_regress->identify_item(@_);
		return if $rrid =~/_ALL/;
		return if $rrid eq "";
		showTestWin($rrid);
	},Tkx::Ev("%x","%y")]);

$tv_regress->g_bind("<1>",[sub{
		my $rrid=$tv_regress->identify_item(@_);
		$tv_regress->selection_remove($tv_regress->selection) if $rrid eq "";
	},Tkx::Ev("%x","%y")]);

$tv_bookmark->g_bind("<1>",[sub{
		my $item=$tv_bookmark->identify_item(@_);
		$tv_bookmark->selection_remove($tv_bookmark->selection) if $item eq "";
	},Tkx::Ev("%x","%y")]);

$tv_bookmark->g_bind("<Double-1>",[sub{
		my $item=$tv_bookmark->identify_item(@_);
		return if $item eq "";
		my $site=$tv_bookmark->set($item,"site");
		my $project=$tv_bookmark->set($item,"project");
		my $tree=$tv_bookmark->set($item,"tree");
		my $suite=$tv_bookmark->set($item,"suite");
		$suite="ALL" if $suite eq "";
		$sel_site=$site;
		refreshProjects();
		$box_project->configure(-values=>Tkx::list(@Projects));
		$sel_project=$project;
		refreshDB();
		return if grep(/$tree/,@Trees)==0;
		$sel_tree=$tree;
		getSuites();
		$box_suite->configure(-values=>Tkx::list(@Suites));
		return if grep(/$suite/,@Suites)==0;
		$sel_suite=$suite;
		show_summary();
	},Tkx::Ev("%x","%y")]);

Tkx::MainLoop();
sub refreshProjects
{
	@Projects=();
	push(@Projects, @{$DVDB{$sel_site}{"PROJECTS"}});
}
sub connectDB
{
	my ($site,$project)=@_;
	my $dbname=lc($project);
    $dbname="ellesmere" if $project eq "Polaris22";
	my $dbhost=$DVDB{$site}{"HOST"};
	my $dbuser=$DVDB{$site}{"USER"};
	my $dbpasswd=$DVDB{$site}{"PASSWD"};
	printf("Trying to connect to Database $dbname\@$site...\n") if $debug;
	$db->disconnect if $db;
	$db=DBI->connect("dbi:Pg:dbname=$dbname;host=$dbhost",$dbuser,$dbpasswd,
			{PrintError => 1,
			RaiseError => 0});
	print("Connect successfully\n") if $debug;
}

sub refreshDB
{
	connectDB($sel_site,$sel_project);
	getTrees();
	$box_tree->configure(-values=>Tkx::list(@Trees));
	getSuites();
	$box_suite->configure(-values=>Tkx::list(@Suites));
}


sub queryDB_col
{
	my $query=shift;
	printf($query."\n") if $debug;
	return $db->selectcol_arrayref($query);
}

sub queryDB
{
	my $query=shift;
	printf($query."\n") if $debug;
	return $db->selectall_arrayref($query);
}

sub getSuites
{
	@Suites=();
	$Suites[0]="ALL";
	my $ref=queryDB_col("SELECT DISTINCT b.block_name
		  FROM block_run br
		  JOIN block b ON br.block_ref=b.block_id
		  JOIN regression_run rr ON br.regression_run_ref=rr.regression_run_id
		  JOIN regression r ON rr.regression_ref=r.regression_id
		  WHERE r.regression_name=\'$sel_tree\'
		  ORDER BY b.block_name");
	push(@Suites,@$ref);
	$sel_suite=$Suites[0];
}

sub getTrees
{
	@Trees=();
	my $ref=queryDB_col("SELECT DISTINCT r.regression_name
		FROM regression r
		ORDER BY r.regression_name");
	@Trees=@$ref;
	$sel_tree=$Trees[0];
}

sub show_summary
{
	my $query_cmd="SELECT rr.regression_run_id, rr.changelist, rr.start_time, rr.end_time, rr.log_directory FROM regression_run rr
	JOIN regression r ON rr.regression_ref = r.regression_id 
	WHERE r.regression_name = \'$sel_tree\' ";
	$query_cmd.="AND rr.regression_run_id IN (
	SELECT br.regression_run_ref FROM block_run br
	JOIN block b ON b.block_id=br.block_ref
	WHERE b.block_name= \'$sel_suite\') " if $sel_suite ne 'ALL';
	$query_cmd.=" ORDER BY rr.regression_run_id DESC";
	my $ref=queryDB($query_cmd);
	my $num=1;
	$tv_regress->delete($tv_regress->children(""));
	foreach my $row (@$ref)
	{
		last if($num++ >$show_count);
		my ($rrid,$changelist,$start_time,$end_time,$log_dir)=@$row;
		my $result_ref=queryDB("SELECT b.block_name, ts.test_status_name, COUNT(ts.test_status_id) AS count
		        FROM $sel_project\_$sel_tree\_test_object_run tor
		        JOIN test_object tob ON tob.test_object_id = tor.test_object_ref
		        JOIN test_status ts ON ts.test_status_id = tor.test_status_ref
		        JOIN block b ON tob.block_ref=b.block_id
		        WHERE tor.regression_run_ref = $rrid
		        GROUP BY ts.test_status_name, b.block_name
		        ORDER BY b.block_name, ts.test_status_name");
		my %result=();
		foreach my $result_row (@$result_ref)
		{
			my ($block,$status,$count)=@$result_row;
			$result{$block}{'pass'}=$count if $status eq "passed";
			$result{$block}{'fail'}=$count if $status eq "failed";
			$result{$block}{'total'}+=$count;
			$result{'ALL'}{'pass'}+=$count if $status eq "passed";
			$result{'ALL'}{'fail'}+=$count if $status eq "failed";
			$result{'ALL'}{'total'}+=$count;
		}
		my $pass=$result{$sel_suite}{'pass'};
		my $fail=$result{$sel_suite}{'fail'};
		my $total=$result{$sel_suite}{'total'};
		my $rate=$total==0?0:($pass/$total*100);
		my $id="$rrid\_$sel_suite";
		$tv_regress->insert("","end",-id=>$id,-text=>$rrid);
		$tv_regress->set($id,"changelist",$changelist);
		$tv_regress->set($id,"starttime",$start_time);
		$tv_regress->set($id,"endtime",$end_time);
		$tv_regress->set($id,"logdir",$log_dir);
		$tv_regress->set($id,"pass",$pass);
		$tv_regress->set($id,"fail",$fail);
		$tv_regress->set($id,"total",$total);
		$tv_regress->set($id,"rate",sprintf("%3.2f%",$rate));
		$tv_regress->tag_add("allpass",$id) if $pass==$total;
		$tv_regress->tag_add("allfail",$id) if $fail==$total;
		$tv_regress->tag_add("allpart",$id) if ($fail<=$total && $pass<=$total);
		if($sel_suite eq 'ALL')
		{
			foreach my $block (keys %result)
			{
				next if $block eq 'ALL';
				$pass=$result{$block}{'pass'};
				$fail=$result{$block}{'fail'};
				$total=$result{$block}{'total'};
				$rate=$total==0?0:($pass/$total*100);
				my $child_id="$rrid\_$block";
				$tv_regress->insert($id,"end",-id=>$child_id,-text=>$block);
				$tv_regress->set($child_id,"pass",$pass);
				$tv_regress->set($child_id,"fail",$fail);
				$tv_regress->set($child_id,"total",$total);
				$tv_regress->set($child_id,"rate",sprintf("%3.2f%",$rate));
				$tv_regress->tag_add("blockpass",$child_id) if $pass==$total;
				$tv_regress->tag_add("blockfail",$child_id) if $fail==$total;
				$tv_regress->tag_add("blockpart",$child_id) if ($fail<=$total && $pass<=$total);
			}
		}
	}
}

sub showTestWin
{
	my $id=shift;
	$id=~/(\d+)_(.+)/;
	my ($rrid,$suite)=($1,$2);
	my $logdir=$tv_regress->set($id,"logdir");
	my $logid=$id;
	if(($logdir eq "") && $tv_regress->parent($id) ne "")
	{
		$logid=$tv_regress->parent($id);
		$logdir=$tv_regress->set($logid,"logdir");
	}
	my @logpaths=();
	if($logdir eq "")
	{
		my $ref=queryDB_col("SELECT log_file FROM job.job_cmd_$rrid WHERE log_file LIKE '%$suite%run_dv-cmd%'");
		@logpaths=@$ref;
	}
	my $mw_test=$mw->new_toplevel;
	$mw_test->g_wm_title("$sel_project\_$sel_tree\_$suite\_runid$rrid");
	$mw_test->g_wm_geometry("800x600+55+55");
	my $tv_tests=$mw_test->new_ttk__treeview;
	my @heads=("status","seed","starttime","endtime","logpath");
	my @heads_text=("Status","Seed","StartTime","EndTime","Log Path");
	$tv_tests->configure(-columns=>Tkx::list(@heads),-height=>25);
	$tv_tests->column("#0",-width=>300);
	$tv_tests->heading("#0",-text=>"Test Name");
	for(my $i=0;$i<@heads;$i++)
	{
		$tv_tests->column($heads[$i],-anchor=>"w",-width=>100);
		$tv_tests->heading($heads[$i],-text=>$heads_text[$i]);
	}
	$tv_tests->column("seed",-width=>50);
	$tv_tests->column("starttime",-width=>150);
	$tv_tests->column("endtime",-width=>150);
	$tv_tests->column("logpath",-width=>1000);
	$tv_tests->g_grid(-row=>0,-column=>0,-sticky=>"nesw");
	$tv_tests->tag_configure("pass",-background=>"#AAFFAA");
	$tv_tests->tag_configure("fail",-background=>"#FFAAAA");
	my $sbar_test=$mw_test->new_ttk__scrollbar(-orient=>"vertical",-command=>[$tv_tests,"yview"]);
	$sbar_test->g_grid(-row=>0,-column=>1,-sticky=>"wns");
	my $sbar_test_v=$mw_test->new_ttk__scrollbar(-orient=>"horizontal",-command=>[$tv_tests,"xview"]);
	$sbar_test_v->g_grid(-row=>1,-column=>0,-sticky=>"ewn");
	$tv_tests->configure(-yscrollcommand=>[$sbar_test,"set"]);
	$tv_tests->configure(-xscrollcommand=>[$sbar_test_v,"set"]);
	$mw_test->g_grid_rowconfigure(0 ,-weight=>1);
	$mw_test->g_grid_columnconfigure(0,-weight=>1);

	my $query_cmd="SELECT t.test_name AS test_name, ts.test_status_name AS status, tor.random_seed, 
SUBSTR(CAST(tor.start_time AS text), 6) AS start_time,
SUBSTR(CAST(tor.end_time AS text), 6) AS end_time,
tor.failed_job_run_ref AS failed_job_run_id
FROM $sel_project\_$sel_tree\_test_object_run tor
JOIN test_object tob ON tor.test_object_ref = tob.test_object_id
JOIN test t ON t.test_id = tob.test_ref
JOIN test_status ts ON ts.test_status_id = tor.test_status_ref
JOIN arch a ON a.arch_id = tor.arch_ref
JOIN conf c ON c.conf_id = tor.conf_ref
JOIN block b ON b.block_id = tob.block_ref
LEFT OUTER JOIN job.job_run_$rrid jr ON jr.job_run_id=tor.failed_job_run_ref
WHERE tor.regression_run_ref = $rrid ";
	$query_cmd.=" AND b.block_name = '$suite' " if($suite ne 'ALL');
	$query_cmd.="ORDER BY status,test_name";

	my $tests_ref=queryDB($query_cmd);
	my $logpath="";
	foreach my $row (@$tests_ref)
	{
		my ($testname,$status,$seed,$starttime,$endtime,$failid)=@$row;
		$tv_tests->insert("","end",-id=>$testname,-text=>$testname);
		$tv_tests->set($testname,"status",$status);
		$tv_tests->set($testname,"starttime",$starttime);
		$tv_tests->set($testname,"endtime",$endtime);
		$logpath="";
		if($failid ne "" && $logdir ne "" && @logpaths==0)
		{
			$logpath="$logdir$sel_tree"."1.log.$failid";
		}
		elsif($logdir eq "" && @logpaths>0)
		{
			my @match_path=grep(/$testname/,@logpaths);
			$logpath=$match_path[0] if(@match_path>0);
		}
		$tv_tests->set($testname,"logpath",$logpath);
		$tv_tests->tag_add("pass",$testname) if $status eq "passed";
		$tv_tests->tag_add("fail",$testname) if $status eq "failed";
	}
	$tv_tests->g_bind("<Double-1>",[sub{
			my $testname=$tv_tests->identify_item(@_);
			return if $testname eq "";
			my $logpath=$tv_tests->set($testname,"logpath");
			return if $logpath eq "";
			viewLog($logpath);
		},Tkx::Ev("%x","%y")]);
}

sub getBookmark
{
	%Bookmark=();
	$tv_bookmark->delete($tv_bookmark->children(""));
	foreach my $file (@Bookmark_files)
	{
		if(open(TMP,$file))
		{
			while(my $line=<TMP>)
			{
				chomp($line);
				$line=~s/^\s+//;
				$line=~s/\s+$//;
				next if $line eq "";
				addBookmark(split('\.',$line));
			}
			close(TMP);
			last;
		}
	}
}

sub addBookmark
{
	my ($site,$project,$tree,$suite)=@_;
	$suite='ALL' if $suite eq "";
	my $item="$site.$project.$tree.$suite";
	$suite="" if $suite eq "ALL";
	if(!exists($Bookmark{$item}))
	{
		$Bookmark{$item}=1;
		$tv_bookmark->insert("","end",-id=>$item,-text=>$item);
		$tv_bookmark->set($item,"site",$site);
		$tv_bookmark->set($item,"project",$project);
		$tv_bookmark->set($item,"tree",$tree);
		$tv_bookmark->set($item,"suite",$suite);
	}
}

sub viewLog
{
	my $logpath=shift;
	my $sitename="";
	$sitename=`/tool/pandora/bin/sitename` if $^O eq "linux";
	chomp($sitename);
	my $logviewer=$^O eq "linux"?"firefox":"explorer";
	$logviewer=$ENV{"LOGVIEWER"} if(exists $ENV{"LOGVIEWER"});
	my $path="";
	my $logsite=$logpath=~/^\/proj\/(mc-regress|9xx-regresss1)/ ? "SRDC":$sel_site eq "CYB1"?"CYB":$sel_site;
	if($sitename eq $logsite)
	{
		$logviewer="gvim";
		$path=$logpath;
		$path="$logpath.gz" if(-f "$logpath.gz");
	}
	else
	{
		$path="http://logviewer-".lc($logsite).$logpath if ($sitename ne "$sel_site");
	}
	system("$logviewer $path ".($^O eq "linux"?"&":""));
}

1;
