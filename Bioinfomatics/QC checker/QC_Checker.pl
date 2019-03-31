use Win32::OLE;
use strict;
use Tkx;

require "INC.pm";
our $WORD=new Win32::OLE('Word.Application');
$WORD->{'Visible'} = 1;
require "UI.pm";
$WORD->quit();
