#!/usr/bin/perl
use strict;
use DBI;
use LWP::Simple;

my $debug_all=1;
my $insert_debug=1;
my $db_debug=0;
my $url_debug=0;

my $DBHost="rm-2zesakl053oe9hd18.mysql.rds.aliyuncs.com";
#my $DBHost="localhost";
my $DBName="QiQuan";
my $DBUser="root";
my $DBPasswd="!QAZ2wsx";
#my $DBPasswd="yjanvj10.4";
my $URLBase="http://hq.sinajs.cn/list=";


my $dbcon;
my %etf_info;
my %contract_list;
my $etf_id;
sub db_connect
{
  return if($dbcon);
  print "db_connect...\n" if $debug_all || $db_debug;
  my $constr="DBI:mysql:database=".$DBName.";host=".$DBHost;
  $dbcon=DBI->connect($constr,$DBUser, $DBPasswd);
  die "DB connect fail\n" if not $dbcon;
}

sub get_50etf
{
  print "enter get_50etf\n" if $debug_all;
  my $url=$URLBase."sh510050";
  my $content= get $url;
  print "get_50etf: $content\n" if $debug_all || $url_debug;
  if($content=~/.*="(.*)";/)
  {
    my @etf=split(",",$1);
    return -1 if(@etf==0);
    $etf_info{'price'}=$etf[3];
    $etf_info{'amount'}=$etf[8];
    $etf_info{'datetime'}=$etf[30]." ".$etf[31];
    return 0;
  }
  return -1;
}

sub get_contract_list
{
  print "enter get_contract_list\n" if $debug_all;
  my $cur_month=shift;
  my @month_list=($cur_month, $cur_month+1, $cur_month+3, $cur_month+6);
  my $url=$URLBase;
  my $cur_year=17;
  my $year=$cur_year;
  foreach my $mon (@month_list)
  {
    $year=$cur_year+1 if $mon>12;
    $mon=$mon-12 if $mon>12;
    $url=sprintf("%sOP_UP_510050%02d%02d,OP_DOWN_510050%02d%02d,",$url,$year,$mon,$year,$mon);
  }
  my $content=get $url;
  print $content,"\n" if $debug_all || $url_debug;
  my @split_content=split("\n",$content);
  return -1 if @split_content==0;
  %contract_list=();
  foreach $content (@split_content)
  {
    if($content=~/(OP_.*)="(.*)"/)
    {
      my @list=split(",",$2);
      foreach my $tmp (@list)
      {
        $contract_list{$tmp}=$1;
      }
    }
  }
}

sub query_single_value
{
    my $sql=shift;
    print "$sql\n" if $debug_all || $db_debug;
    db_connect();
    my $stmt=$dbcon->prepare($sql);
    $stmt->execute;
    my @result=$stmt->fetchrow_array();
    $stmt->finish;
    if(scalar(@result)==0)
    {
        return -1;
    }
    else
    {
        return $result[0];
    }
}

sub query_db
{
    my $sql=shift;
    print "query_db $sql\n" if $debug_all || $db_debug;
    db_connect();
    my $stmt=$dbcon->prepare($sql);
    $stmt->execute;
    my %result=$stmt->fetchrow_array();
    $stmt->finish;
    return %result;
}

sub exist_contract
{
  print "enter exist_contract\n" if $debug_all;
  my ($year, $month, $type, $grade)=@_;
  my $sql="select * from contract where year=$year and month=$month and type=$type and grade=\'$grade\'";
  my $result=query_single_value($sql);
  return ($result==-1) ? 0:1;
}

sub get_contract_data
{
  print "enter get_contract_data\n" if $debug_all;
  my $url=$URLBase.join(",",keys(%contract_list));
  my $content=get $url;
  print $content,"\n" if $debug_all || $url_debug;
  my @contract_array=split("\n",$content);
  return -1 if @contract_array==0;
#  open(TMP, "tmp");
#  my @contract_array=<TMP>;

  my $contract_group;
  my $name;
  my $price;
  my $datetime;
  my $year;
  my $month;
  my $grade;
  my $type;
  foreach my $contract_line (@contract_array)
  {
    if($contract_line=~/(CON_OP.*)="(.*)"/)
    {
      die "contract_list do not have $1\n" if not exists($contract_list{$1});
      my @contract_split=split(",", $2);
      $name=$contract_split[37];
      $price=$contract_split[3];
      $datetime=$contract_split[32];
      $contract_group=$contract_list{$1};
      die "unrecognize gruop:$contract_group\n" if not $contract_group=~/OP_(\S+)_510050(\d{2})(\d{2})/;
      $type=($1 eq "UP")?1:0;
      $year=2000+$2;
      $month=$3;
      $name=~/\d{4}A?/;
      $grade=$&;
      if(!exist_contract($year, $month, $type, $grade))
      {
        my $sql=sprintf("insert into contract(year, month, type, grade) values(%d, %d, %d, '%s')", $year, $month, $type, $grade);
        print $sql,"\n" if $debug_all || $db_debug || $insert_debug;
        die "insert contract fail\n" if not $dbcon->do($sql);
      }
      my $id=query_single_value("select contract_id from contract where year=$year and month=$month and type=$type and grade=\'$grade\'");
      die "get contract id fail\n" if($id==-1);
      my $sql=sprintf("insert into contract_info(etf_id, contract_id, contract_price, datetime) values(%d, %d, %f, \'%s\')", $etf_id, $id, $price, $datetime);
      print $sql,"\n" if $debug_all || $db_debug || $insert_debug;
      die "insert contract info fail" if not $dbcon->do($sql);
    }
  }
}

sub insert_etf
{
  printf "enter insert_etf\n" if $debug_all;
  my $sql="select datetime from last_etf";
  my $last_datetime=query_single_value($sql);
  return -1 if($etf_info{'datetime'} eq $last_datetime);
  $sql=sprintf("insert into etf_info(price,amount,datetime) values(%f,%d,\'%s\')", $etf_info{'price'}, $etf_info{'amount'}, $etf_info{'datetime'});
  print $sql,"\n" if $debug_all || $db_debug || $insert_debug;
  return -1 if not $dbcon->do($sql);
  $sql="select etf_id from last_etf";
  $etf_id=query_single_value($sql);
  return 0;
}


my @cur_datetime=localtime(time);
my $cur_month=$cur_datetime[4];
die "get 50etf price fail" if get_50etf()==-1;
exit if (insert_etf()==-1);
die "get contract_list fail\n" if get_contract_list($cur_month+1)==-1;
die "get contract_data fail\n" if get_contract_data()==-1;

